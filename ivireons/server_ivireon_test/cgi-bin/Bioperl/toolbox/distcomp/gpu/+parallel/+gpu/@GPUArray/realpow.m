function out = realpow( in1, in2 )
%REALPOW Real power of GPUArray
%   Z = REALPOW(X,Y)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = -8*GPUArray.ones(N)
%       try realpow(D,1/3), catch, disp('complex output!'), end
%       E = realpow(-D,1/3)
%   
%   See also REALPOW, PARALLEL.GPU.GPUARRAY.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:09:44 $

error( nargchk( 2, 2, nargin, 'struct' ) );
out = pElementwiseBinaryOp( 'realpow', in1, in2 );
