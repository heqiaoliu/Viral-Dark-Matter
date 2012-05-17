function X = pinv(A,tol)
%Embedded MATLAB Library function.

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(isa(A,'float'), ...
    ['Function ''pinv'' is not defined for values of class ''' class(A) '''.']);
eml_lib_assert(ndims(A) == 2, 'EmbeddedMATLAB:pinv:inputMustBe2D', ...
    'Input matrix must be 2D.');
eml_assert(nargin < 2 || (isa(tol,'float') && isscalar(tol)), ...
    'TOL must be a scalar float.');
if nargin < 2
    if size(A,1) < size(A,2)
        X = eml_pinv(A')';
    else
        X = eml_pinv(A);
    end
else
    if size(A,1) < size(A,2)
        X = eml_pinv(A',tol)';
    else
        X = eml_pinv(A,tol);
    end
end

%--------------------------------------------------------------------------

function X = eml_pinv(A,tol)
m = cast(size(A,1),eml_index_class);
n = cast(size(A,2),eml_index_class);
AZERO = eml_scalar_eg(A);
X = eml_expand(AZERO,[n,m]);
if isempty(A)
    return
end
[U,S,V] = svd(A,'econ');
% U is m x n
% S is n x n
% V is n x n
if nargin < 2
    % Since SVD always sorts the singular values descending, the maximum
    % singular value is always S(1,1).
    tol = double(m) * S(1,1) * eps(class(A));
end
% Compute r = sum(s > tol) without forming s.
r = zeros(eml_index_class);
for k = 1:n
    if ~(S(k,k) > tol)
        break
    end
    r = eml_index_plus(r,1);
end
if r > 0
    % Do matrix multiplication:
    % s = diag(ones(r,1)./s(1:r));
    % X = V(:,1:r)*s*U(:,1:r)';
    ONE = ones(eml_index_class);
    vcol = ONE;
    for j = 1:r
        V = eml_xscal(n,eml_div(1,S(j,j)),V,vcol,ONE);
        vcol = eml_index_plus(vcol,n);
    end
    X = eml_xgemm('N','C',n,m,r,1+AZERO,V,ONE,n,U,ONE,m,AZERO,X,ONE,n);
end

%--------------------------------------------------------------------------
