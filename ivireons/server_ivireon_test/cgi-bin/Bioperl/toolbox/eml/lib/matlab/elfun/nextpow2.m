function p = nextpow2(n)
%Embedded MATLAB Library Function

%   Copyright 1984-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin == 1, 'Not enough input arguments.');
eml_assert(isa(n,'float'), ['Function ''nextpow2'' is not defined ', ...
    'for values of class ''' class(n) '''.']);
p = eml.nullcopy(real(n));
for k = 1:eml_numel(n)
    p(k) = eml_scalar_nextpow2(n(k));
end
