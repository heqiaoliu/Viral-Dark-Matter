function x = asind(x)
%Embedded MATLAB Library Function

%   Copyright 2002-2007 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(isa(x,'float'), ['Function ''asind'' is not defined for values of class ''' class(x) '''.']);
eml_assert(isreal(x), 'Argument should be real.');
for k = 1:eml_numel(x)
    if x(k) < -1 || 1 < x(k)
        eml_error('EmbeddedMATLAB:asind:domainError', ...
            'Domain error. All input values must be in the range [-1,1].');
    end
end
for k = 1:eml_numel(x)
    x(k) = eml_scalar_asind(x(k));
end


