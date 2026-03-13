
#include <stdio.h>
#include <stdlib.h>
#include <stdio.h>
#include <cuda.h>
#include <cuda_runtime.h>
#include <time.h>

#define CHECK(call) {                                         \
    cudaError_t err = call;                                   \
    if (err != cudaSuccess) {                                 \
        fprintf(stderr, "CUDA error in %s:%d: %s\n",          \
                __FILE__, __LINE__, cudaGetErrorString(err)); \
        exit(EXIT_FAILURE);                                   \
    }                                                         \
}

double myCPUTimer() {
    struct timespec ts;
    // CLOCK_MONOTONIC acts like a stopwatch; it guarantees the time only moves forward
    clock_gettime(CLOCK_MONOTONIC, &ts); 
    
    // tv_sec is seconds, tv_nsec is nanoseconds. We combine them into a single decimal!
    return (double)ts.tv_sec + (double)ts.tv_nsec / 1000000000.0;
}

bool verify(float* CPU_Answer, float* GPU_Answer, unsigned int nRows, unsigned int nCols) {
    bool out = true;
    float err = 0;
    for (unsigned int i = 0; i < nRows; i++) {
        for (unsigned int j = 0; j < nCols; j++) {
            int idx = i * nCols + j;
            float e = fabsf(CPU_Answer[idx] - GPU_Answer[idx]);
            err += e;
            if (e > 10e-4) {
                out = false;
            };
        }
    }
    if (!out) {
        printf("failed with MAE %f ", err / (nRows * nCols));
    }
    return out;
}

void basicSgemm_h(int m, int k, int n, const float *A_h, const float *B_h, float *C_h) {
    double start = myCPUTimer();
    for (int i = 0; i < m; i++) {
        for (int j = 0; j < n; j++)  {
            float sum = 0;
            for (int x = 0; x < k; x++) {
                sum += (A_h[i * k + x] * B_h[x * n + j]);
            }
            C_h[i * n + j] = sum;
        }
    }
    double stop = myCPUTimer();
    printf("MatMul on CPU:                    %f s\n", stop - start);
}

__global__ void matrixMulKernel_1thread1element (
    int m, int k, int n, 
    const float *A_d, const float *B_d, float* C_d
) {
    int i = blockDim.x * blockIdx.x + threadIdx.x;
    int j = blockDim.y * blockIdx.y + threadIdx.y;

    if (i < m && j < n) {
        float sum = 0;
        for (int x = 0; x < k; x++) {
            sum += A_d[i * k + x] * B_d[x * n + j];
        }
        C_d[i * n + j] = sum;
    }
}

void basicSgemm_d_1thread1element (
    int m, int k, int n, 
    const float *A_h, const float *B_h, float *C_h
) {
    double total = 0;
    double start, stop;
    float *A_d, *B_d, *C_d;

    start = myCPUTimer();
    CHECK(cudaMalloc(&A_d, sizeof(float) * m * k));
    CHECK(cudaMalloc(&B_d, sizeof(float) * k * n));
    CHECK(cudaMalloc(&C_d, sizeof(float) * m * n));
    stop = myCPUTimer();
    total += stop-start;
    printf("        cudaMalloc:                 %f s\n", stop - start);

    start = myCPUTimer();
    CHECK(cudaMemcpy(A_d, A_h, sizeof(float) * m * k, cudaMemcpyHostToDevice));
    CHECK(cudaMemcpy(B_d, B_h, sizeof(float) * k * n, cudaMemcpyHostToDevice));
    stop = myCPUTimer();
    total += stop-start;
    printf("        cudaMemcpy H2D:             %f s\n", stop - start);

    start = myCPUTimer();
    dim3 blockDim(16, 16);
    dim3 gridDim((m + blockDim.x - 1) / blockDim.x, 
                 (n + blockDim.y - 1) / blockDim.y);
    matrixMulKernel_1thread1element<<<gridDim, blockDim>>>(m, k, n, A_d, B_d, C_d);
    CHECK(cudaDeviceSynchronize());
    stop = myCPUTimer();
    total += stop-start;
    printf("        kernel:                     %f s\n", stop - start);

    start = myCPUTimer();
    CHECK(cudaMemcpy(C_h, C_d, sizeof(float) * m * n, cudaMemcpyDeviceToHost));
    stop = myCPUTimer();
    total += stop-start;
    printf("        cudaMemcpy D2H:             %f s\n", stop - start);

    CHECK(cudaFree(C_d));
    CHECK(cudaFree(A_d));
    CHECK(cudaFree(B_d));
    printf("    basicSgemm_d_1thread1element:   %f s\n", total);
}

