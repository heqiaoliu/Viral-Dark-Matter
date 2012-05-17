function r = eps(x)
%Embedded MATLAB Library Function

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml

if nargin == 0
    x = 'double';
end
eml_prefer_const(x);
eml_assert(isa(x,'float') || (ischar(x) && eml_is_float_class(x)), ...
    'Class must be ''single'' or ''double''');
if ischar(x)
    if strcmp(x,'single')
        r = eml_const(single(eml_pow(2,-23)));
    else
        r = eml_const(eml_pow(2,-52));
    end
else
    % Except for denormals, if 2^E <= ABS(X) < 2^(E+1), then
    %   EPS(X) = 2^(E-23) if ISA(X,'single')
    %   EPS(X) = 2^(E-52) if ISA(X,'double')
    r = eml.nullcopy(real(x));
    if isa(x,'single')
        mantissaBits = eml_const(int32(24));
        rmin = eml_const(realmin('single'));
        mineps = eml_const(eml_pow(2,-149));
    else
        mantissaBits = eml_const(int32(53));
        rmin = eml_const(realmin);
        mineps = eml_const(eml_pow(2,-1074));
    end
    for k = 1:eml_numel(x)
        absxk = abs(x(k));
        if isfinite(absxk)
            if absxk <= rmin
                r(k) = mineps;
            else
                [~,exponent] = eml_frexp(absxk);
                exponent = eml_minus(exponent,mantissaBits,'int32','spill');
                r(k) = eml_ldexp(1,exponent);
            end
        else
            r(k) = eml_guarded_nan;
        end
    end
end
