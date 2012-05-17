function y = eml_refblas_xasum(n,x,ix0,incx)
%Embedded MATLAB Private Function

%   Level 1 BLAS 
%   xASUM(N,X(IX0),INCX)

%   Copyright 2007 The MathWorks, Inc.
%#eml

eml_assert(nargin == 4, 'Not enough input arguments.');
eml_prefer_const(n,ix0,incx);
y = zeros(class(x));
if n < 1 || incx < 1
    return
end
kstart = cast(ix0,eml_index_class);
kinc = cast(incx,eml_index_class);
kend = eml_index_plus(kstart,eml_index_times(eml_index_minus(n,1),kinc));
if isreal(x) % DASUM and SASUM
    for k = kstart:kinc:kend
        y = y + abs(x(k));
    end
else % DZASUM and SCASUM
    for k = kstart:kinc:kend
        y = y + eml_xcabs1(x(k));
    end
end