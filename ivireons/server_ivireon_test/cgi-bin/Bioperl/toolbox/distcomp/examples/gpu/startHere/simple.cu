/*
 * To compile this CU file use
 *
 *  nvcc -ptx simple.cu
 *
 * This will generate simple.ptx in the same directory. Then the kernels
 * can be loaded with makeKernel using
 *
 * k = parallel.gpu.CUDAKernel('simple.ptx', 'simple.cu', entryName);
 *
 * Make sure you are in the same dir as this file.
 */

// Copyright 2010 The MathWorks, Inc.
// $Revision: 1.1.8.2 $   $Date: 2010/05/10 17:04:02 $

/*
 * Define a very simple kernel to run on a single thread that adds a float
 * to another one. NOTE that any outputs MUST be pointers, hence the first
 * input to this function is a pointer, so that MATLAB treats it as an 
 * output.
 */
__global__ void reallySimple( float * pi, float c ) {
    *pi += c;
}

/*
 * Lets now use a thread block to run many threads at once. We will given
 * a vector as input and assume that there are the correct number of threads
 * for array elements. Each thread will add the constant c to each element
 */
__global__ void usesThreadBlock( float * pi, float c )  {
    int idx = threadIdx.x;
    pi[idx] += c;
}

/*
 * Lets now use both a thread block and a grid to go bigger than 512 in size
 */
__global__ void usesGridsAndBlocks( float * pi, float c )  {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    pi[idx] += c;
}

/*
 * Example that works correctly when there are more threads than array
 * elements.
 */
__global__ void includeArraySize( float * pi, float c, int s )  {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if ( idx < s ) {
        pi[idx] += c;
    }
}
