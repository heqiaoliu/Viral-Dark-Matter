function r = hypot(x,y)
%Embedded MATLAB Library Function

%   Copyright 2003-2008 The MathWorks, Inc.
%#eml

eml_assert(nargin == 2, 'Not enough input arguments.');
eml_assert(isa(x,'float'), ['Function ''hypot'' is not defined for values of class ''' class(x) '''.']);
r = eml_scalexp_alloc(eml_scalar_eg(real(x),real(y)),x,y);
for k = 1:eml_numel(r)
    r(k) = eml_scalar_hypot(eml_scalexp_subsref(x,k),eml_scalexp_subsref(y,k));
end
