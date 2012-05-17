function [A,ipiv,info] = eml_xgetrf(m,n,A,iA0,lda)
%Embedded MATLAB Private Function

%   Copyright 2005-2010 The MathWorks, Inc.
%#eml

eml_must_inline;
[A,ipiv,info] = eml_lapack_xgetrf(m,n,A,iA0,lda);
