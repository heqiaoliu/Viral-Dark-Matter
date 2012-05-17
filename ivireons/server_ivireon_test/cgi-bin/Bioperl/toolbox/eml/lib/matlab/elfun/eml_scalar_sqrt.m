function x = eml_scalar_sqrt(x)
%Embedded MATLAB Library Function

%   Copyright 2002-2008 The MathWorks, Inc.
%#eml

if isreal(x)
    x = eml_sqrt(x);
else
    if isnan(real(x)) || isnan(imag(x))
        x = complex(eml_guarded_nan(class(x)),eml_guarded_nan(class(x)));
        return
    end
    yr = eml_sqrt(0.5.*(eml_scalar_hypot(real(x),imag(x))+eml_fabs(real(x))));
    if real(x) > 0
        yi = 0.5.*eml_rdivide(imag(x),yr);
    else
        if yr > 0 && imag(x) < 0
            yi = -yr;
        else
            yi = yr;
        end
        if real(x) < 0
            yr = 0.5.*eml_rdivide(imag(x),yi);
        end
    end
    x = complex(yr,yi);
end

