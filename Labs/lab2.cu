
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <stdlib.h>;

using namespace std;


__global__ void vectorsSum(int* a, int* b, int* c, int* d)
{

    int globalIDx = blockIdx.x * blockDim.x + threadIdx.x;
    int globalIDy = blockIdx.y * blockDim.y + threadIdx.y;
    int globalIDz = blockIdx.z * blockDim.z + threadIdx.z;

    int globalId = (globalIDz * dimX * dimY) + (globalIDy * blockDim.x * gridDim.x) + globalIDx;

    d[globalId] = a[globalId] + b[globalId] + c[globalId];
}

int main()
{

    const int arraySize = 10000;

    dim3 blockSize(10, 10, 1);
    dim3 gridSize(10, 10, 1);

    int a_host[arraySize];
    int b_host[arraySize];
    int c_host[arraySize];

    int array_final_host[arraySize];

    for (int i = 0; i < arraySize; i++) {
        a_host[i] = i;
        b_host[i] = i;
        c_host[i] = i;
    }

    int* a_device;
    int* b_device;
    int* c_device;

    int* array_final_device;

    const int dataCount = arraySize;
    const int data_size = dataCount * sizeof(int);

    cudaMalloc((void**)&a_device, data_size);
    cudaMalloc((void**)&b_device, data_size);
    cudaMalloc((void**)&c_device, data_size);
    cudaMalloc((void**)&array_final_device, data_size);

    cudaMemcpy(a_device, a_host, data_size, cudaMemcpyHostToDevice);
    cudaMemcpy(b_device, b_host, data_size, cudaMemcpyHostToDevice);
    cudaMemcpy(c_device, c_host, data_size, cudaMemcpyHostToDevice);
    cudaMemcpy(array_final_device, array_final_host, data_size, cudaMemcpyHostToDevice);

    vectorsSum << <gridSize, blockSize >> > (a_device, b_device, c_device, array_final_device);

    cudaMemcpy(c_host, c_device, data_size, cudaMemcpyDeviceToHost);
    cudaMemcpy(a_host, a_device, data_size, cudaMemcpyDeviceToHost);
    cudaMemcpy(b_host, b_device, data_size, cudaMemcpyDeviceToHost);
    cudaMemcpy(array_final_host, array_final_device, data_size, cudaMemcpyDeviceToHost);

    for (int i = 0; i < arraySize; ++i) {
        printf("%d\n", array_final_host[i]);
    }

    cudaDeviceReset();
    cudaFree(a_device);
    cudaFree(b_device);
    cudaFree(c_device);
    cudaFree(array_final_device);

    cudaDeviceSynchronize();
    
    return 0;
}