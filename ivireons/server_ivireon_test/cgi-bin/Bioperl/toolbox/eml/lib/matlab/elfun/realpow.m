function z = realpow(x,y)
%Embedded MATLAB Library Function

%   Copyright 2006-2008 The MathWorks, Inc.
%#eml

eml_assert(nargin >= 2, 'Not enough input arguments.');
eml_assert(isa(x,'float'), ['Function ''realpow'' is not defined for values of class ''' class(x) '''.']);
eml_assert(isa(y,'float'), ['Function ''realpow'' is not defined for values of class ''' class(y) '''.']);
eml_assert(isreal(x) && isreal(y), 'Inputs must be real.');
z = eml_scalexp_alloc(eml_scalar_eg(x,y),x,y);
for k = 1:eml_numel(z)
    xk = eml_scalexp_subsref(x,k);
    yk = eml_scalexp_subsref(y,k);
    if xk < 0 && floor(yk) ~= yk
        eml_error('MATLAB:realpow:complexResult','Realpow produced complex result.');
    end
end
for k = 1:eml_numel(z)
  z(k) = eml_scalar_realpow( ...
      eml_scalexp_subsref(x,k), ...
      eml_scalexp_subsref(y,k));
end
