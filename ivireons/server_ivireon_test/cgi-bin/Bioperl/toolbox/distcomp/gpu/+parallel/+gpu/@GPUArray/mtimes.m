function C = mtimes(A, B)
%* Matrix multiply for GPUArray
%   C = A * B
%   C = MTIMES(A,B)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       A = GPUArray(rand(N))
%       B = GPUArray(rand(N))
%       C = A * B
%   
%   See also MTIMES, PARALLEL.GPU.GPUARRAY.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1.2.1 $   $Date: 2010/06/10 14:28:15 $

error(nargchk(2,2,nargin,'struct'));

isScalarMult = isscalar(A) || isscalar(B);
if isScalarMult
    try
        C = times(A, B);
        return;
    catch E
        throw(E);
    end
end

isDotProduct = isvector(A) && isvector(B) ...
    && size(A, 1) == 1 && size(B, 2) == 1;
if isDotProduct 
    try
        % Note that the mtimes overload must always return GPUArray. 
        C = parallel.gpu.GPUArray(dot(A, B));
        return;
    catch E
        throw(E);
    end
end

% At this point, we should only be left with matrix-matrix, matrix-vector or
% vector-matrix multiplication.
C = iProperMatrixMultiplication(A, B);

end
function C = iProperMatrixMultiplication(A, B)
% Handles MTIMES for the case of non-scalar expansion and non-dot product.
% Throws all errors as the caller.

if ~(ndims(A) == 2 && ndims(B) == 2)
    ex = MException('parallel:gpu:mtimes:inputsMustBe2D', ...
                    'Both inputs must be 2-D matrices unless one input is a scalar.');
    throwAsCaller(ex);
end

if ~(iIsFloat(A) && iIsFloat(B))
    ex = MException('parallel:gpu:mtimes:OnlyFloatSupported', ...
                    ['Matrix multiplication is supported only for single and ' ...
                     'double matrices, or when one of the inputs is scalar.']);
    throwAsCaller(ex);
end

if size(A, 2) ~= size(B, 1)
    ex = MException('parallel:gpu:mtimes:IncompatibleDimensions',  ...
                    'Matrix dimensions must agree.');
    throwAsCaller(ex);
end

A = pGPU(A);
B = pGPU(B);

try
    C = hMtimes(A, B);
catch E
    throw(E);
end

end % End of iProperMatrixMultiplication.

function isflt = iIsFloat(x)
    [~, ~, isflt] = pObjProps(x);
end % End of iIsFloat.
