%% Simple GPU Examples
%% Introduction
% This set of simple examples show how to 
%
% * Prepare CU code such that it can be called from MATLAB(R)
% * Make MATLAB aware of that compiled code
% * Interact with that code via the CUDAKernel object
% * Pass data into and out of calls to those kernels
% * How to leave data on the GPU for more optimal performance
%
% All the examples will use kernels defined in the |simple.cu| file. Please
% do look in this file for the C code for each kernel.

%   Copyright 2010 The MathWorks, Inc.

% Define the names of files for the source and compiled code that we are
% going to use. The CU file holds the source code and PTX file the compiled
% code.
filename = 'simple';
cuFile  = [filename '.cu']
ptxFile = [filename '.' parallel.gpu.ptxext]

%% Compile up the CU file
% The starting point for writing kernels in CUDA is to use the CU language
% to define what the kernel should do. This CU source file needs to be
% compiled using the NVIDIA compiler (|nvcc|) to generate compiled code
% that the driver and GPU understand. 
%
% The compiled format that MATLAB uses to talk to the CUDA drivers is
% called PTX. This is a low-level assembly language defined in by NVIDIA
% that is _not_ GPU hardware specific (which means that you can often use
% PTX code on many different GPU's provided that the features used are
% supported).
%
% We ship the correct PTX code for the examples, but it you wanted to
% compile the CU code yourself then you would use something like the
% command below to compile the CU file |source.cu| to produce |source.ptx| :
%
%    nvcc -ptx source.cu
%
% If you want to control the name of the resulting PTX output file then you
% can use the |-o| option on nvcc (e.g. to produce a PTX file called
% |output.ptxw32|) :
%
%    nvcc -ptx source.cu -o output.ptxw32
%
% Note: PTX code is usually platform specific because pointers are either
% 32-bit of 64-bit and the C integer type |long| is defined differently. If
% you compile the |simple.cu| file yourself, you will need to use a
% different extension for the |ptxFile| variable above, as we have used a
% platform specific one.

% system(['nvcc -ptx ' cuFile ' -o ' ptxFile]);

%% Load the reallySimple Example
% One of the kernels in the |simple.cu| file is called |reallySimple|. It
% expects to be run on just one thread on the GPU. It is passed a pointer
% to a float and a float. It dereferences the pointer, adds the two floats
% together, and puts the result in the location referenced by the
% pointer. We can make MATLAB aware of this kernel by creating a CUDAKernel
% object that represents this kernel. 
%
% MATLAB is made aware of the kernel using the |parallel.gpu.CUDAKernel|
% constructor. We need to pass in the name of the PTX file that contains the
% kernel, the name of the kernel to load (since a PTX file can contain many
% kernels), and the original CU file for the kernel (to pick up the C
% prototype of the kernel to tell us how data should be passed to the
% kernel). For more information on creating kernels see the documentation on
% the |parallel.gpu.CUDAKernel| constructor.
%
% The |CUDAKernel| object created has information about how to call the
% kernel, the thread block and grid sizes to define how many threads will be
% used on the GPU, the shared memory requirements, etc.

k = parallel.gpu.CUDAKernel(ptxFile, cuFile, 'reallySimple')

%% Calling the reallySimple CUDAKernel
% Having constructed a |CUDAKernel| object in MATLAB, we need know how to
% call the actual kernel on the GPU. We do this using the |feval| method of
% the |CUDAKernel| object. Several of the |CUDAKernel| objects properties provide
% information about how the kernel should be called. The |NumRHSArguments|
% property is the required number of right hand side arguments to the
% kernel. The |MaxNumLHSArguments| property is the maximum number of
% outputs. The |ArgumentTypes| property is the expected MATLAB types for
% each input argument, and if it is also considered an output as well.
%
% Basically
%
% * Scalar C types (int, float, double, etc.) require scalar inputs from
% MATLAB
% * Pointers to C types (int *, float *, etc) accept MATLAB arrays and are
% also outputs from the kernel
% * |const| pointer to C types (const int *) accept MATLAB arrays but are
% not outputs from the kernel
%
% For more information on the relationship between the kernel's C prototype
% and the MATLAB see the documentation.
%
% The |reallySimple| kernel has the C prototype 
%
%   void reallySimple( float * pi, float c )
%
% which means that it takes a single array and a single scalar from MATLAB,
% and adds them together to return a single array. _Note_ that since we are
% calling the kernel with one thread the single array we pass will consist
% of only one value.

