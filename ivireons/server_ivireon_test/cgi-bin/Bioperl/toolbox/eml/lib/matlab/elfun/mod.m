function r = mod(x,y)
%Embedded MATLAB Library Function

%   Copyright 2002-2008 The MathWorks, Inc.
%#eml

eml_assert(nargin > 1, 'Not enough input arguments.');
eml_assert(isreal(x) && isreal(y), 'Arguments must be real.');
eml_assert(isa(x,'numeric') || ischar(x), ['Function ''mod'' is not defined for values of class ''' class(x) '''.']);
eml_assert(isa(y,'numeric') || ischar(y), ['Function ''mod'' is not defined for values of class ''' class(y) '''.']);
eml_assert(isa(x,class(y)) || ...
    (~isinteger(x) && ~isinteger(y)) || ...
    (isinteger(x) && (isscalar(y) && isa(y,'double'))) || ...
    (isinteger(y) && (isscalar(x) && isa(x,'double'))), ...
    'Integers can only be combined with integers of the same class, or scalar doubles.');
r = eml_scalexp_alloc(eml_scalar_eg(x,y),x,y);
for k = 1:eml_numel(r)
    xk = cast(eml_scalexp_subsref(x,k),class(r));
    yk = cast(eml_scalexp_subsref(y,k),class(r));
    r(k) = eml_scalar_mod(xk,yk);
end
