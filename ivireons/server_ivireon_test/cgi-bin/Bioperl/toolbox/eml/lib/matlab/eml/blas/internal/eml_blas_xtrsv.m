function x = eml_blas_xtrsv(UPLO,TRANS,DIAGA,n,A,ia0,lda,x,ix0,incx)
%Embedded MATLAB Private Function

%   Level 2 BLAS 
%   xTRSV(UPLO,TRANS,DIAGA,N,A(IA0),LDA,X(IX0),INCX)

%   Copyright 2002-2007 The MathWorks, Inc.
%#eml

x = eml_refblas_xtrsv(UPLO,TRANS,DIAGA,n,A,ia0,lda,x,ix0,incx);