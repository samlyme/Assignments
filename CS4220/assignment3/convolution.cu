#include "opencv2/core/types.hpp"
#include "opencv2/imgcodecs.hpp"
#include "opencv2/imgproc.hpp"
#include <iostream>
#include <stdlib.h>
#include <cuda.h>
#include <cuda_runtime.h>
#include <time.h>

#include <opencv2/opencv.hpp>

#define DIAMETER 5
#define RADIUS 2

#define CHECK(call) {                                         \
    cudaError_t err = call;                                   \
    if (err != cudaSuccess) {                                 \
        fprintf(stderr, "CUDA error in %s:%d: %s\n",          \
                __FILE__, __LINE__, cudaGetErrorString(err)); \
        exit(EXIT_FAILURE);                                   \
    }                                                         \
}

__constant__ float d_filter[DIAMETER * DIAMETER] = {
    1.0f / (DIAMETER * DIAMETER), 1.0f / (DIAMETER * DIAMETER), 1.0f / (DIAMETER * DIAMETER), 1.0f / (DIAMETER * DIAMETER), 1.0f / (DIAMETER * DIAMETER),
    1.0f / (DIAMETER * DIAMETER), 1.0f / (DIAMETER * DIAMETER), 1.0f / (DIAMETER * DIAMETER), 1.0f / (DIAMETER * DIAMETER), 1.0f / (DIAMETER * DIAMETER),
    1.0f / (DIAMETER * DIAMETER), 1.0f / (DIAMETER * DIAMETER), 1.0f / (DIAMETER * DIAMETER), 1.0f / (DIAMETER * DIAMETER), 1.0f / (DIAMETER * DIAMETER),
    1.0f / (DIAMETER * DIAMETER), 1.0f / (DIAMETER * DIAMETER), 1.0f / (DIAMETER * DIAMETER), 1.0f / (DIAMETER * DIAMETER), 1.0f / (DIAMETER * DIAMETER),
    1.0f / (DIAMETER * DIAMETER), 1.0f / (DIAMETER * DIAMETER), 1.0f / (DIAMETER * DIAMETER), 1.0f / (DIAMETER * DIAMETER), 1.0f / (DIAMETER * DIAMETER)
};

const float h_filter[DIAMETER * DIAMETER] = {
    1.0f / (DIAMETER * DIAMETER), 1.0f / (DIAMETER * DIAMETER), 1.0f / (DIAMETER * DIAMETER), 1.0f / (DIAMETER * DIAMETER), 1.0f / (DIAMETER * DIAMETER),
    1.0f / (DIAMETER * DIAMETER), 1.0f / (DIAMETER * DIAMETER), 1.0f / (DIAMETER * DIAMETER), 1.0f / (DIAMETER * DIAMETER), 1.0f / (DIAMETER * DIAMETER),
    1.0f / (DIAMETER * DIAMETER), 1.0f / (DIAMETER * DIAMETER), 1.0f / (DIAMETER * DIAMETER), 1.0f / (DIAMETER * DIAMETER), 1.0f / (DIAMETER * DIAMETER),
    1.0f / (DIAMETER * DIAMETER), 1.0f / (DIAMETER * DIAMETER), 1.0f / (DIAMETER * DIAMETER), 1.0f / (DIAMETER * DIAMETER), 1.0f / (DIAMETER * DIAMETER),
    1.0f / (DIAMETER * DIAMETER), 1.0f / (DIAMETER * DIAMETER), 1.0f / (DIAMETER * DIAMETER), 1.0f / (DIAMETER * DIAMETER), 1.0f / (DIAMETER * DIAMETER)
};

double myCPUTimer() {
    struct timespec ts;
    // CLOCK_MONOTONIC acts like a stopwatch; it guarantees the time only moves forward
    clock_gettime(CLOCK_MONOTONIC, &ts); 
    
    // tv_sec is seconds, tv_nsec is nanoseconds. We combine them into a single decimal!
    return (double)ts.tv_sec + (double)ts.tv_nsec / 1000000000.0;
}

bool verify(cv::Mat& a, cv::Mat& b, unsigned int nRows, unsigned int nCols) {
    if (a.empty() || b.empty()) {
        std::cerr << "One or both images are empty.\n";
        return false;
    }

    if (a.size() != b.size()) {
        std::cerr << "Image sizes differ.\n";
        return false;
    }

    if (a.type() != b.type()) {
        std::cerr << "Image types differ.\n";
        return false;
    }

    cv::Mat diff;
    cv::absdiff(a, b, diff);

    const int maxPixelDiff = 1;

    double minDiff = 0.0;
    double maxDiff = 0.0;
    cv::minMaxLoc(diff, &minDiff, &maxDiff);

    double meanDiff = cv::mean(diff)[0];

    cv::Mat badMask = diff > maxPixelDiff;
    int badPixels = cv::countNonZero(badMask);
    double badPixelRatio =
        static_cast<double>(badPixels) / static_cast<double>(a.rows * a.cols);

    bool ok = (maxDiff <= maxPixelDiff);

    if (!ok) {
        cv::imwrite("badPixels.png", badPixels);
    }

    return ok;
}

