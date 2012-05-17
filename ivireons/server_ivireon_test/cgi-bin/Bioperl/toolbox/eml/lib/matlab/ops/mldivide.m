function Y = mldivide(A,B)
%Embedded MATLAB Library Function

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml
eml.allowpcode('plain');
eml_assert(nargin >= 2, 'Not enough input arguments.');
if eml_is_const(isscalar(A)) && isscalar(A)
    Y = B ./ A;
    return
end
eml_assert(isa(A,'float'), ...
    ['Operation ''mldivide'' is not defined for values of class ''' class(A) '''.']);
eml_assert(isa(B,'float'), ...
    ['Operation ''mldivide'' is not defined for values of class ''' class(B) '''.']);
eml_lib_assert(size(B,1) == size(A,1), ...
    'MATLAB:dimagree', ...
    'Matrix dimensions must agree.');
eml_lib_assert(ndims(A) == 2 && ndims(B) == 2, ...
    'MATLAB:mldivide:inputsMustBe2D', ...
    'Input arguments must be 2-D.');
if isempty(A) || isempty(B)
    Y = eml_expand(eml_scalar_eg(A,B),[size(A,2),size(B,2)]);
elseif size(A,1) == size(A,2)
    Y = eml_lusolve(A,B);
else
    Y = eml_qrsolve(A,B);
end

%--------------------------------------------------------------------------
