function x = atanh(x)
%Embedded MATLAB Library Function

%   Copyright 2002-2008 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(isa(x,'float'), ['Function ''atanh'' is not defined for values of class ''' class(x) '''.']);
if isreal(x)
    for k = 1:eml_numel(x)
        if x(k) < -1 || 1 < x(k)
            eml_error('EmbeddedMATLAB:atanh:domainError', ...
                'Domain error. To compute complex results from real x, use ''atanh(complex(x))''.');
            x(k) = eml_guarded_nan(class(x));
        end
    end
end
for k = 1:eml_numel(x)
    x(k) = eml_scalar_atanh(x(k));
end
