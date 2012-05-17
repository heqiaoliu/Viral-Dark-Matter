function [a,b,c,s] = eml_blas_xrotg(a,b)
%Embedded MATLAB Private Function

%   Level 1 BLAS 
%   xROTG(A,B,C,S)

%   Copyright 2007 The MathWorks, Inc.
%#eml

[a,b,c,s] = eml_refblas_xrotg(a,b);
