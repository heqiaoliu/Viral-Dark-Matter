%FEVAL Evaluate kernel on GPU
%   feval(KERN, x1, ..., xn) evaluates the kernel KERN with the given
%   arguments x1, ..., xn.  The number of input arguments, n, must equal
%   the value of the NumRHSArguments property of KERN, and the types of the
%   input arguments x1, ..., xn must match the description in the
%   ArgumentTypes property of KERN.  The input data can be regular MATLAB
%   arrays, GPU arrays, or a mixture of the two.
%
%   [y1, ..., ym] = feval(KERN, x1, ..., xn) returns multiple output arguments
%   from the evaluation of the kernel. Each output argument corresponds to the
%   value of the non-const pointer inputs to the CUDA kernel after it has
%   executed.  Each output argument is a GPUArray.  The number of output
%   arguments, m, must not exceed the value of the MaxNumLHSArguments property
%   of KERN.
%
%   Example:
%   If the CUDA kernel within a CU file has the following signature:
%     void myKernel(const float * pIn, float * pInOut1, float * pInOut2)
% 
%   The corresponding kernel object in MATLAB then has the properties:
%     MaxNumLHSArguments: 2
%        NumRHSArguments: 3
%          ArgumentTypes: {'in single vector'  'inout single vector'  ...
%                          'inout single vector'}
%
%   You can use feval on this code's kernel (KERN) with the syntax:
%          [y1, y2] = feval(KERN, x1, x2, x3)
% 
%   The three input arguments, x1, x2, and x3, correspond to the three
%   arguments that are passed into the CUDA function. The output arguments,
%   y1 and y2, correspond to the values of pInOut1 and pInOut2 after the
%   CUDA kernel has executed.
%
%   See also parallel.gpu.CUDAKernel, parallel.gpu.GPUArray.

% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.6.1.4.1 $   $Date: 2010/06/10 14:24:43 $
