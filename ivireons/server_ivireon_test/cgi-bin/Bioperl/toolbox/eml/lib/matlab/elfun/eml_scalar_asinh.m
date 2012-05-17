function x = eml_scalar_asinh(x)
%Embedded MATLAB Library Function

%   Copyright 2002-2007 The MathWorks, Inc.
%#eml

if isreal(x)
    % Adapted from the algorithm in src\util\libm\fdlibm.cpp
    % Method :
    %	Based on
    %		asinh(x) = sign(x) * log [ |x| + sqrt(x*x+1) ]
    %	we have
    %		asinh(x) := sign(x)*(log(x)+ln2)) for large |x|, else
    %		asinh(x) := sign(x)*log(2|x|+1/(|x|+sqrt(x*x+1))) if|x|>2, else
    %		asinh(x) := sign(x)*log1p(|x| + x^2/(1 + sqrt(1+x^2)))
    xneg = x < 0;
    if xneg
        x = -x;
    end
    if x >= eml_const(eml_pow(2,28)) % |x|>=large
        x = eml_log(x) + eml_log(2);
    elseif x > 2 % 2<|x|<large
        x = eml_log(2.*x + eml_rdivide(1,eml_sqrt(x.*x+1)+x));
    else % 2>=|x|
        t = x.*x;
        x = eml_scalar_log1p(x + eml_rdivide(t,1+eml_sqrt(1+t)));
    end
    if xneg
        x = -x;
    end
else
    % y = -i*asin(i*x)
    ctmp = eml_scalar_asin(complex(-imag(x),real(x)));
    x = complex(imag(ctmp),-real(ctmp));
end