% This kernel should add the 2 inputs together on a single thread
o = feval(k, 1, 2)

%% MATLAB type Coercion
% Notice how in the previous example we passed in the double precision
% numbers |1| and |2|, and were able to call the kernel successfully even
% though it was expecting the C type |float|. When passing MATLAB numeric
% data to any kernel it will be converted into the correct type before
% calling the kernel, so it is safe to pass in double arrays or scalars
% in place of the correct type. However do note that there is both a memory
% and time cost to doing this conversion, so if you can pass the correct
% type in it will be more efficient.
%
% Also note that the underlying return type from the kernel call is single as
% defined in the C prototype of the kernel.

disp(classUnderlying(o))

%% Run the usesThreadBlock example
% Now that we have created and used a kernel with a single thread, lets
% expand up a little and use more threads to run the kernel in parallel.
% The kernel we are going to use is in the |simple.cu| file and is called
% |usesThreadBlock|. The C prototype for this kernel is identical to that
% for the |reallySimple| example:
%
%   void usesThreadBlock( float * pi, float c )
%
% Once again this kernel just dereferences the pointer, adds the other
% float and assigns back to the pointer. However, this time the kernel
% makes use of the thread index to index into the array |pi| so that the
% size of the array can be greater than 1. The kernel assumes that the size
% of the array |pi| is the same as the number of threads that it is running
% with, so it is our responsibility to ensure that those two numbers match
% up.
%
% We are going to use the |ThreadBlockSize| property of the |CUDAKernel|
% object to change the number of threads launched when we call the |feval|
% method of the kernel.

% Create the CUDAKernel object
k = parallel.gpu.CUDAKernel(ptxFile, cuFile, 'usesThreadBlock');

% Show that this kernel still works on one thread
o = feval(k, 1, 2)
%%

% Now lets define a number N for the size of the array and the number of
% threads 
N = 8;
k.ThreadBlockSize = N;
% Execute the kernel with the correct array size for the first input
o = feval(k, ones(1, N), 2)
%%

% Make it bigger - lets not print out the result, we'll compare the result
% to evaluating the same thing in MATLAB
N = 256;
k.ThreadBlockSize = N;
% Execute the kernel with the correct array size for the first input
o = feval(k, ones(1, N), 2);
% Did we get the expected output? We can use the |gather| function on the
% |GPUArray| "o" to retrieve the data.
fprintf('Expected output size %d, got size %d\n', N ,numel(o));
fprintf('Is the output (o) all 3: %d\n', all(gather(o) == 3));

%%
% Note that the |ThreadBlockSize| property of a kernel can be a 1, 2 or 3
% element integer vector to define the x, y, and z values of |threadIdx| in
% the kernel code.

%% Run the usesGridsAndBlocks example
% The problem with only using thread blocks is that the maximum size of a
% thread block on the CUDA platform is 512. Many GPUs are capable of
% running many thread bocks simultaneously on the many multiprocessors
% available. To run more threads you need to set the grid size to launch
% the kernel over. This is a 1 or 2 element vector (you would use a 2
% element vector if you wanted a 2D grid referenced by |blockIdx.x| and
% |blockIdx.y| in the kernel).
%
% Once again the kernel we are going to invoke will just add the inputs
% together, and once again the input size must exactly match the total
% number of threads.

