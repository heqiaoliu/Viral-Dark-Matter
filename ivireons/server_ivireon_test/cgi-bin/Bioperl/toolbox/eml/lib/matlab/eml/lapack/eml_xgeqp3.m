function [A,tau,jpvt] = eml_xgeqp3(A)
%Embedded MATLAB Private Function

%   Copyright 2005-2010 The MathWorks, Inc.
%#eml

eml_must_inline;
[A,tau,jpvt] = eml_lapack_xgeqp3(A);
