function [A,info] = eml_xpotrf(uplo,n,A,ia0,lda)
%Embedded MATLAB Private Function

%   Copyright 2002-2010 The MathWorks, Inc.
%#eml

eml_must_inline;
[A,info] = eml_lapack_xpotrf(uplo,n,A,ia0,lda);