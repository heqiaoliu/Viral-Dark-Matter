function y = erfcx(x)
%Embedded MATLAB Library Function

%   Copyright 1984-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin == 1, 'Not enough input arguments.');
y = eml_erfcore(x,2);
