function [a,b,c,s] = eml_refblas_xrotg(a,b)
%Embedded MATLAB Private Function

%   Level 1 BLAS xROTG(A,B,C,S)

%   Copyright 2007 The MathWorks, Inc.
%#eml

eml_assert(nargin == 2, 'Not enough input arguments.');
eml_assert(isreal(a) == isreal(b) && isa(a,class(b)), ...
    'A and B must be of the same class and complexness.');
ZERO = zeros(class(a));
if isreal(a) % DROTG and SROTG
    roe = b;
    absa = abs(a);
    absb = abs(b);
    if absa > absb
        roe = a;
    end
    scale = absa + absb;
    if scale == 0
        s = ZERO;
        c = ones(class(a));
        a = ZERO;
        b = ZERO;
        return
    end
    ads = absa/scale;
    bds = absb/scale;
    r = scale.*sqrt(ads.*ads + bds.*bds);
    if roe < 0
        r = -r;
    end
    c = a/r;
    s = b/r;
    if absa > absb
        b = s;
    elseif c ~= 0
        b = 1/c;
    else
        b = ones(class(b));
    end
    a = r;
else % ZROTG and CROTG
    absa = abs(a);
    if absa == 0
        c = ZERO;
        s = complex(ones(class(a)));
        a = b;
        return
    end
    absb = abs(b);
    scale = absa + absb;
    ads = absa/scale;
    bds = absb/scale;
    r = scale.*sqrt(ads.*ads + bds.*bds);
    alpha1 = a/absa;
    c = absa/r;
    s = eml_conjtimes(b,alpha1)/r;
    a = alpha1.*r;
end
