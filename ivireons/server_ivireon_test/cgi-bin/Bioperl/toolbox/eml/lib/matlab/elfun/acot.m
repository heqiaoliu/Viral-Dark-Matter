function x = acot(x)
%Embedded MATLAB Library Function

%   Copyright 2002-2007 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(isa(x,'float'), ['Function ''acot'' is not defined for values of class ''' class(x) '''.']);
for k = 1:eml_numel(x)
    x(k) = eml_scalar_acot(x(k));
end
