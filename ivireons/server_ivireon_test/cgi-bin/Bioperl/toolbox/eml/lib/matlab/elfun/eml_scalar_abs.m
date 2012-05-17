function y = eml_scalar_abs(x)
%Embedded MATLAB Library Function

%   Copyright 2002-2007 The MathWorks, Inc.
%#eml

if ischar(x) || islogical(x)
    y = double(x);
elseif isinteger(x)
    % No support for complex integers.
    % Trust range analysis to eliminate conditional for uints.
    if x < 0
        y = -x;
    else
        y = x;
    end
elseif isreal(x) % real float
    y = eml_fabs(x);
else % complex float
    y = eml_dlapy2(real(x),imag(x));
end
