function c = dot(a, b, dim)
%DOT Vector dot product of GPUArray
%   C = DOT(A,B)
%   C = DOT(A,B,DIM)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       d1 = GPUArray.colon(1,N);
%       d2 = GPUArray.ones(N,1);
%       d = dot(d1,d2)
%   
%   returns d = N*(N+1)/2.
%   
%   See also DOT, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/COLON, PARALLEL.GPU.GPUARRAY/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1.2.2 $  $Date: 2010/06/21 17:56:47 $

iVerifySupportedDataType(a);
iVerifySupportedDataType(b);
a = pGPU(a);
b = pGPU(b);

% Special case: A and B are vectors and dim not supplied.
if isvector(a) && isvector(b) && nargin<3
    % Ensure that a and b are either both column vectors or both row vectors.
    if iscolumn(a) ~= iscolumn(b)
        b = b.';
    end
    iVerifySizes(a, b);
    try
        if hIsFloat(a) && hIsFloat(b)
            c = hDot(a, b);
        else
            c = gather(sum(conj(a).*b));
        end
    catch E
        throw(E);
    end
  return;
end

iVerifySizes(a, b);
if nargin == 2
  c = sum(conj(a).*b);
else
  c = sum(conj(a).*b, dim);
end

end % End of dot.

function iVerifySizes(a, b)
% Verify that the sizes of a and b match
    if any(size(a) ~= size(b))
        err = MException('parallel:gpu:dot:InputSizeMismatch',  ...
                         'A and B must be same size.');
        throwAsCaller(err);
    end
end

function iVerifySupportedDataType(x)
% Throw error as caller if we don't support the class of x.
    if ~pIsSupportedForElementwise(x) || isequal(classUnderlying(x), 'logical')
        err = MException('parallel:gpu:dot:UnsupportedDataType', ...
                         'DOT is not supported for GPU arrays of %s.', ...
                         classUnderlying(x));
        throwAsCaller(err);
    end
end
