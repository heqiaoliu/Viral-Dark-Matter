function A = eml_lapack_xunghr(n,ilo,ihi,A,ia0,lda,tau,itau0)
%Embedded MATLAB Private Function

%   Copyright 2010 The MathWorks, Inc.
%#eml

eml_must_inline;
A = eml_matlab_zunghr(n,ilo,ihi,A,ia0,lda,tau,itau0);
