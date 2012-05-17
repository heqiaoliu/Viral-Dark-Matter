function [X,rc] = eml_lusolve(A,B,nowarn)
%Embedded MATLAB Private Function

%   Solve square A*X = B via LU decomposition.
%   A is assumed to be square and non-empty.

%   Copyright 2005-2009 The MathWorks, Inc.
%#eml

if nargin < 3
    nowarn = false;
end
n = cast(size(A,2),eml_index_class);
if n > 3 || ~eml_is_const(size(A)) || ~eml_is_const(size(B))
    if nargout == 2
        [X,rc] = lusolveNxN(A,B,nowarn);
    else
        X = lusolveNxN(A,B,nowarn);
    end
elseif n == 3
    if nargout == 2
        [X,rc] = lusolve3x3(A,B,nowarn);
    else
        X = lusolve3x3(A,B,nowarn);
    end
elseif n == 2
    if nargout == 2
        [X,rc] = lusolve2x2(A,B,nowarn);
    else    
        X = lusolve2x2(A,B,nowarn);
    end
else
    X = rdivide(B,A);
    if nargout == 2
        if any(isnan(A))
            rc = eml_guarded_nan(class(A));
        elseif any(isinf(A))
            rc = zeros(class(A));
        else
            rc = ones(class(A));
        end
    end
end

%--------------------------------------------------------------------------

function warn_singular
eml_warning('MATLAB:singularMatrix', ...
    'Matrix is singular to working precision.');

%--------------------------------------------------------------------------

function [X,rc] = lusolveNxN(A,B,nowarn)
% General LU-solve of AX = B using BLAS functions.
eml_must_inline;
ONE = ones(eml_index_class);
if nargout == 2
    oneNormA = norm(A,1);
end
n = cast(size(A,2),eml_index_class);
[A,ipiv,info] = eml_xgetrf(n,n,A,ONE,n);
if ~nowarn && info > 0
    warn_singular;
end
CZERO = eml_scalar_eg(A,B);
CONE = CZERO + 1;
X = B + CZERO;
nb = cast(size(B,2),eml_index_class);
% Do the ipiv swaps.
for i = 1:n
    if ipiv(i) ~= i
        ip = ipiv(i);
        for j = 1:nb
            temp = X(i,j);
            X(i,j) = X(ip,j);
            X(ip,j) = temp;
        end
    end
end
% inv(L)*X --> X
X = eml_xtrsm('L','L','N','U',n,nb,CONE,A,ONE,n,X,ONE,n);
% inv(U)*X --> X
X = eml_xtrsm('L','U','N','N',n,nb,CONE,A,ONE,n,X,ONE,n);
if nargout == 2
    % TODO: avoid refactoring.
    rc = eml_rcond(A,oneNormA);
end

%--------------------------------------------------------------------------

function [X,rc] = lusolve2x2(A,B,nowarn)
% Same algorithm as general case but optimized for 2x2 A.
% This routine also treats A and B as read-only.
eml_must_inline;
ONE = ones(eml_index_class);
TWO = cast(2,eml_index_class);
nb = cast(size(B,2),eml_index_class);
if eml_xcabs1(A(2,1)) > eml_xcabs1(A(1,1))
    r1 = TWO;
    r2 = ONE;
else
    r1 = ONE;
    r2 = TWO;
end
a21 = eml_div(A(r2,1),A(r1,1));
a22 = A(r2,2) - a21*A(r1,2);
if ~nowarn && (a22 == 0 || A(r1,1) == 0)
    warn_singular;
end
X = eml.nullcopy(eml_expand(eml_scalar_eg(A,B),size(B)));
for k = 1:nb
    X(2,k) = eml_div(B(r2,k)-B(r1,k)*a21,a22);
    X(1,k) = eml_div(B(r1,k)-X(2,k)*A(r1,2),A(r1,1));
end
if nargout == 2
    d = abs(A(1,1)*A(2,2) - A(2,1)*A(1,2));
    absA11 = abs(A(1,1));
    absA21 = abs(A(2,1));
    absA12 = abs(A(1,2));
    absA22 = abs(A(2,2));
    mx1 = max(absA11+absA21,absA12+absA22);
    mx2 = max(absA11+absA12,absA21+absA22);
    rc = d / (mx1*mx2);
end

%--------------------------------------------------------------------------

function [X,rc] = lusolve3x3(A,B,nowarn)
% Same algorithm as general case but optimized for 3x3 A.
eml_must_inline;
if nargout == 2
    oneNormA = norm(A,1);
end
nb = cast(size(B,2),eml_index_class);
ONE = ones(eml_index_class);
TWO = cast(2,eml_index_class);
THREE = cast(3,eml_index_class);
% These are the row indices.  We won't actually need to swap rows for
% partial pivoting.
r1 = ONE;
r2 = TWO;
r3 = THREE;
% Row r1 has the maximum element of the first column.
maxval = eml_xcabs1(A(1,1));
a21 = eml_xcabs1(A(2,1));
if a21 > maxval
    maxval = a21;
    r1 = TWO;
    r2 = ONE;
end
if eml_xcabs1(A(3,1)) > maxval
    r1 = THREE;
    r2 = TWO;
    r3 = ONE;
end
% Divide lower triangular part of column by max.
A(r2,1) = eml_div(A(r2,1),A(r1,1));
A(r3,1) = eml_div(A(r3,1),A(r1,1));
% Subtract multiple of column 1 from columns 2 and 3.
A(r2,2) = A(r2,2) - A(r2,1)*A(r1,2);
A(r3,2) = A(r3,2) - A(r3,1)*A(r1,2);
A(r2,3) = A(r2,3) - A(r2,1)*A(r1,3);
A(r3,3) = A(r3,3) - A(r3,1)*A(r1,3);
% Swap rows 2 and 3 if indicated.
if eml_xcabs1(A(r3,2)) > eml_xcabs1(A(r2,2))
    rtemp = r2;
    r2 = r3;
    r3 = rtemp;
end
% Divide lower triangular part of column 2 by max.
A(r3,2) = eml_div(A(r3,2),A(r2,2));
% Subtract multiple of column 2 from column 3.
A(r3,3) = A(r3,3) - A(r3,2)*A(r2,3);
% Warn if singular.
if ~nowarn && (A(r1,1) == 0 || A(r2,2) == 0 || A(r3,3) == 0)
    warn_singular;
end
% Use the LU decomposition to solve the systems.
X = eml.nullcopy(eml_expand(eml_scalar_eg(A,B),size(B)));
for k = ONE:nb
    % Solve L*T = B,
    X(1,k) = B(r1,k);
    X(2,k) = B(r2,k) - X(1,k)*A(r2,1);
    X(3,k) = B(r3,k) - X(1,k)*A(r3,1) - X(2,k)*A(r3,2);
    % Solve U*X = T;
    X(3,k) = eml_div(X(3,k),A(r3,3));
    X(1,k) = X(1,k) - X(3,k)*A(r1,3);
    X(2,k) = X(2,k) - X(3,k)*A(r2,3);
    X(2,k) = eml_div(X(2,k),A(r2,2));
    X(1,k) = X(1,k) - X(2,k)*A(r1,2);
    X(1,k) = eml_div(X(1,k),A(r1,1));
end
if nargout == 2
    rc = eml_rcond(A,oneNormA);
end

%--------------------------------------------------------------------------
