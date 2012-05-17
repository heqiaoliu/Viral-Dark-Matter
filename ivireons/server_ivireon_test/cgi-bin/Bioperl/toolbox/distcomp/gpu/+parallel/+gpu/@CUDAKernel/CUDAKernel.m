%CUDAKernel GPU CUDAKernel object
%   KERN = parallel.gpu.CUDAKernel(PTXFILE, CPROTO) and
%   KERN = parallel.gpu.CUDAKernel(PTXFILE, CPROTO, FUNC) return a kernel object
%   that you can use to call a CUDA kernel on the GPU.  PTXFILE is the name of
%   the file that contains the PTX code, and CPROTO is the C prototype for the
%   kernel call that KERN represents.  If specified, FUNC must be a string that
%   unambiguously defines the appropriate kernel entry name in the PTX file.  If
%   FUNC is omitted, the PTX file must contain only a single entry point.
%
%   KERN = parallel.gpu.CUDAKernel(PTXFILE, CUFILE) and
%   KERN = parallel.gpu.CUDAKernel(PTXFILE, CUFILE, FUNC) read the CUDA source
%   file CUFILE, and look for a kernel definition starting with '__global__' to
%   find the function prototype for the CUDA kernel that is defined in PTXFILE.
%
%   Example:
%   If simpleEx.cu contains the following:
%     /*
%     * Add a constant to a vector.
%     */
%     __global__ void addToVector(float * pi, float c, int vecLen)  {
%        int idx = blockIdx.x * blockDim.x + threadIdx.x;
%        if ( idx < vecLen ) {
%            pi[idx] += c;
%     }
%   and simpleEx.ptx contains the PTX resulting from compiling simpleEx.cu
%   into PTX, both of the following return a kernel object that you can use
%   to call the addToVector CUDA kernel.
%
%   kern = parallel.gpu.CUDAKernel('simpleEx.ptx', 'simpleEx.cu');
%   kern = parallel.gpu.CUDAKernel('simpleEx.ptx', ...
%                                    'float *, float, int');
%
%   See also parallel.gpu.CUDAKernel, parallel.gpu.CUDAKernel.feval.

% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.6.1.2.1 $   $Date: 2010/07/01 20:42:29 $

%{
properties
    % ThreadBlockSize - Size of block of threads on the kernel
    %    The ThreadBlockSize can be an integer vector of length 1, 2 or 3 
    %    (since thread blocks can be up to 3-dimensional). 
    ThreadBlockSize;
    
    % MaxThreadsPerBlock - Maximum number of threads in a block
    %    This is the maximum number of threads permissible in a single block for
    %    this CUDAKernel. The product of the elements of ThreadBlockSize must
    %    not exceed this value.
    MaxThreadsPerBlock;

    % GridSize - Size of grid 
    %    The GridSize is effectively the number of thread blocks that will be
    %    launched independently by the GPU. This is an integer vector of
    %    length 1 or 2. 
    GridSize;

    % SharedMemorySize - Amount of dynamic shared memory for thread blocks
    %    The SharedMemorySize specifies the amount of dynamic shared memory in
    %    bytes that is available to each thread block.
    SharedMemorySize

    % EntryPoint - Entry point in PTX code for this kernel
    %    The EntryPoint is a string containing the actual entry point name in 
    %    the PTX code that this kernel is going to call.
    EntryPoint;

    % MaxNumLHSArguments - Maximum number of left hand side arguments 
    %    The maximum number of left hand side arguments that this kernel
    %    supports in its feval method.  
    MaxNumLHSArguments;

    % NumRHSArguments - Required number of right hand side arguments to kernel
    %    The required number of right hand side arguments needed to call this
    %    kernel through the feval method.
    NumRHSArguments;

    % ArgumentTypes - Description of input arguments to kernel
    %    Cell array of strings describing the input arguments required when
    %    evaluating this kernel.  Each string indicates the expected MATLAB
    %    type for that input is (a numeric type such as uint8, single, or
    %    double followed by the word scalar or vector). In addition, if that
    %    argument is only an input to the kernel, it is prefixed by in; and if
    %    it is an input/output, it is prefixed by inout. 
    ArgumentTypes;
end
%}
