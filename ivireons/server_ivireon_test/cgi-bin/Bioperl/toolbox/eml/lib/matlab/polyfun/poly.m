function c = poly(x)
%Embedded MATLAB Library Function

%   Limitations:
%   1. This version does not discard non-finite x-values.
%   2. Complex input always results in complex output.

%   Copyright 1984-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(isa(x,'float'), ...
    ['Function ''poly'' is not defined for values of class ''' class(x) '''.']);
if eml_is_const(isvector(x)) && isvector(x)
    c = vector_poly(x);
else
    eml_assert(eml_ndims(x) == 2, 'Input must be 2D.');
    eml_lib_assert(isscalar(x) || ~isvector(x), ...
        'EmbeddedMATLAB:poly:vsizeMatrixIsVector', ...
        ['A variable-size matrix input to POLY must not become a ', ...
        'vector input at runtime. Use a variable-length vector instead.']);
    eml_lib_assert(size(x,1) == size(x,2), ...
        'MATLAB:poly:InputSize', ...
        'Argument must be a vector or a square matrix.');
    % Characteristic polynomial (square x)
    c = vector_poly(eig(x));
end

%--------------------------------------------------------------------------

function c = vector_poly(x)
% POLY for the vector input case.
n = cast(eml_numel(x),eml_index_class);
for j = 1:n
    if ~isfinite(x(j))
        eml_error('EmbeddedMATLAB:nonfiniteValuesNotSupported', ...
            'X must not contain Infs or NaNs.');
    end
end
c = eml.nullcopy(eml_expand(eml_scalar_eg(x),[1,n+1]));
c(1) = 1;
for j = 1:n
    c(j+1) = -x(j)*c(j);
    for k = j:-1:2
        c(k) = c(k) - x(j)*c(k-1);
    end
end

%--------------------------------------------------------------------------