function x = eml_scalar_fix(x)
%Embedded MATLAB Library Function

%   Copyright 2002-2007 The MathWorks, Inc.
%#eml

if isfloat(x)
    if isreal(x)
        x = scalar_fix(x);
    else
        x = complex(scalar_fix(real(x)),scalar_fix(imag(x)));
    end
end

%--------------------------------------------------------------------------

function x = scalar_fix(x)
if x > 0
    x = eml_floor(x);
else
    x = eml_ceil(x);
end

%--------------------------------------------------------------------------
