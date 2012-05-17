function y = inv(x)
%Embedded MATLAB Library Function

%   Limitations:  Not expected to return the same non-finite values as
%   MATLAB for singular matrix inputs.

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(isa(x,'float'), ...
    ['Function ''inv'' is not defined for values of class ''' class(x) '''.']);
eml_lib_assert(ndims(x) == 2 && size(x,1) == size(x,2), 'MATLAB:square', ...
    'Matrix must be square.');
if size(x,1) > 3 || ~eml_is_const(size(x))
    y = invNxN(x);
    checkcond(x,y);
elseif isscalar(x)
    y = eml_div(1,x);
    checkcond(x,y);
elseif size(x,1) == 2
    y = inv2x2(x);
    checkcond(x,y);
elseif size(x,1) == 3
    y = inv3x3(x);
    checkcond(x,y);
else % if isempty(x)
    y = x;
end

%--------------------------------------------------------------------------

function checkcond(x,xinv)
n1x = norm(x,1);
n1xinv = norm(xinv,1);
rc = eml_rdivide(1,n1x*n1xinv);
if n1x == 0 || n1xinv == 0 || rc == 0
    eml_warning('MATLAB:singularMatrix','Matrix is singular to working precision.');
elseif isnan(rc) || rc < eps(class(x))
    eml_warning('MATLAB:illConditionedMatrix', ...
        ['Matrix is singular, close to singular or badly scaled.\n'...
        '         Results may be inaccurate. RCOND = %e.'],rc);
end

%--------------------------------------------------------------------------

function x = inv2x2(x)
% Cramer's rule for the 2x2 case.
x11 = x(1,1);
d = x11*x(2,2) - x(2,1)*x(1,2);
x(1,1) = eml_div(x(2,2),d);
x(2,2) = eml_div(x11,d);
x(2,1) = eml_div(-x(2,1),d);
x(1,2) = eml_div(-x(1,2),d);

%--------------------------------------------------------------------------

function y = inv3x3(x)
% Unrolled code for 3x3 Case.
zero = cast(0,eml_index_class);
three = cast(3,eml_index_class);
six = cast(6,eml_index_class);
p1 = zero; % First column offset.
p2 = three; % Second column offset.
p3 = six; % Third column offset.
absx11 = abs(x(1,1));
absx21 = abs(x(2,1));
absx31 = abs(x(3,1));
if (absx21 > absx11) && (absx21 > absx31)
    % Swap rows 1 and 2.
    p1 = three;
    p2 = zero;
    t1 = x(1,1);
    x(1,1) = x(2,1);
    x(2,1) = t1;
    t1 = x(1,2);
    x(1,2) = x(2,2);
    x(2,2) = t1;
    t1 = x(1,3);
    x(1,3) = x(2,3);
    x(2,3) = t1;
elseif absx31 > absx11
    % Swap rows 1 and 3.
    p1 = six;
    p3 = zero;
    t1 = x(1,1);
    x(1,1) = x(3,1);
    x(3,1) = t1;
    t1 = x(1,2);
    x(1,2) = x(3,2);
    x(3,2) = t1;
    t1 = x(1,3);
    x(1,3) = x(3,3);
    x(3,3) = t1;
end
% First opportunity to compute save 1 / x(1,1).
x(2,1) = eml_div(x(2,1),x(1,1));
x(3,1) = eml_div(x(3,1),x(1,1));
x(2,2) = x(2,2) - x(2,1)*x(1,2);
x(3,2) = x(3,2) - x(3,1)*x(1,2);
x(2,3) = x(2,3) - x(2,1)*x(1,3);
x(3,3) = x(3,3) - x(3,1)*x(1,3);
if abs(x(3,2)) > abs(x(2,2))
    itmp = p2;
    p2 = p3;
    p3 = itmp;
    t1 = x(2,1);
    x(2,1) = x(3,1);
    x(3,1) = t1;
    t1 = x(2,2);
    x(2,2) = x(3,2);
    x(3,2) = t1;
    t1 = x(2,3);
    x(2,3) = x(3,3);
    x(3,3) = t1;
end
% First opportunity to compute and save 1 / x(2,2).
x(3,2) = eml_div(x(3,2),x(2,2));
x(3,3) = x(3,3) - x(3,2)*x(2,3);
% Several opportunities here to replace divisions with mults
% by saved reciprocal values of x(1,1), x(2,2), and x(3,3).
t3 = eml_div(x(3,2)*x(2,1) - x(3,1),x(3,3));
t2 = eml_div(-(x(2,1) + x(2,3)*t3),x(2,2));
y = eml.nullcopy(x);
y(eml_index_plus(p1,1)) = eml_div(1 - x(1,2)*t2 - x(1,3)*t3,x(1,1));
y(eml_index_plus(p1,2)) = t2;
y(eml_index_plus(p1,3)) = t3;
t3 = eml_div(-x(3,2),x(3,3));
t2 = eml_div(1 - x(2,3)*t3,x(2,2));
y(eml_index_plus(p2,1)) = eml_div(-(x(1,2)*t2 + x(1,3)*t3),x(1,1));
y(eml_index_plus(p2,2)) = t2;
y(eml_index_plus(p2,3)) = t3;
t3 = eml_div(1,x(3,3));
t2 = eml_div(-x(2,3)*t3,x(2,2));
y(eml_index_plus(p3,1)) = eml_div(-(x(1,2)*t2 + x(1,3)*t3),x(1,1));
y(eml_index_plus(p3,2)) = t2;
y(eml_index_plus(p3,3)) = t3;

%--------------------------------------------------------------------------

function y = invNxN(x)
% General case.
n = cast(size(x,1),eml_index_class);
% Allocate the inverse matrix.
y = eml.nullcopy(x);
y(:) = 0;
% LU decomposition.
ONE = ones(eml_index_class);
[x,ipiv] = eml_xgetrf(n,n,x,ONE,n);
p = eml_ipiv2perm(ipiv,n);
% Solve L*Y = eye(n).  This step takes advantage of the structure of
% eye(n), so we do not use xTRSM for this step.
for k = 1:n
    c = p(k);
    y(k,c) = 1;
    for j = k:n
        if y(j,c) ~= 0
            % Matlab idiom: y(j+1:n,c) = y(j+1:n,c) - y(j,c)*x(j+1:n,j);
            for i = eml_index_plus(j,1):n
                y(i,c) = y(i,c) - y(j,c)*x(i,j);
            end
        end
    end
end
% inv(U)*Y --> Y
y = eml_xtrsm('L','U','N','N',n,n,1+eml_scalar_eg(x),x,ONE,n,y,ONE,n);

%--------------------------------------------------------------------------
