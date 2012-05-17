function x = eml_scalar_round(x)
%Embedded MATLAB Library Function

%   Copyright 2002-2007 The MathWorks, Inc.
%#eml

if isfloat(x)
    if isreal(x)
        x = scalar_round(x);
    else
        x = complex(scalar_round(real(x)),scalar_round(imag(x)));
    end
end

%--------------------------------------------------------------------------

function y = scalar_round(x)
if x < 0
    y = eml_ceil(x - 0.5);
else
    y = eml_floor(x + 0.5);
end

%--------------------------------------------------------------------------
