%% GPU Bandwidth Test
%% Introduction
% This demo will measure several different bandwidths applicable to the
% performance of code on a GPU. Particularly the bandwidths for 
% 
% * Moving data from the host to the device
% * Retrieving data from the device to the host
% * Writing (only) data on the device
% * Reading and writing data on the device
% 
% These bandwidths affect the performance characteristics of code on the
% GPU, since almost all data destined for use in GPU computations will
% start on the host, and whilst running a kernel the data will need to be
% read from the GPU device memory and the results written back.
%
% We need to define some numbers that govern the overall size of tests. You
% may find the you want to change these numbers for your particular system
% as the results may change based on these numbers.

function gpudemo_bandwidth
%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2.4.2 $  $Date: 2010/06/21 17:55:24 $


% How many threads should each thread block run with - 512 is the max for
% most GPU's in 2010
T = 512;
% How many thread blocks should we ask the GPU to start up. Increasing this
% number should linearly increase the time taken to run the kernels.
G = 1024;

% Define the size in 'single' of the vector to test host to GPU bandwidth
% with. 
device = gpuDevice();
if log2( device.FreeMemory ) > 28
    % Device has enough free memory for a single vector of this length
    N = 5e7;
else
    % Device only has a small amount of free memory
    N = 1e7;
end


% We need to load up the 2 kernels that we are going to use to measure the
% device memory bandwidth. Note that PTX code is slightly different on 32
% and 64 bit platforms (owing to the way pointers are passed) so there are
% 2 different PTX files with the correct code in them.
cuFile  = 'bandwidth.cu';
ptxFile = ['bandwidth.' parallel.gpu.ptxext];
b1 = parallel.gpu.CUDAKernel(ptxFile, cuFile, 'bandwidth1');
b2 = parallel.gpu.CUDAKernel(ptxFile, cuFile, 'bandwidth2');
% How many bytes in a single
sizeofSingle = 4;


%% Moving data from the host to the device
% To test the bandwidth between the host and the device all we need to do
% is allocate an array in MATLAB(R) and time how long it takes to create a
% |GPUArray| object that represents data on the card.

% Allocate the data on the host that we will copy to the device
data = ones(N, 1, 'single');
% Time moving it to the device
tic
d = parallel.gpu.GPUArray(data);
allocT = toc;

fprintf('Time to allocate on GPU and copy memory:  %.2f milliS\n', allocT*1e3);
bandwidth =  sizeofSingle*N /allocT;
fprintf('Measured bandwidth is:                    %.3f GB/s\n\n', bandwidth*1e-9);

%% Moving data from the device to the host
% To test the bandwidth between device and host we time how long it takes
% to get that same data back from the card onto the host. We use the
% |gather| method of a |GPUArray| object to do this.

% Time retrieving the data from the device
tic
gather(d);
readT = toc;

fprintf('Time to allocate on host and copy memory: %.2f milliS\n', readT*1e3);
bandwidth =  sizeofSingle*N /readT;
fprintf('Measured bandwidth is:                    %.3f GB/s\n\n', bandwidth*1e-9);

%% Device Write-only Test
% This test is going to invoke one of the 2 kernels defined in the
% bandwidth.cu file (the one called |bandwidth1|). Provided that the second
% input to this kernel is greater than zero, each thread of the kernel will
% write that value (in a coalesced way) to global memory. Since we know that
% there is an overhead to launching kernels we will also measure that
% overhead and subtract from the final run time so that we are carefully
% measuring just the memory access times. Note that in the |iTimeKernelRun|
% function we reuse the input array as an output array to ensure that no
% memory is copied before calling the kernel on the device. The C code for
% the kernel we are calling is 
%
%  __global__ void bandwidth1(float * pOutput, float val ) {
%      // Calculate (for each thread) which element of the array to write
%      int idx = blockDim.x*blockIdx.x + threadIdx.x;
%      if ( val > 0 ) {
%          pOutput[idx] = val;
%      }
%  }


% Make sure that the kernel is using the correct number of threads and
% thread blocks
b1.ThreadBlockSize = T;
b1.GridSize = G;
% Make correctly sized data on the device
d = parallel.gpu.GPUArray(zeros(T, G, 'single'));

% Measure overhead - zero input to kernel - no memory write
overheadT = iTimeKernelRun(b1, d, 0);
fprintf('Run time with no memory access:    %.2f microS\n', overheadT*1e6);

% Measure runtime - one input to kernel - force memory write
runT = iTimeKernelRun(b1, d, 1);
fprintf('Run time with one memory access:   %.2f microS\n', runT*1e6);

% Compute memory bandwidth in B/s - float has 4 bytes
bandwidth =  sizeofSingle*T*G / (runT - overheadT);
fprintf('Measured bandwidth is: %.3f GB/s\n\n', bandwidth*1e-9);


%% Device Read \ Write Test
% This test is very similar to that above. The only difference is in the 
% kernel being called. This time the kernel will read from device memory
% first and then write to the same element of device memory. All access is
% coalesced. The C code for kernel we are calling is 
%
%  __global__ void bandwidth1(float * pData, float val ) {
%      // Calculate (for each thread) which element of the array to read/write
%      int idx = blockDim.x*blockIdx.x + threadIdx.x;
%      if ( val > 0 ) {
%          pData[idx] = pData[idx] + val;
%      }
%  }

b2.ThreadBlockSize = T;
b2.GridSize = G;
% Make correctly sized data
d = parallel.gpu.GPUArray(zeros(T, G, 'single'));

% Measure overhead - zero input
overheadT = iTimeKernelRun(b2, d, 0);
fprintf('Run time with no memory access:    %.2f microS\n', overheadT*1e6);

% Measure runtime - one input
runT = iTimeKernelRun(b2, d, 1);
fprintf('Run time with two memory accesses: %.2f microS\n', runT*1e6);

% Compute memory bandwidth in B/s - float has 4 bytes, read once, written
% once.
bandwidth =  2*sizeofSingle*T*G / (runT - overheadT);
fprintf('Measured bandwidth is: %.3f GB/s\n\n', bandwidth*1e-9);

%%
snapnow;

%% Helper functions
% Function to loop on a kernel |run| method many times to get better timing
% information on how long the kernel takes to run. 
function t = iTimeKernelRun(k, x, s)
N = 1000;
tic
for i = 1:N
    x = feval(k, x, s);
end
t = toc/N;
