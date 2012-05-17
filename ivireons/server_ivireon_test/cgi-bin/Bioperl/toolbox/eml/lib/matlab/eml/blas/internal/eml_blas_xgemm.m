function C = eml_blas_xgemm(TRANSA,TRANSB,m,n,k,alpha1,A,ia0,lda,B,ib0,ldb,beta1,C,ic0,ldc)
%Embedded MATLAB Private Function

%   Level 3 BLAS
%   xGEMM(TRANSA,TRANSB,M,N,K,ALPHA11,A(IA0),LDA,B(IB0),LDB,BETA1,C(IC0),LDC)

%   Copyright 2007 The MathWorks, Inc.
%#eml

C = eml_refblas_xgemm(TRANSA,TRANSB,m,n,k,alpha1,A,ia0,lda,B,ib0,ldb,beta1,C,ic0,ldc);