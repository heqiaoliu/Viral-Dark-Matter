function x = log(x)
%Embedded MATLAB Library Function

%   Copyright 2002-2007 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(isa(x,'float'), ['Function ''log'' is not defined for values of class ''' class(x) '''.']);
if isreal(x)
    for k = 1:eml_numel(x)
        if x(k) < 0
            eml_error('EmbeddedMATLAB:log:domainError', ...
                'Domain error. To compute complex results from real x, use ''log(complex(x))''.');
        end
    end
end
for k = 1:eml_numel(x)
    x(k) = eml_scalar_log(x(k));
end
