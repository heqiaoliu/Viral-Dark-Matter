function y = eml_refblas_xnrm2(n,x,ix0,incx)
%Embedded MATLAB Private Function

%   Level 1 BLAS
%   xNRM2(N,X(IX0),INCX)

%   Copyright 2007-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin == 4, 'Not enough input arguments.');
eml_prefer_const(n,ix0,incx);
zero = zeros(class(x));
one = ones(class(x));
y = zero;
if n < 1 || incx < 1
    return
elseif n == 1
    y = abs(x(ix0));
    return
end
scale = zero;
firstNonZero = true;
kinc = cast(incx,eml_index_class);
kstart = cast(ix0,eml_index_class);
kend = eml_index_plus(kstart,eml_index_times(eml_index_minus(n,1),kinc));
for k = kstart:kinc:kend
    xk = real(x(k));
    if xk ~= zero
        absxk = abs(xk);
        if firstNonZero
            scale = absxk;
            y = one;
            firstNonZero = false;
        elseif scale < absxk
            t = eml_rdivide(scale,absxk);
            y = one + y.*t.*t;
            scale = absxk;
        else
            t = eml_rdivide(absxk,scale);
            y = y + t.*t;
        end
    end
    xk = imag(x(k));
    if xk ~= zero
        absxk = abs(xk);
        if firstNonZero
            scale = absxk;
            y = one;
            firstNonZero = false;
        elseif scale < absxk
            t = eml_rdivide(scale,absxk);
            y = one + y.*t.*t;
            scale = absxk;
        else
            t = eml_rdivide(absxk,scale);
            y = y + t.*t;
        end
    end
end
y = scale .* eml_sqrt(y);
