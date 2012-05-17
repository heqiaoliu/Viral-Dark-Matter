function [A,tau] = eml_lapack_xgeqrf(A)
%Embedded MATLAB Private Function

%   Copyright 2005-2010 The MathWorks, Inc.
%#eml

eml_must_inline;
[A,tau] = eml_matlab_zgeqp3(A);