__global__ void matrixMulKernel_tiled(
    int m, int k, int n, 
    const float *A_d, const float *B_d, float* C_d, 
    unsigned Adz_sz, unsigned Bdz_sz // these two are only really used for thread coarsening.
) {
    extern __shared__ float smem[];

    float *A_s = smem;
    float *B_s = &smem[Adz_sz];

    int tileWidth = blockDim.x;
    int numTiles = (k + tileWidth - 1) / tileWidth;

    int row = blockDim.y * blockIdx.y + threadIdx.y;
    int col = blockDim.x * blockIdx.x + threadIdx.x;
    
    float out = 0;
    for (int tile = 0; tile < numTiles; tile++) {
        int a_col = tile * tileWidth + threadIdx.x;
        int b_row = tile * tileWidth + threadIdx.y;

        // 2. Load A into shared memory (Transposed: A_s[local_col][local_row])
        if (row < m && a_col < k) {
            A_s[threadIdx.x * tileWidth + threadIdx.y] = A_d[row * k + a_col];
        } else {
            A_s[threadIdx.x * tileWidth + threadIdx.y] = 0.0f;
        }

        // 3. Load B into shared memory (Standard: B_s[local_row][local_col])
        if (b_row < k && col < n) {
            B_s[threadIdx.y * tileWidth + threadIdx.x] = B_d[b_row * n + col];
        } else {
            B_s[threadIdx.y * tileWidth + threadIdx.x] = 0.0f;
        }
        __syncthreads();

        for (int ki = 0; ki < tileWidth; ki++) {
            out += A_s[ki * tileWidth + threadIdx.y] * B_s[ki * tileWidth + threadIdx.x];
        }
        __syncthreads();
    }

    if (row < m && col < n) {
        C_d[row * n + col] = out;
    }
}

void basicSgemm_d_tiled (int m, int k, int n, const float *A_h, const float *B_h, float *C_h) {
    double total = 0;
    double start, stop;
    float *A_d, *B_d, *C_d;

    start = myCPUTimer();
    CHECK(cudaMalloc(&A_d, sizeof(float) * m * k));
    CHECK(cudaMalloc(&B_d, sizeof(float) * k * n));
    CHECK(cudaMalloc(&C_d, sizeof(float) * m * n));
    stop = myCPUTimer();
    total += stop-start;
    printf("        cudaMalloc:                 %f s\n", stop - start);

    start = myCPUTimer();
    CHECK(cudaMemcpy(A_d, A_h, sizeof(float) * m * k, cudaMemcpyHostToDevice));
    CHECK(cudaMemcpy(B_d, B_h, sizeof(float) * k * n, cudaMemcpyHostToDevice));
    stop = myCPUTimer();
    total += stop-start;
    printf("        cudaMemcpy H2D:             %f s\n", stop - start);

    // TODO: write hardware tuning
    printf("        Tuning tile size:\n");
    int deviceId;
    cudaGetDevice(&deviceId);
    cudaDeviceProp devProps;
    CHECK(cudaGetDeviceProperties(&devProps, deviceId));

    // First, we can safely ignore SMEM, our kernel only requires 2 floats 
    // per thread in SMEM, and all current Hardware supports at least 12 floats
    // per thread in SMEM.

    // Now, we aim to maximize Occupancy, while also maximizing block size.
    // Maximizing block size means more shared memory usage.

    int maxTileWidth;
    switch (devProps.maxThreadsPerMultiProcessor) {
        case 1536: maxTileWidth = 16; break; // 6 blocks
        case 2048: maxTileWidth = 32; break; // 2 blocks
        default:   maxTileWidth = 16; break;
    }

    printf("            maxTileWidth:          %d\n", maxTileWidth);
    unsigned int sharedMemorySize = 2 * maxTileWidth * maxTileWidth * sizeof(float);

    start = myCPUTimer();
    dim3 blockDim(maxTileWidth, maxTileWidth);
    dim3 gridDim((n + blockDim.y - 1) / blockDim.y, 
                 (m + blockDim.x - 1) / blockDim.x);
    matrixMulKernel_tiled<<<gridDim, blockDim, sharedMemorySize>>>(
        m, k, n, 
        A_d, B_d, C_d,
        maxTileWidth * maxTileWidth, maxTileWidth * maxTileWidth
    );
    CHECK(cudaDeviceSynchronize());
    stop = myCPUTimer();
    total += stop-start;
    printf("        kernel:                     %f s\n", stop - start);

    start = myCPUTimer();
    CHECK(cudaMemcpy(C_h, C_d, sizeof(float) * m * n, cudaMemcpyDeviceToHost));
    stop = myCPUTimer();
    total += stop-start;
    printf("        cudaMemcpy D2H:             %f s\n", stop - start);

    CHECK(cudaFree(C_d));
    CHECK(cudaFree(A_d));
    CHECK(cudaFree(B_d));
    printf("    basicSgemm_d_tiled:             %f s\n", total);
}

