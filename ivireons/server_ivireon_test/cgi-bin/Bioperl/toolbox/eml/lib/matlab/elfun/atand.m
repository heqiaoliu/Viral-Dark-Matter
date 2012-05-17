function x = atand(x)
%Embedded MATLAB Library Function

%   Copyright 2002-2007 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(isa(x,'float'), ['Function ''atand'' is not defined for values of class ''' class(x) '''.']);
eml_assert(isreal(x), 'Argument should be real.');
for k = 1:eml_numel(x)
    x(k) = eml_scalar_atand(x(k));
end
