function A = eml_lapack_xungqr(m,n,k,A,ia0,lda,tau,itau0)
%Embedded MATLAB Private Function

%   Copyright 2002-2010 The MathWorks, Inc.
%#eml

eml_must_inline;
A = eml_matlab_zungqr(m,n,k,A,ia0,lda,tau,itau0);
