function [k,e] = ellipke(m,tol)
%Embedded MATLAB Library Function

%   Copyright 1984-2010 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0,'Not enough input arguments.');
eml_assert(isa(m,'float'),['Function ''ellipke'' is not defined for values of class ''' class(m) '''.']);
if nargin < 2
    tol = eps(class(m));
end
eml_assert(isa(tol,'float'),['Function ''ellipke'' is not defined for values of class ''' class(tol) '''.']);
eml_assert(isreal(m) && isreal(tol),'Input arguments must be real.');
eml_assert(eml_is_const(size(tol)) && isscalar(tol) && isfloat(tol), 'TOL must be a scalar float.');
if isempty(m)
    k = m;
    e = m;
    return
end
k = eml.nullcopy(m);
e = eml.nullcopy(m);
ONE = ones(class(m));
ZERO = zeros(class(m));
for j = 1:eml_numel(m)
    if m(j) == 1
        k(j) = eml_guarded_inf;
        e(j) = ONE;
    elseif m(j) < 0 || m(j) > 1
        eml_error('MATLAB:ellipke:MOutOfRange','M must be in the range 0 <= M <= 1.');
    else
        a0 = ONE;
        b0 = sqrt(1-m(j));
        s0 = m(j);
        i1 = ZERO; w1 = ONE; a1 = ONE;
        while w1 > tol
            a1 = eml_rdivide(a0+b0,2);
            b1 = sqrt(a0*b0);
            c1 = eml_rdivide(a0-b0,2);
            i1 = i1 + 1;
            w1 = pow2(i1)*c1*c1;
            s0 = s0 + w1;
            a0 = a1;
            b0 = b1;
        end
        k(j) = eml_rdivide(pi,2*a1);
        e(j) = k(j)*(1-eml_rdivide(s0,2));
    end
end
