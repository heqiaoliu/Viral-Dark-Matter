function y = xor(s,t)
%Embedded MATLAB Library Function

%   Copyright 2006-2007 The MathWorks, Inc.
%#eml

eml_assert(nargin == 2, 'Not enough input arguments.');
eml_assert(isreal(s) && isreal(t), 'Operands must be real.');
y = logical(eml_bitxor(uint8(logical(s)),uint8(logical(t))));
