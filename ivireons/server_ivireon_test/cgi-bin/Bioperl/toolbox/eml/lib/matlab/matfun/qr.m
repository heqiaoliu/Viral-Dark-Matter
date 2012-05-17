function [Q,R,E] = qr(A,econ)
%Embedded MATLAB Library Function

%   Copyright 2002-2010 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(nargin == 1 || (isa(econ,'numeric') && isscalar(econ)), ...
    'Use qr(X,0) for economy size decomposition.');
eml_assert(isa(A,'float'), ...
    ['Function ''qr'' is not defined for values of class ''' class(A) '''.']);
eml_lib_assert(ndims(A) == 2, 'EmbeddedMATLAB:qr:inputMustBe2D', ...
    'Argument A must be a 2-D matrix.');
eml_lib_assert(nargin == 1 || econ == 0, ...
    'MATLAB:qr:unknownOptionForEconomySizeDecomposition', ...
    'Use qr(X,0) for economy size decomposition.');
if nargout == 3
    if nargin == 1
        [Q,R,E] = qr_full(A);
    else
        [Q,R,E] = qr_econ(A);
    end
elseif nargout == 2
    if nargin == 1
        [Q,R] = qr_full(A);
    else
        [Q,R] = qr_econ(A);
    end
else
    Q = eml_xgeqrf(A);
end

%--------------------------------------------------------------------------

function [Q,R,E] = qr_full(A)
% Full QR with or without pivoting.
ONE = ones(eml_index_class);
eml_must_inline;
m = cast(size(A,1),eml_index_class);
n = cast(size(A,2),eml_index_class);
if ~eml_is_const(n)
    eml.varsize('Q','tau');
end
% Q is m x m, R is m x n
Q = eml.nullcopy(eml_expand(eml_scalar_eg(A),[m,m]));
R = eml.nullcopy(A);
if nargout == 3
    E = zeros(n,class(A));
end
if m > n
    % Q = [A,zeros(m,m-n)];
    for j = 1:n
        for i = 1:m
            Q(i,j) = A(i,j);
        end
    end
    for j = n+1:m
        for i = 1:m
            Q(i,j) = 0;
        end
    end
    if nargout == 3
        [Q,tau,jpvt] = eml_xgeqp3(Q);
    else
        [Q,tau] = eml_xgeqrf(Q);
    end
    for j = 1:n
        for i = 1:j
            R(i,j) = Q(i,j);
        end
        for i = eml_index_plus(j,1):m
            R(i,j) = 0;
        end
    end
    Q = eml_xungqr(m,m,n,Q,ONE,m,tau,ONE);
else
    if nargout == 3
        [A,tau,jpvt] = eml_xgeqp3(A);
    else
        [A,tau] = eml_xgeqrf(A);
    end
    for j = 1:m
        for i = 1:j
            R(i,j) = A(i,j);
        end
        for i = eml_index_plus(j,1):m
            R(i,j) = 0;
        end
    end
    for j = eml_index_plus(m,1):n
        for i = 1:m
            R(i,j) = A(i,j);
        end
    end
    A = eml_xungqr(m,m,m,A,ONE,m,tau,ONE);
    for j = 1:m
        for i = 1:m
            Q(i,j) = A(i,j);
        end
    end
end
if nargout == 3
    % Create a permutation matrix from jpvt.
    for k = 1:n
        E(jpvt(k),k) = 1;
    end
end

%--------------------------------------------------------------------------

function [Q,R,E] = qr_econ(A)
% Economy size QR with pivoting.
eml_must_inline;
ONE = ones(eml_index_class);
if nargout == 3
    [A,tau,jpvt] = eml_xgeqp3(A);
    E = double(jpvt);
else
    [A,tau] = eml_xgeqrf(A);
end
m = cast(size(A,1),eml_index_class);
n = cast(size(A,2),eml_index_class);
if m > n
    % Q is m x n, R is n x n
    R = eml.nullcopy(eml_expand(eml_scalar_eg(A),[n,n]));
    for j = 1:n
        for i = 1:j
            R(i,j) = A(i,j);
        end
        for i = eml_index_plus(j,1):n
            R(i,j) = 0;
        end
    end
    A = eml_xungqr(m,n,n,A,ONE,m,tau,ONE);
    Q = A;
else
    % Q is m x m, R is m x n
    R = eml.nullcopy(A);
    for j = 1:m
        for i = 1:j
            R(i,j) = A(i,j);
        end
        for i = eml_index_plus(j,1):m
            R(i,j) = 0;
        end
    end
    for j = eml_index_plus(m,1):n
        for i = 1:m
            R(i,j) = A(i,j);
        end
    end
    A = eml_xungqr(m,m,m,A,ONE,m,tau,ONE);
    Q = eml.nullcopy(eml_expand(eml_scalar_eg(A),[m,m]));
    for j = 1:m
        for i = 1:m
            Q(i,j) = A(i,j);
        end
    end
end

%--------------------------------------------------------------------------
