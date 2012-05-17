function z = eml_conjtimes(a,b)
%Embedded MATLAB Private Function
%
%   z = conj(a) .* b.  
%   Results in simpler generated code in the complex cases.

%   Copyright 2005-2007 The MathWorks, Inc.
%#eml

eml_must_inline;
if isreal(a) && isreal(b)
    z = a .* b;
elseif isreal(a)
    z = complex(a.*real(b),a.*imag(b));
elseif isreal(b)
    z = complex(real(a).*b,imag(a).*(-b));
else
    z = complex(real(a).*real(b) + imag(a).*imag(b), ...
                real(a).*imag(b) - imag(a).*real(b));
end
