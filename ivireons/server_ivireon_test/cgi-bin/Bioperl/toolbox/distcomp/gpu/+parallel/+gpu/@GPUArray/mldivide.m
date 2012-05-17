function X = mldivide(A, B)
%\ Backslash or left matrix divide for GPUArrays
%   X = A \ B is the matrix division of A into B, where either A or B or both are
%   GPUArray.  This is roughly the same as INV(A)*B, except it is computed in a 
%   different way.  If A is an N-by-N matrix and B is a column vector with N
%   components, or a matrix with several such columns, then X = A\B is the 
%   solution to the equation A*X = B.  A\EYE(SIZE(A)) produces the inverse of A.
%   
%   X = MLDIVIDE(A,B) is called for the syntax A\B when A or B is an object.
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       A = GPUArray(rand(N));
%       B = GPUArray(rand(N,1));
%       X = A \ B
%   
%   See also MLDIVIDE, PARALLEL.GPU.GPUARRAY.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1.2.2 $  $Date: 2010/06/21 17:56:48 $

error(nargchk(2,2,nargin,'struct'));

if isscalar(A)
    try
        X = ldivide(A, B);
        return;
    catch E
        throw(E);
    end
end

if ~( ndims(A) == 2 && ndims(B) == 2 )
    error('parallel:gpu:mldivide:inputsMustBe2D',...
          'Input arguments must be 2-D matrices.');
end

if ~(iIsFloat(A) && iIsFloat(B))
    error('parallel:gpu:mldivide:OnlyFloatSupported', ...
          'MLDIVIDE is supported only for single and double inputs.');    
end


if ~(isreal(A) && isreal(B))
    error('parallel:gpu:mldivide:OnlyRealSupported', ...
          'MLDIVIDE is currently supported only for real inputs.');    
end

if size(A, 1) ~= size(B, 1)
    error('parallel:gpu:mldivide:IncompatibleDimensions',  ...
          'Matrix dimensions must agree.');
end

if size(A, 1) == size(A, 2) 
    % Make sure that both A and B are out on the card 
    A = pGPU(A);
    B = pGPU(B);
    
    try
        X = hMldivide(A, B);
    catch E
        throw(E);
    end
else
   error('parallel:gpu:mldivide:rectangularA', ...
         'First input argument must be a square matrix.');
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function isflt = iIsFloat(x)
    [~, ~, isflt] = pObjProps(x);
end % End of iIsFloat.
