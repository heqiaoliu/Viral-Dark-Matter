function X = mrdivide(A, B)
%/ Slash or right matrix divide for GPUArray
%   C = A / B
%   C = MRDIVIDE(A,B)
%   
%   B must be scalar.
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D1 = GPUArray.colon(1, N)'
%       D2 = D1 / 2
%   
%   See also MRDIVIDE, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/COLON, PARALLEL.GPU.GPUARRAY/ZEROS.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/06/10 14:28:14 $

error(nargchk(2,2,nargin,'struct'));

if isscalar(B)
    try
        X = rdivide(A, B);
        return;
    catch E
        throw(E);
    end
else   
    error('parallel:gpu:mrdivide:nonscalarB', ...
          'The second input argument must be scalar.')    
end
