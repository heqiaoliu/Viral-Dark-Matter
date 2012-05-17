function x = round(x)
%Embedded MATLAB Library Function

%   Copyright 2002-2007 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(isa(x,'numeric'), ['Function ''round'' is not defined for values of class ''' class(x) '''.']);
for k = 1:eml_numel(x)
    x(k) = eml_scalar_round(x(k));
end