% Create the CUDAKernel object
k = parallel.gpu.CUDAKernel(ptxFile, cuFile, 'usesGridsAndBlocks');
%%

% Set the common thread block size and the grid size.
k.ThreadBlockSize = 128;
k.GridSize        = 64;
% Total number of threads (which is the size of the array)
N = prod(k.ThreadBlockSize) * prod(k.GridSize);
%%

% Execute the kernel with the correct array size for the first input
o = feval(k, ones(1, N), 2);

% Did we get the expected output?
fprintf('Expected output size %d, got size %d\n', N ,numel(o));
fprintf('Is the output (o) all 3: %d\n', all(gather(o) == 3));

%% Using GPUArrays rather than MATLAB data with CUDAKernels
% All the above examples of calling kernels have used MATLAB data directly.
% To correctly pass the this data to the kernel we have had to take the
% inputs and copy them down to the GPU before calling kernel. Then after
% the kernel is complete we have retrieved the data from the card and made
% it into ordinary MATLAB numeric data. This copying of data to and from
% the GPU can be costly. 
%
% The |parallel.gpu.GPUArray| object is used to put data on the GPU and deal
% with this problem. In addition, where ever the |feval| method on a kernel
% expects a |vector| input (as opposed to a |scalar| input), the |GPUArray|
% object can be used to pass the data already on the card to the kernel.
%
% Unlike MATLAB data the numeric type of the |GPUArray| must exactly match
% that expected by the kernel as we do not have the opportunity to coerce
% it to the correct type.
%
% We are going to use the |usesGridsAndBlocks| kernel again to show how
% |GPUArray| interacts with a kernel.

% Create the CUDAKernel object
k = parallel.gpu.CUDAKernel(ptxFile, cuFile, 'usesGridsAndBlocks');
% Set the common thread block size and the grid size.
k.ThreadBlockSize = 128;
k.GridSize        = 64;
% Total number of threads (which is the size of the array)
N = prod(k.ThreadBlockSize) * prod(k.GridSize);
%%

% Put the data on the card - note that we expressly make single data here
% as we know that the kernel expects floats
d = parallel.gpu.GPUArray(ones(1, N, 'single'))
%%

% Execute the kernel with the GPUArray as the first input
o = feval(k, d, 2)
%%
% We can use the |gather| method of |GPUArray| to get the results back from
% the GPU into MATLAB. Given the above computation, we should show that all
% the values in |d == 1| and |o == 3|


fprintf('Are all values in d 1: %d\n', all(gather(d) == 1));
fprintf('Are all values in o 3: %d\n', all(gather(o) == 3));

%% Run the includeArraySize example
% One of the drawbacks with all the previous examples is that the size of
% the input array has always had to be the same as the total number of
% threads. Since the total number of threads is the product of the
% |ThreadBlockSize| and |GridSize| of the kernel, this cannot be an
% arbitrary number. 
%
% The usual way around this problem is to pass the actual size of the array
% into the kernel as another parameter, and to branch in the kernel if this
% thread does not have any work to do. Then simply by making the number of
% threads greater than the number of array elements all elements of the
% array are operated on safely.
%
% See the |includeArraySize| kernel for an implementation of this. The
% example simply extends the |usesGridsAndBlocks| example to include the
% overall array size as an input to the kernel.


% Create the CUDAKernel object
k = parallel.gpu.CUDAKernel(ptxFile, cuFile, 'includeArraySize');
%%


% Array size can be up to 128*64 = 8192
k.ThreadBlockSize = 128;
k.GridSize        = 64;
% Actually make the array smaller at 7000
N = 7000;
%%

% Don't forget to pass in the array size as the third argument
o = feval(k, ones(1, N), 2, N);

fprintf('Expected output size %d, got size %d\n', N ,numel(o));
fprintf('Is the output (o) all 3: %d\n', all(gather(o) == 3));

%%

%#ok<*NOPTS,*NASGU> m-lint off lack of ';' and ununsed arg
