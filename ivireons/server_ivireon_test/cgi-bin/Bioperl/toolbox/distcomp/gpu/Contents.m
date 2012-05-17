% Parallel Computing Toolbox
% Version 5.0 (R2010b) 03-Aug-2010
% 
% There are several options available for using your computer's graphics 
% processing unit (GPU) for matrix operations. 
% 
%     - Transfer data between the MATLAB workspace and the GPU
%     - Evaluate individual MATLAB functions that have been 
%       overloaded for execution on the GPU  
%     - Execute MATLAB code containing multiple functions using ARRAYFUN. 
%       (Not all MATLAB functions are supported.)
%     - Create kernels from CU files for execution on the GPU
%
% The GPU Computing section of the Parallel Computing Toolbox User's Guide 
% provides more information on these use cases and lists supported devices 
% and device drivers.
%
% Data Transfer Operations
%     gpuArray - Transfer an array from the MATLAB workspace to the GPU
%     gather   - Transfer an array from the GPU to the MATLAB workspace
%
% MATLAB Overloads
%
%     All of the MATLAB functions that have been made available for 
%     execution on the GPU can be viewed using the command 
%
%         methods('parallel.gpu.GPUArray')
%
%     Examples: 
%         % FFT
%         A = gpuArray( rand( 2^16, 100 ) );
%         F = fft(A) 
%
%         % MLDIVIDE
%         A = gpuArray( rand(1024) ); B = gpuArray( rand(1024,1) );
%         X = A\B
%
%         % MTIMES
%         A = gpuArray( rand(1024) ); B = gpuArray( rand(1024) );
%         C = A*B
%
% Execute MATLAB code on the GPU 
%     parallel.gpu.GPUArray/arrayfun - Apply a function to each element of 
%                                      an array on the GPU
%
%     The function to evaluate on the GPU must exist on the path.  Only a 
%     subset of the MATLAB language is supported by ARRAYFUN on the GPU. 
%     The restrictions are listed in the User's Guide.
%
%     Example:
%         % The file xycrull.m is one example of an existing MATLAB file
%         % that can be automatically executed on the GPU.
%         %
%         % Execute 'type xycrull' at the MATLAB prompt to view the contents 
%         % of the file.
%         %
%         gt = gpuArray(rand(400));
%         [o1, o2] = arrayfun(@xycrull, gt)     
%
% CUDA Kernel Operations
%     parallel.gpu.CUDAKernel       - Create a kernel object that corresponds 
%                                     to a particular kernel in a CU file
%     parallel.gpu.CUDAKernel/feval - Evaluate a kernel on the GPU
%       
% Device Information
%     gpuDeviceCount - Return the number of GPU devices available
%     gpuDevice      - Query or select a GPU device
 
% Copyright 2010-2010 The MathWorks, Inc. 
% Generated from Contents.m_template revision 1.1.6.1  $Date: 2010/06/10 14:24:35 $
