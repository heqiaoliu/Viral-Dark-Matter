function b = isnan(x)
%Embedded MATLAB Library Function

%   Copyright 2002-2008 The MathWorks, Inc.
%#eml

eml_allow_enum_inputs;
eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(isa(x,'numeric') || ischar(x) || islogical(x), ...
    ['Function ''isnan'' is not defined for values of class ''' class(x) '''.']);
if isa(x,'float') && eml_option('NonFinitesSupport')
    if isreal(x)
        b = eml_isnan(x);
    else
        b = eml_isnan(real(x)) | eml_isnan(imag(x)); 
    end
else
    b = eml_expand(false,size(x));
end
