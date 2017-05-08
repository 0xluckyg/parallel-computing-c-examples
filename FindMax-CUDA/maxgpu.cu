#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <cuda.h>

__global__ void findMaxKernel(unsigned int *array, unsigned int *max, int *mutex, unsigned int n)
{
	unsigned int index = threadIdx.x + blockIdx.x*blockDim.x;
	unsigned int stride = gridDim.x*blockDim.x;
	unsigned int offset = 0;

	__shared__ unsigned int cache[1024];

	unsigned int temp = 0;
	while(index + offset < n){
		temp = (temp > array[index + offset]) ? temp : array[index+offset];
		offset += stride;
	}

	cache[threadIdx.x] = temp;

	__syncthreads();

	// reduction
	unsigned int i = blockDim.x/2;
	while(i != 0){
		if(threadIdx.x < i){
			cache[threadIdx.x] = (cache[threadIdx.x] > cache[threadIdx.x + i]) ? cache[threadIdx.x] : cache[threadIdx.x + i];
		}

		__syncthreads();
		i /= 2;
	}

	if(threadIdx.x == 0){		
		atomicMax(max, cache[0]);
	}
}

unsigned int getmaxcu(unsigned int num[], unsigned int size)
{
	unsigned int *d_num;
	unsigned int *h_max;
	unsigned int *d_max;
	int *d_mutex;

	//Allocate memory
	h_max = (unsigned int*)malloc(sizeof(unsigned int));
	cudaMalloc((void**)&d_num, size*sizeof(unsigned int));
	cudaMalloc((void**)&d_max, sizeof(unsigned int));
	cudaMalloc((void**)&d_mutex, sizeof(int));
	cudaMemset(d_max, 0, sizeof(unsigned int));
	cudaMemset(d_mutex, 0, sizeof(unsigned int));

	//Copy from host to device
	cudaMemcpy(d_num, num, size*sizeof(unsigned int), cudaMemcpyHostToDevice);

	// call kernel
	dim3 gridSize = 256;
	dim3 blockSize = 1024;
	findMaxKernel<<< gridSize, blockSize >>>(d_num, d_max, d_mutex, size);

	//Copy from device to host
	cudaMemcpy(h_max, d_max, sizeof(unsigned int), cudaMemcpyDeviceToHost);

	// free memory	
	cudaFree(d_num);
	cudaFree(d_max);
	cudaFree(d_mutex);

	return h_max[0];
}

int main(int argc, char *argv[])
{
    unsigned int size = 0;  // The size of the array
    unsigned int i;  // loop index
    unsigned int * numbers; //pointer to the array
    
    if(argc !=2)
    {
		printf("usage: maxseq num\n");
		printf("num = size of the array\n");
		exit(1);
    }
   
    size = atol(argv[1]);

    numbers = (unsigned int *)malloc(size * sizeof(unsigned int));
    if( !numbers )
    {
		printf("Unable to allocate mem for an array of size %u\n", size);
		exit(1);
    }    

	srand(time(NULL)); // setting a seed for the random number generator
    // Fill-up the array with random numbers from 0 to size-1 
    for( i = 0; i < size; i++)
		numbers[i] = rand()  % size;    
   
    printf(" The maximum number in the array is: %u\n", getmaxcu(numbers, size));

	free(numbers);
	exit(0);
}
