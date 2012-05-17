function x = eml_scalar_sign(x)
%Embedded MATLAB Library Function

%   Copyright 2002-2007 The MathWorks, Inc.
%#eml

if isreal(x)
    if eml_option('NonFinitesSupport') && isnan(x)
        x = eml_guarded_nan(class(x));
    elseif x > 0
        x = ones(class(x));
    elseif x < 0
        x = -ones(class(x));
    else
        x = zeros(class(x));
    end
else
    absx = eml_scalar_abs(x);
    if absx == 0
        x = complex(zeros(class(x)));
    else
        x = complex(eml_rdivide(real(x),absx),eml_rdivide(imag(x),absx));
    end
end
