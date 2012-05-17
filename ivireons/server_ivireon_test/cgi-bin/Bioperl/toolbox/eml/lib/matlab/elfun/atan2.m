function r = atan2(y,x)
%Embedded MATLAB Library Function

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin>1,'Not enough input arguments.');
eml_assert(isa(x,'float'), ...
    ['Function ''atan2'' is not defined for values of class ''' class(x) '''.']);
eml_assert(isa(y,'float'), ...
    ['Function ''atan2'' is not defined for values of class ''' class(y) '''.']);
eml_assert(isreal(y) && isreal(x), 'Arguments must be real.');
r = eml_scalexp_alloc(eml_scalar_eg(y,x),y,x);
for k = 1:eml_numel(r)
    r(k) = eml_scalar_atan2(eml_scalexp_subsref(y,k),eml_scalexp_subsref(x,k));
end
