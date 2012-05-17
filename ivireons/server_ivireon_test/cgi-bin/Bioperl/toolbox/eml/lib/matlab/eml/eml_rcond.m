function  result = eml_rcond(A,normA)
%Embedded MATLAB Library Function

%   RCOND with optional factorization.  If nargin == 2, the input A is
%   assumed to be the output of xGETRF, a combined LU matrix, and the input
%   normA is assumed to be the 1-norm of the original matrix A.
%
%   We assume that the input A is 2-D and square.

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml

eml_assert(isa(A,'float'), 'Inputs must be single or double.');
n = cast(size(A,1),eml_index_class);
ONE = ones(eml_index_class);
result = zeros(class(A));
if n == 0
    return
elseif n == 1
    absA = abs(A(1));
    if isinf(absA) && isreal(A)
    elseif ~isfinite(absA)
        result = eml_guarded_nan(class(A));
    elseif absA ~= 0
        result = ones(class(A));
    end
    return
end
if nargin == 1
    normA = norm(A,1);
end
if normA == 0
    return
end
if nargin == 1
    A = eml_xgetrf(n,n,A,ONE,n);
end
for k = n:-1:1
    if A(k,k) == 0
        return
    end
end
ainvnm = zeros(class(A));
itermax = 5;
iter = 2;
kase = 1;
jump = 1;
j = 1;
x = eml_expand(eml_scalar_eg(A)+eml_rdivide(1,double(n)),[n,1]);
while kase ~= 0
    if kase == 1 % no transpose
        x = eml_xtrsv('L','N','U',n,A,ONE,n,x,ONE,ONE);
        % x = L\x; Lower Triangular, No Transpose, Unit Diagonal
        x = eml_xtrsv('U','N','N',n,A,ONE,n,x,ONE,ONE);
        % x = U\x; Upper Triangular, No Transpose, Non-Unit Diagonal
    else % conjugate-transpose
        x = eml_xtrsv('U','C','N',n,A,ONE,n,x,ONE,ONE);
        % x = (U')\x; Upper Triangular, Conjugate Transpose, Non-Unit Diagonal
        x = eml_xtrsv('L','C','U',n,A,ONE,n,x,ONE,ONE);
        % x = (L')\x; Lower Triangular, Conjugate Transpose, Unit Diagonal
    end
    % Serves the role of zlacon() from LAPACK
    if jump == 1 % x has been over-written with A*x
        ainvnm = norm(x,1);
        if ~isfinite(ainvnm)
            result = ainvnm;
            return
        end
        x = make_sign_vector(x);
        kase = 2;
        jump = 2;
    elseif jump == 2 % x has been over-written with A^H * x (conjugate-transpose)
        j = izmax1(x);
        iter = 2;
        x(:) = 0;
        x(j) = 1;
        kase = 1;
        jump = 3;
    elseif jump == 3 % x has been over-written with A*x
        ainvnm = norm(x,1);
        if ainvnm <= x(1)
            x = make_altsign_vector(x);
            kase = 1;
            jump = 5;
        else
            x = make_sign_vector(x);
            kase = 2;
            jump = 4;
        end
    elseif jump == 4 % x has been over-written with A^H * x
        jlast = j;
        j = izmax1(x);
        if (abs(x(jlast)) ~= abs(x(j))) && (iter <= itermax)
            iter = iter + 1;
            x(:) = 0;
            x(j) = 1;
            kase = 1;
            jump = 3;
        else
            x = make_altsign_vector(x);
            kase = 1;
            jump = 5;
        end
    elseif jump == 5 % x has been over-written with A*x
        temp = eml_rdivide(eml_rdivide(2*norm(x,1),3),double(n));
        if temp > ainvnm
            ainvnm = temp;
        end
        kase = 0;
    end
end
if ainvnm ~= 0
    result = eml_rdivide(eml_rdivide(1,ainvnm),normA);
end

%--------------------------------------------------------------------------

function x = make_sign_vector(x)
eml_must_inline;
SAFMIN = realmin(class(x));
for k = 1:eml_numel(x)
    absxk = abs(x(k));
    if absxk > SAFMIN
        x(k) = eml_div(x(k),absxk);
    else
        x(k) = 1;
    end
end

%--------------------------------------------------------------------------

function x = make_altsign_vector(x)
eml_must_inline;
n = eml_numel(x);
altsgn = ones(class(x));
nm1 = cast(n-1,class(x));
for k = 1:n
    x(k) = altsgn*(1 + eml_rdivide(k-1,nm1));
    altsgn = -altsgn;
end

%--------------------------------------------------------------------------

function idx = izmax1(x)
% Computes max(abs(real(x)))
% Assumes that x is nonempty.
eml_must_inline;
idx = 1;
smax = abs(real(x(1)));
for k = 2:eml_numel(x)
    absrexk = abs(real(x(k)));
    if absrexk <= smax
    else
        idx = k;
        smax = absrexk;
    end
end

%--------------------------------------------------------------------------