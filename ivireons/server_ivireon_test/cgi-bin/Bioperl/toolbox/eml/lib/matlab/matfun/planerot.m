function [G,x] = planerot(x)
%Embedded MATLAB Library Function

%   Copyright 1984-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin == 1, 'Not enough input arguments.');
eml_assert(isa(x,'float'), ...
    ['Function ''planerot'' is not defined for values of class ''' class(x) '''.']);
eml_assert(eml_is_const(size(x)),'Input must be fixed-size.');
eml_assert(eml_numel(x) == 2 && size(x,1) == 2 && size(x,2) == 1, ...
    ... 'EmbeddedMATLAB:planerot:need2ElementColumnVector', ...
    'Input must be a 2-element column vector.');
if x(2) ~= 0
    r = norm(x);
    G = eml_div([x';-x(2),x(1)],r);
    x = [r; 0];
else
    G = eye(2,class(x));
end
