function [L,U,P] = lu(A,opt)
%Embedded MATLAB Library Function

%   Copyright 2002-2008 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(isa(A,'float'), ...
    ['Function ''lu'' is not defined for values of class ''' class(A) '''.']);
eml_lib_assert(ndims(A) == 2, 'EmbeddedMATLAB:lu:inputMustBe2D', ...
    'Matrix must be 2-D.');
eml_assert(nargin == 1 || ...
    (ischar(opt) && (strcmp(opt,'vector') || strcmp(opt,'matrix'))), ...
    'Second argument must be ''vector'' or ''matrix''');
ONE = ones(eml_index_class);
m = cast(size(A,1),eml_index_class);
n = cast(size(A,2),eml_index_class);
if nargout <= 1
    L = eml_xgetrf(m,n,A,ONE,m);
    return
elseif nargout == 2
    [A,ipiv] = eml_xgetrf(m,n,A,ONE,m);
    [L,U] = expandlu(A,eml_ipiv2perm(ipiv,m));
    return
end
if nargin == 2 && strcmp(opt,'vector')
    [A,ipiv] = eml_xgetrf(m,n,A,ONE,m);
    P = double(eml_ipiv2perm(ipiv,m));
    [L,U] = expandlu(A);
else
    [A,ipiv] = eml_xgetrf(m,n,A,ONE,m);
    [L,U,P] = expandlu(A,eml_ipiv2perm(ipiv,m));
end

%--------------------------------------------------------------------------

function [L,U,P] = expandlu(X,pivot)
% Form L, U, and possibly P matrices.  If pivot is supplied and nargout<3, 
% the pivot vector is applied to L. Otherwise, P is the corresponding 
% permutation matrix.
m = size(X,1);
n = size(X,2);
mn = min(m,n);
L = eml_expand(eml_scalar_eg(X),[m,mn]);
U = eml_expand(eml_scalar_eg(X),[mn,n]);
% Extract the upper triangular matrix U.
for j = 1:mn
    for i = 1:j
        U(i,j) = X(i,j);
    end
end
for j = mn+1:n
    for i = 1:mn
        U(i,j) = X(i,j);
    end
end
if nargin == 2 && nargout < 3
    % Form the lower triangular matrix L and apply the pivot vector.
    for j = 1:mn
        L(pivot(j),j) = 1;
        for i = j+1:m
            L(pivot(i),j) = X(i,j);
        end
    end
else
    % Extract the lower triangular matrix L.
    for j = 1:mn
        L(j,j) = 1;
        for i = j+1:m
            L(i,j) = X(i,j);
        end
    end
    % Form the permutation matrix P if required.
    if nargout == 3
        P = zeros(m,class(X));
        if nargin == 2
            for j = 1:m
                P(j,pivot(j)) = 1;
            end
        else
            for j = 1:m
                P(j,j) = 1;
            end
        end
    end
end
        
%--------------------------------------------------------------------------
