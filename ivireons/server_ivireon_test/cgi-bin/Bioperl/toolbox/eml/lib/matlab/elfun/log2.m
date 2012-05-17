function [f,e] = log2(x)
%Embedded MATLAB Library Function

%   Copyright 2006-2008 The MathWorks, Inc.
%#eml

eml_assert(nargin>0, 'Not enough input arguments.');
eml_assert(isa(x,'float'), ['Function ''log2'' is not defined for values of class ''' class(x) '''.']);
if nargout == 2
    if ~isreal(x)
        eml_warning('MATLAB:log2:ignoredImagPart','Imaginary part is ignored.');
    end
    f = zeros(size(x),class(x));
    e = zeros(size(x),class(x));
    for k = 1:eml_numel(x)
        [f(k),e(k)] = eml_scalar_log2(real(x(k)));
    end
else
    if isreal(x)
        for k = 1:eml_numel(x)
            if x(k) < 0
                eml_error('EmbeddedMATLAB:log2:domainError', ...
                    'Domain error. To compute complex results from real x, use ''log2(complex(x))''.');
            end
        end
    end
    f = eml.nullcopy(x);
    for k = 1:eml_numel(x)
        f(k) = eml_scalar_log2(x(k));
    end
end
