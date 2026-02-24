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

__global__ void matrixMulKernel_1thread1row (
    int m, int k, int n, 
    const float *A_d, const float *B_d, float* C_d
) {
    int i = blockDim.x * blockIdx.x + threadIdx.x;

    if (i < m) {
        for (int j = 0; j < n; j++) {
            float sum = 0;
            for (int x = 0; x < k; x++) {
                sum += A_d[i * k + x] * B_d[x * n + j];
            }
            C_d[i * n + j] = sum;
        }
    }
}

void basicSgemm_d_1thread1row (
    int m, int k, int n, 
    const float *A_h, const float *B_h, float* C_h
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
    dim3 blockDim(256, 1);
    dim3 gridDim((m + blockDim.x - 1) / blockDim.x, 1);
    matrixMulKernel_1thread1row<<<gridDim, blockDim>>>(m, k, n, A_d, B_d, C_d);
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
    printf("    basicSgemm_d_1thread1row:       %f s\n", total);

}

__global__ void matrixMulKernel_1thread1column(
    int m, int k, int n, 
    const float *A_d, const float *B_d, float* C_d
) {
    int j = blockDim.y * blockIdx.y + threadIdx.y;

    if (j < n) {
        for (int i = 0; i < m; i++) {
            float sum = 0;
            for (int x = 0; x < k; x++) {
                sum += A_d[i * k + x] * B_d[x * n + j];
            }
            C_d[i * n + j] = sum;
        }
    }
}

void basicSgemm_d_1thread1column(
    int m, int k, int n, 
    const float *A_h, const float *B_h, float* C_h
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
    dim3 blockDim(1, 256);
    dim3 gridDim(1, (n + blockDim.y - 1) / blockDim.y);
    matrixMulKernel_1thread1column<<<gridDim, blockDim>>>(m, k, n, A_d, B_d, C_d);
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
    printf("    basicSgemm_d_1thread1row:       %f s\n", total);

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

    const int numOutputs = 4;
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
    printf("\n");
    basicSgemm_d_1thread1element(m, k, n, A, B, outputBufs[1]);
    printf("\n");
    basicSgemm_d_1thread1row(m, k, n, A, B, outputBufs[2]);
    printf("\n");
    basicSgemm_d_1thread1column(m, k, n, A, B, outputBufs[3]);
    printf("\n");

    printf("Verifying results...\n");
    for (int i = 0; i < numOutputs; i++) {
        switch (i) {
            case 0: printf("basicSgemm_h                    "); break;
            case 1: printf("basicSgemm_d_1thread1element    "); break;
            case 2: printf("basicSgemm_d_1thread1row        "); break;
            case 3: printf("basicSgemm_d_1thread1column     "); break;
            default:printf("unkown                          "); break;
        }
        if (verify(outputBufs[0], outputBufs[i], m, n)) {
            printf("TEST_PASSED\n");
        } else {
            printf("TEST_FAILED\n");
        }
    }
}