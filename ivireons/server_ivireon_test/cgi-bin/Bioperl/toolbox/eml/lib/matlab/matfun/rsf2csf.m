function [U,T] = rsf2csf(Ur,Tr)
%Embedded MATLAB Library Function

%   Copyright 1984-2010 The MathWorks, Inc.
%#eml

eml_assert(nargin == 2, 'Not enough input arguments.');
eml_assert(isa(Ur,'float') && isa(Tr,'float'), ...
    'Inputs must be ''double'' or ''single''.');
eml_assert(isreal(Ur) && isreal(Tr), 'Inputs must be real.');
[T,U] = eml_rsf2csf(Tr,Ur);