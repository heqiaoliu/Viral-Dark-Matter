function x = acosh(x)
%Embedded MATLAB Library Function

%   Copyright 2002-2007 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(isa(x,'float'), ['Function ''acosh'' is not defined for values of class ''' class(x) '''.']);
if isreal(x)
    for k = 1:eml_numel(x)
        if -1 < x(k) && x(k) < 1
            eml_error('EmbeddedMATLAB:acosh:domainError', ...
                'Domain error. To compute complex results from real x, use ''acosh(complex(x))''.');
            x(k) = eml_guarded_nan;
        end
    end
end
for k = 1:eml_numel(x)
    x(k) = eml_scalar_acosh(x(k));
end

