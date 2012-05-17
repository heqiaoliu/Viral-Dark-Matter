function x = atan(x)
%Embedded MATLAB Library Function

%   Copyright 2002-2007 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(isa(x,'float'), ['Function ''atan'' is not defined for values of class ''' class(x) '''.']);
if ~isreal(x)
    for k = 1:eml_numel(x)
        if real(x(k)) == 0 && abs(imag(x(k))) == 1
            eml_warning('MATLAB:atan:singularity','Singularity in ATAN.');
            break
        end
    end
end
for k = 1:eml_numel(x)
    x(k) = eml_scalar_atan(x(k));
end