int main(int argc, char *argv[]) {
    cudaDeviceSynchronize(); // warm up device

    if (argc != 4) {
        fprintf(stderr, "Error: Incorrect number of arguments.\n");
        fprintf(stderr, "Usage: %s <m> <k> <n>\n", argv[0]);
        fprintf(stderr, "  m: Number of rows in Matrix A and C\n");
        fprintf(stderr, "  k: Number of columns in Matrix A, rows in Matrix B\n");
        fprintf(stderr, "  n: Number of columns in Matrix B and C\n");
        return EXIT_FAILURE;
    }

    int m = atoi(argv[1]);
    int k = atoi(argv[2]);
    int n = atoi(argv[3]);

    if (m <= 0 || k <= 0 || n <= 0) {
        fprintf(stderr, "Error: Matrix dimensions must be greater than 0.\n");
        return EXIT_FAILURE;
    }

    printf("Initializing matrices with dimensions:\n");
    printf("  Matrix A: %d x %d\n", m, k);
    printf("  Matrix B: %d x %d\n", k, n);
    printf("  Matrix C: %d x %d\n", m, n);

    float* A = (float*)malloc(sizeof(float) * m * k);
    float* B = (float*)malloc(sizeof(float) * k * n);

    const int numOutputs = 3;

    float *outputBufs[numOutputs];
    for (int i = 0; i < numOutputs; i++) {
        outputBufs[i] = (float*)malloc(sizeof(float) * m * n);
    }

    for (int i = 0; i < m; i++) {
        for (int j = 0; j < k; j++) {
            A[i * k + j] = rand()%100/100.0;
        }
    }
    for (int i = 0; i < k; i++) {
        for (int j = 0; j < n; j++) {
            B[i * n + j] = rand()%100/100.0;
        }
    }

    // DO NOT Comment out! This is the answer key!
    basicSgemm_h(m, k, n, A, B, outputBufs[0]);

    printf("MatMul on GPU:\n");
    basicSgemm_d_1thread1element(m, k, n, A, B, outputBufs[1]);
    basicSgemm_d_tiled(m, k, n, A, B, outputBufs[2]);

    printf("Verifying results...\n");
    for (int i = 0; i < numOutputs; i++) {
        switch (i) {
            case 0: printf("basicSgemm_h                    "); break;
            case 1: printf("basicSgemm_d_1thread1element    "); break;
            default:printf("basicSgemm_d_tiled              "); break;
        }
        if (verify(outputBufs[0], outputBufs[i], m, n)) {
            printf("TEST_PASSED\n");
        } else {
            printf("TEST_FAILED\n");
        }
    }

    free(A);
    free(B);
    for (int i = 0; i < numOutputs; i++) {
        free(outputBufs[i]);
    }
}
