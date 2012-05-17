%% Running MATLAB(R) Functions on the GPU
% The method |arrayfun| allows you to run a MATLAB(R) function file
% natively on the GPU. The MATLAB file must contain a single function and
% must contain only scalar operations and arithmetic.

% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/06/21 17:56:06 $

%% Using Horner's Rule to Calculate Exponentials
% Horner's rule allows the efficient evaluation of power series expansions.
% We will use it to calculate the first 10 terms of the power series
% expansion for the exponential function |exp|. We can implement this as a
% MATLAB function.

type pctdemo_aux_gpuhorner

%% Preparing |gpuhorner| for the GPU
% To run this function on the GPU, we use a handle to the
% |pctdemo_aux_gpuhorner| function, which we can evaluate using |arrayfun|.
% We can pass in |GPUArray| objects or standard MATLAB arrays. |gpuhorner|
% automatically adapts to different size and type inputs. We can compare
% the results computed on the GPU with standard MATLAB execution simply by
% evaluating the function directly.

gpuhorner = @pctdemo_aux_gpuhorner;

%% Create the Input Data
% We create some inputs of different types and sizes, and use |gpuArray| to
% send them to the GPU.

data1  = rand( 2000, 'single' );
data2  = rand( 1000, 'double' );
gdata1 = gpuArray( data1 );
gdata2 = gpuArray( data2 );

%% Evaluate |gpuhorner| on the GPU
% To evaluate the |gpuhorner|, we simply call |arrayfun|, using the same
% calling convention as the original MATLAB function. We can compare the
% results by evaluating the original function directly in MATLAB. We expect
% some slight numerical differences because the floating-point arithmetic
% on the GPU does not precisely match the arithmetic performed on the CPU.

gresult1 = arrayfun( gpuhorner, gdata1 );
gresult2 = arrayfun( gpuhorner, gdata2 );

comparesingle = max( max( abs( gather( gresult1 ) - ...
                               pctdemo_aux_gpuhorner( data1 ) ) ) )
comparedouble = max( max( abs( gather( gresult2 ) - ...
                               pctdemo_aux_gpuhorner( data2 ) ) ) )

%% Comparing Performance between GPU and CPU
% We can compare the performance of the GPU version to the native MATLAB
% version. Current generation GPUs have much better performance in single
% precision, so we will compare that.

tic, gresult1 = arrayfun( gpuhorner, gdata1 ); tgpu = toc;
tic, result1  = gpuhorner( data1 );            tcpu = toc;
speedup = tcpu / tgpu

displayEndOfDemoMessage(mfilename)
