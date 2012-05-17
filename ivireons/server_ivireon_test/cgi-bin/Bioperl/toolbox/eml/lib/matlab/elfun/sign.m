function x = sign(x)
%Embedded MATLAB Library Function

%   Copyright 2002-2007 The MathWorks, Inc.
%#eml

eml_assert(nargin == 1, 'Not enough input arguments.');
eml_assert(isa(x,'numeric'),['Function ''sign'' is not defined for values of class ''' class(x) '''.']);
eml_assert(isreal(x) || ~isinteger(x), 'Complex integers are not supported.');
for k = 1:eml_numel(x)
    x(k) = eml_scalar_sign(x(k));
end
