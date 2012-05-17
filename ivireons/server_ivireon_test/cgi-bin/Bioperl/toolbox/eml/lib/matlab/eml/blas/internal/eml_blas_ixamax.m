function idxmax = eml_blas_ixamax(n,x,ix0,incx)
%Embedded MATLAB Private Function

%   Level 1 BLAS 
%   IxAMAX(N,X(IX0),INCX)

%   Copyright 2007 The MathWorks, Inc.
%#eml

idxmax = eml_refblas_ixamax(n,x,ix0,incx);