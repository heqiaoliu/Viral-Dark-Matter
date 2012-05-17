function varargout = max( varargin )
%MAX elementwise maximum value of GPUArrays
%   M = MAX(X,Y) returns a GPUArray the same size as X and Y 
%   with the largest elements taken from X or Y. Either one 
%   can be a scalar.
%   
%   Example:
%   import parallel.gpu.GPUArray
%       X = GPUArray.colon(1,1000)
%       M = max(X,500);
%   
%   See also MAX, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/COLON


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/06/10 14:28:11 $

try
    [varargout{1:nargout}] = pMinMaxTemplate( 'max', varargin{:} );
catch E
    throw( E );
end