__host__ __device__ int reflect101(int x, int max) {
    if (max <= 1) return 0;

    while (x < 0 || x >= max) {
        if (x < 0) {
            x = -x;                    // reflect around 0, excluding edge
        }
        if (x >= max) {
            x = 2 * max - x - 2;      // reflect around max-1, excluding edge
        }
    }
    return x;
}

void blurImage_h(
    cv::Mat& Pout_Mat_h, cv::Mat& Pin_Mat_h, 
    unsigned int nRows, unsigned int nCols
) {
    std::cout << "blurImage_h" << std::endl;
    double start = myCPUTimer();

    Pout_Mat_h.create(Pin_Mat_h.size(), Pin_Mat_h.type());

    for (int row = 0; row < nRows; row++) {
        for (int col = 0; col < nCols; col++) {
            float sum = 0.0f;
            for (int i = -RADIUS; i <= RADIUS; i++) {
                for (int j = -RADIUS; j <= RADIUS; j++) {
                    int filterRow = i + RADIUS;
                    int filterCol = j + RADIUS;
                    sum += static_cast<float>(
                        Pin_Mat_h.at<unsigned char>(
                            reflect101(row + i, nRows),
                            reflect101(col + j, nCols)
                        )
                    ) * h_filter[filterRow * DIAMETER + filterCol];
                }
            }

            Pout_Mat_h.at<unsigned char>(row, col) = static_cast<unsigned char>(sum);
        }
    }

    std::cout << "blurImage_h elapsed: " << (myCPUTimer() - start) << " s" << std::endl;
}

void blurImage_opencv(
    cv::Mat& Pout_Mat_h, cv::Mat& Pin_Mat_h
) {
    double start = myCPUTimer();
    cv::blur(Pin_Mat_h, Pout_Mat_h, cv::Size_(DIAMETER, DIAMETER), cv::Point(-1, -1), cv::BORDER_REFLECT_101);
    std::cout << "blurImage_opencv elapsed: " << (myCPUTimer() - start) << " s" << std::endl;
}

__global__ void blurImage_Kernel(unsigned char* Pout, unsigned char* Pin, unsigned int nRows, unsigned int nCols) {
    int col = blockIdx.x * blockDim.x + threadIdx.x;
    int row = blockIdx.y * blockDim.y + threadIdx.y;

    if (row < nRows && col < nCols) {
        int sum = 0;
        for (int i = -RADIUS; i <= RADIUS; i++) {
            for (int j = -RADIUS; j <= RADIUS; j++) {
                sum += Pin[reflect101(row + i, nRows) * nCols + reflect101(col + j, nCols)];
            }
        }

        Pout[row * nCols + col] = (float) sum / (DIAMETER*DIAMETER);
    }
}

void blurImage_d(
    cv::Mat& Pout_Mat_h,
    const cv::Mat& Pin_Mat_h,
    unsigned int nRows,
    unsigned int nCols
) {
    std::cout << "blurImage_d" << std::endl;
    double start = myCPUTimer();
    Pout_Mat_h.create(nRows, nCols, CV_8UC1);

    unsigned char *Pout, *Pin;

    CHECK(cudaMalloc(&Pout, nRows * nCols));
    CHECK(cudaMalloc(&Pin,  nRows * nCols));

    CHECK(cudaMemcpy2D(
        Pin, nCols,
        Pin_Mat_h.data, Pin_Mat_h.step,
        nCols,
        nRows,
        cudaMemcpyHostToDevice
    ));

    dim3 blockSize(16, 16);
    dim3 gridSize((nCols + 15)/16, (nRows + 15)/16);

    blurImage_Kernel<<<gridSize, blockSize>>>(Pout, Pin, nRows, nCols);
    CHECK(cudaGetLastError());
    CHECK(cudaDeviceSynchronize());

    CHECK(cudaMemcpy2D(
        Pout_Mat_h.data, Pout_Mat_h.step,
        Pout, nCols,
        nCols,
        nRows,
        cudaMemcpyDeviceToHost
    ));

    cudaFree(Pout);
    cudaFree(Pin);

    std::cout << "blurImage_d elapsed: " << (myCPUTimer() - start) << " s" << std::endl;
}

