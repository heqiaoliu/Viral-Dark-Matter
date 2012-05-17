function x = log10(x)
%Embedded MATLAB Library Function

%   Copyright 1984-2007 The MathWorks, Inc.
%#eml

eml_assert(nargin>0, 'Not enough input arguments.');
eml_assert(isa(x,'float'), ['Function ''log10'' is not defined for values of class ''' class(x) '''.']);
if isreal(x)
    for k = 1:eml_numel(x)
        if x(k) < 0
            eml_error('EmbeddedMATLAB:log10:domainError', ...
                'Domain error. To compute complex results from real x, use ''log10(complex(x))''.');
        end
    end
end
for k = 1:eml_numel(x)
    x(k) = eml_scalar_log10(x(k));
end
