// Copyright 2010 The MathWorks, Inc.
// $Revision: 1.1.8.2 $   $Date: 2010/05/10 17:03:57 $

/*
 * Write only bandwith test - compute the index that this thread will read
 * and if the second input is greater than zero write it to the output
 */
__global__ void bandwidth1(float * pOutput, float val ) {
    // Calculate (for each thread) which element of the array to write
    int idx = blockDim.x*blockIdx.x + threadIdx.x;
    if ( val > 0 ) {
        pOutput[idx] = val;
    }
}

/*
 * Read and write only bandwith test - compute the index that this thread 
 * will read and if the second input is greater than zero read from the 
 * input and add 
 */
__global__ void bandwidth2(float * pData, float val ) {
    // Calculate (for each thread) which element of the array to read/write
    int idx = blockDim.x*blockIdx.x + threadIdx.x;
    if ( val > 0 ) {
        pData[idx] = pData[idx] + val;
    }
}

