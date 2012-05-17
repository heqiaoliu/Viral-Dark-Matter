function y = angle(x)
%Embedded MATLAB Library Function

%   Copyright 2002-2007 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(isa(x,'float'), ['Function ''angle'' is not defined for values of class ''' class(x) '''.']);
y = zeros(size(x),class(x));
for k = 1:eml_numel(x)
    y(k) = eml_scalar_angle(x(k));
end
