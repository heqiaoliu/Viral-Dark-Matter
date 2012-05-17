function B = eml_blas_xtrsm(SIDE,UPLO,TRANSA,DIAGA,m,n,alpha1,A,ia0,lda,B,ib0,ldb)
%Embedded MATLAB Private Function

%   Level 3 BLAS 
%   xTRSM(SIDE,UPLO,TRANSA,DIAGA,M,N,ALPHA1,A(IA0),LDA,B(IB0),LDB)

%   Copyright 2002-2007 The MathWorks, Inc.
%#eml

B = eml_refblas_xtrsm(SIDE,UPLO,TRANSA,DIAGA,m,n,alpha1,A,ia0,lda,B,ib0,ldb);
