function z = log1p(z)
%Embedded MATLAB Library Function

%   Copyright 1984-2007 The MathWorks, Inc.
%#eml

eml_assert(nargin == 1, 'Not enough input arguments.');
eml_assert(isa(z,'float'), ['Function ''log1p'' is not defined for values of class ''' class(z) '''.']);
if isreal(z)
    for k = 1:eml_numel(z)
        if z(k) < -1
            eml_error('EmbeddedMATLAB:log:domainError', ...
                'Domain error. To compute complex results from real x, use ''log(complex(x))''.');
        end
    end
end
for k = 1:eml_numel(z)
    z(k) = eml_scalar_log1p(z(k));
end

