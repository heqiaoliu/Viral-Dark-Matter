function y = expint(x)
%Embedded MATLAB Library Function

%   Copyright 2002-2008 The MathWorks, Inc.
%#eml

eml_assert(nargin == 1, 'Not enough input arguments.');
eml_assert(isa(x,'float'), 'Inputs must be single or double.');
y = eml.nullcopy(complex(real(x)));
ONE = complex(ones(class(x)));
ZERO = complex(zeros(class(x)));
% figure out which algorithm to use by evaluating interpolating polynomial
% at real(z)
egamma=0.57721566490153286061;
p = [-3.602693626336023e-09 -4.819538452140960e-07 -2.569498322115933e-05 ...
    -6.973790859534190e-04 -1.019573529845792e-02 -7.811863559248197e-02 ...
    -3.012432892762715e-01 -7.773807325735529e-01  8.267661952366478e+00];
% series expansion
for k = 1:eml_numel(x)
    xk = x(k);
    pk = polyval(p,real(xk));
    absimagxk = abs(imag(xk));
    if xk == 0
        y(k) = eml_guarded_inf;
    elseif absimagxk <= pk
        if isreal(xk)
            yk = -egamma - log(complex(xk));
        else
            yk = -egamma - log(xk);
        end
        j = 1;
        pterm = xk;
        term = xk;
        while abs(term) > eps(yk)
            yk = yk + term;
            j = j + 1;
            pterm = eml_div(-xk*pterm,j);
            term = eml_div(pterm,j);
        end
        y(k) = yk;
    elseif absimagxk > pk
        n = 1;
        xk = x(k);
        am2 = ZERO;
        bm2 = ONE;
        am1 = ONE;
        bm1 = complex(real(xk),imag(xk));
        f = eml_div(am1,bm1);
        oldf = complex(eml_guarded_inf(class(x)));
        j = 2;
        while abs(f - oldf) > 100*eps(f)
            % calculate the coefficients of the recursion formulas for j
            % even
            alpha1 = n - 1 + eml_rdivide(j,2); % note: beta1 = 1
            % calculate A(j), B(j), and f(j)
            a = am1 + alpha1*am2;
            b = bm1 + alpha1*bm2;
            % save new normalized variables for next pass through the loop
            % note: normalization to avoid overflow or underflow
            am2 = eml_div(am1,b);
            bm2 = eml_div(bm1,b);
            am1 = eml_div(a,b);
            bm1 = ONE;
            f = am1;
            j = j + 1;
            % calculate the coefficients for j odd
            alpha1 = eml_rdivide(j-1,2);
            beta1 = xk;
            a = beta1*am1 + alpha1*am2;
            b = beta1*bm1 + alpha1*bm2;
            am2 = eml_div(am1,b);
            bm2 = eml_div(bm1,b);
            am1 = eml_div(a,b);
            bm1 = ONE;
            oldf = f;
            f = am1;
            j = j + 1;
        end
        y(k) = exp(-xk)*f - 1i*pi*((real(xk)<0)&&(imag(xk)==0));
    else
        y(k) = 0;
    end
end
