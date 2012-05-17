function y = eml_blas_xgemv(trans,m,n,alpha1,A,ia0,lda,x,ix0,incx,beta1,y,iy0,incy)
%Embedded MATLAB Private Function

%   Level 2 BLAS
%   xGEMV(TRANS,M,N,ALPHA1,A(IA0),LDA,X(IX0),INCX,BETA,Y(IY0),INCY)

%   Copyright 2007 The MathWorks, Inc.
%#eml

y = eml_refblas_xgemv(trans,m,n,alpha1,A,ia0,lda,x,ix0,incx,beta1,y,iy0,incy);