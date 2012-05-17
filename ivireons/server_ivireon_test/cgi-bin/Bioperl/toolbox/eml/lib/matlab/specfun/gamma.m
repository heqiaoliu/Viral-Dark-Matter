function result = gamma(x)
%Embedded MATLAB Library Function

%   Copyright 1984-2008 The MathWorks, Inc.
%#eml

eml_assert(nargin == 1, 'Not enough input arguments.');
eml_assert(isa(x,'float'), 'Inputs must be single or double.');
eml_assert(isreal(x), 'Input must be real.');

gam = [1.0; 1.0; 2.0; 6.0; 24.0; 120.0; 720.0; 5040.0; 40320.0;
    362880.0; 3628800.0; 39916800.0; 479001600.0; 6227020800.0;
    87178291200.0; 1307674368000.0; 20922789888000.0; 355687428096000.0;
    6402373705728000.0; 121645100408832000.0; 2432902008176640000.0;
    51090942171709440000.0; 1124000727777607680000.0];

p = [-1.71618513886549492533811e+0; 2.47656508055759199108314e+1;
    -3.79804256470945635097577e+2; 6.29331155312818442661052e+2;
    8.66966202790413211295064e+2; -3.14512729688483675254357e+4;
    -3.61444134186911729807069e+4; 6.64561438202405440627855e+4];
q = [-3.08402300119738975254353e+1; 3.15350626979604161529144e+2;
    -1.01515636749021914166146e+3; -3.10777167157231109440444e+3;
    2.25381184209801510330112e+4; 4.75584627752788110767815e+3;
    -1.34659959864969306392456e+5; -1.15132259675553483497211e+5];
c = [-1.910444077728e-03; 8.4171387781295e-04;
    -5.952379913043012e-04; 7.93650793500350248e-04;
    -2.777777777777681622553e-03; 8.333333333333333331554247e-02;
    5.7083835261e-03];

result = eml.nullcopy(x);
for k = 1:eml_numel(x)
    if (x(k) >= 1) && (x(k) <= 23) && (x(k) == floor(x(k)))
        result(k) = gam(x(k));
    elseif (x(k) < 1) && (x(k) == floor(x(k))) %x is a non-positive integer
        result(k) = eml_guarded_inf;
    elseif isnan(x(k))
        result(k) = eml_guarded_nan;
    elseif isinf(x(k))
        result(k) = eml_guarded_inf;
    else
        fact = ones(class(x));
        n = zeros(class(x));
        parity = false;
        if x(k) <= 0  % Catch negative x(k)
            y = -x(k);
            yint = floor(y);
            result(k) = y - yint;
            if yint ~= floor(eml_rdivide(y,2))*2
                parity = true;
            end
            fact = eml_rdivide(-pi,sin(pi*result(k)));
            x(k) = y + 1;
        end
        if x(k) < 12
            xkold = x(k);
            if x(k) < 1
                z = x(k);
                x(k) = x(k) + 1;
            else
                n = floor(x(k)) - 1;
                x(k) = x(k) - n;
                z = x(k) - 1;
            end
            xnum = 0*z;
            xden = xnum + 1;
            for i = 1:8
                xnum = (xnum + p(i)) * z;
                xden = xden * z + q(i);
            end
            result(k) = eml_rdivide(xnum,xden) + 1;
            if xkold < x(k)
                result(k) = eml_rdivide(result(k),xkold);
            elseif xkold > x(k)
                for j = 1:n
                    result(k) = result(k) * x(k);
                    x(k) = x(k) + 1;
                end
            end
        else  % x(x) >= 12
            y = x(k);
            ysq = y*y;
            sum = cast(c(7),class(y));
            for i = 1:6
                sum = eml_rdivide(sum,ysq) + c(i);
            end
            spi = 0.9189385332046727417803297;
            sum = eml_rdivide(sum,y) - y + spi;
            sum = sum + (y - 0.5)*eml_log(y);
            result(k) = eml_exp(sum);
        end
        if parity
            result(k) = -result(k);
        end
        if fact ~= 1
            result(k) = eml_rdivide(fact,result(k));
        end
    end
end