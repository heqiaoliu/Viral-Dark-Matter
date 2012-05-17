function out = erf( in )
%ERF Error function of GPUArray
%   Y = ERF(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray.ones(N);
%       E = erf(D)
%   
%   See also ERFC, ERFINV, ERFCINV,  PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/ONES.
%   
%   


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/06/10 14:27:43 $

out = pElementwiseUnaryOp( 'erf', in );
