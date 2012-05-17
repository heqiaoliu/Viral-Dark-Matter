function [a,tau] = eml_lapack_xgehrd(a)
%Embedded MATLAB Private Function

%   Copyright 2010 The MathWorks, Inc.
%#eml

eml_must_inline;
[a,tau] = eml_matlab_zgehrd(a);