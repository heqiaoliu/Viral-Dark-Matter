function A = eml_blas_xgerc(m,n,alpha1,x,ix0,incx,y,iy0,incy,A,ia0,lda)
%Embedded MATLAB Private Function

%   Level 2 BLAS 
%   xGERC(M,N,ALPHA,X(IX0),INCX,Y(IY0),INCY,A(IA0),LDA)

%   Copyright 2007 The MathWorks, Inc.
%#eml

A = eml_refblas_xgerc(m,n,alpha1,x,ix0,incx,y,iy0,incy,A,ia0,lda);