#define TILE 16
__global__ void blurImage_tiled_Kernel(
    unsigned char* Pout,
    const unsigned char* Pin,
    unsigned int nRows,
    unsigned int nCols
) {
    __shared__ float tile[TILE + 2 * RADIUS][TILE + 2 * RADIUS];

    int tx = threadIdx.x;
    int ty = threadIdx.y;

    int out_x = blockIdx.x * TILE + tx;
    int out_y = blockIdx.y * TILE + ty;

    for (int y = ty; y < TILE + 2 * RADIUS; y += blockDim.y) {
        for (int x = tx; x < TILE + 2 * RADIUS; x += blockDim.x) {
            int gx = blockIdx.x * TILE + x - RADIUS;
            int gy = blockIdx.y * TILE + y - RADIUS;

            int rx = reflect101(gx, static_cast<int>(nCols));
            int ry = reflect101(gy, static_cast<int>(nRows));
            tile[y][x] = static_cast<float>(Pin[ry * static_cast<int>(nCols) + rx]);
        }
    }

    __syncthreads();

    if (out_x < nCols && out_y < nRows) {
        float sum = 0.0f;

        for (int ky = 0; ky < DIAMETER; ky++) {
            for (int kx = 0; kx < DIAMETER; kx++) {
                sum += tile[ty + ky][tx + kx] * d_filter[ky * DIAMETER + kx];
            }
        }

        sum = fminf(fmaxf(sum, 0.0f), 255.0f);
        Pout[out_y * nCols + out_x] = static_cast<unsigned char>(sum);
    }
}
void blurImage_tiled_d(
    cv::Mat& Pout_Mat_h,
    const cv::Mat& Pin_Mat_h,
    unsigned int nRows,
    unsigned int nCols
) {
    std::cout << "blurImage_tiled_d" << std::endl;
    double start = myCPUTimer();
    Pout_Mat_h.create(nRows, nCols, CV_8UC1);

    unsigned char *Pout, *Pin;

    CHECK(cudaMalloc(&Pout, nRows * nCols));
    CHECK(cudaMalloc(&Pin,  nRows * nCols));

    CHECK(cudaMemcpy2D(
        Pin, nCols,
        Pin_Mat_h.data, Pin_Mat_h.step,
        nCols,
        nRows,
        cudaMemcpyHostToDevice
    ));

    dim3 blockSize(TILE, TILE);
    dim3 gridSize((nCols + TILE - 1)/TILE, (nRows + TILE - 1)/TILE);

    blurImage_tiled_Kernel<<<gridSize, blockSize>>>(Pout, Pin, nRows, nCols);
    CHECK(cudaGetLastError());
    CHECK(cudaDeviceSynchronize());

    CHECK(cudaMemcpy2D(
        Pout_Mat_h.data, Pout_Mat_h.step,
        Pout, nCols,
        nCols,
        nRows,
        cudaMemcpyDeviceToHost
    ));

    cudaFree(Pout);
    cudaFree(Pin);

    std::cout << "blurImage_tiled_d elapsed: " << (myCPUTimer() - start) << " s" << std::endl;
}
#undef TILE

int main(int argc, char *argv[]) {
    if (argc < 2) {
        std::cerr << "Usage: " << argv[0] << " <image_path>" << std::endl;
        return -1;
    }

    std::string filename = argv[1];

    // Load image (grayscale since your assignment uses grayscale images)
    cv::Mat img = cv::imread(filename, cv::IMREAD_GRAYSCALE);

    // Error handling
    if (img.empty()) {
        std::cerr << "Error: Could not load image!" << std::endl;
        return -1;
    }

    std::cout << "Image loaded successfully!" << std::endl;
    std::cout << "Width: " << img.cols << ", Height: " << img.rows << std::endl << std::endl;

    cv::Mat out_opencv;
    blurImage_opencv(out_opencv, img);
    cv::imwrite("blurredImg_opencv.jpg", out_opencv);
    std::cout << std::endl;

    bool res;
    cv::Mat out_h(img.rows, img.cols, CV_8UC1);
    blurImage_h(out_h, img, img.rows, img.cols);
    std::cout << "out_h" << std::endl;
    res = verify(out_opencv, out_h, out_h.rows, out_h.cols);
    std::cout << (res ? "pass" : "fail") << std::endl << std::endl;
    cv::imwrite("blurredImg_cpu.jpg", out_h);

    cv::Mat out_d(img.rows, img.cols, CV_8UC1);
    blurImage_d(out_d, img, img.rows, img.cols);
    std::cout << "out_d" << std::endl;
    res = verify(out_opencv, out_d, out_h.rows, out_h.cols);
    std::cout << (res ? "pass" : "fail") << std::endl << std::endl;
    cv::imwrite("blurredImg_gpu.jpg", out_d);

    cv::Mat out_tiled_d(img.rows, img.cols, CV_8UC1);
    blurImage_tiled_d(out_tiled_d, img, img.rows, img.cols);
    std::cout << "out_tiled_d" << std::endl;
    res = verify(out_opencv, out_tiled_d, out_h.rows, out_h.cols);
    std::cout << (res ? "pass" : "fail") << std::endl << std::endl;
    cv::imwrite("blurredImg_tiled_gpu.jpg", out_tiled_d);


    for (int i = 0; i < out_h.rows; i++) {
        for (int j = 0; j < out_h.cols; j++) {

        }
    }

    return 0;
}
