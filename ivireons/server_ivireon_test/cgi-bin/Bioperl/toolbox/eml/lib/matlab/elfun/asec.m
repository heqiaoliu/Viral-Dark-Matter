function x = asec(x)
%Embedded MATLAB Library Function

%   Copyright 2002-2007 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(isa(x,'float'), ['Function ''asec'' is not defined for values of class ''' class(x) '''.']);
if isreal(x)
    for k = 1:eml_numel(x)
        if -1 < x(k) && x(k) < 1
            eml_error('EmbeddedMATLAB:asec:domainError', ...
                'Domain error. To compute complex results from real x, use ''asec(complex(x))''.');
        end
    end
end
for k = 1:eml_numel(x)
    x(k) = eml_scalar_asec(x(k));
end
