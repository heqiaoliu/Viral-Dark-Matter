function b = gammainc(x,a,tail)
%Embedded MATLAB Library Function

%   Copyright 1984-2008 The MathWorks, Inc.
%#eml

eml_assert(nargin >= 2, 'Not enough inputs.');
eml_assert(isreal(a), 'A must be real.');
eml_assert(isreal(x), 'X must be real.');
lower = nargin < 3 || strcmp(tail, 'lower');
eml_assert(lower || strcmp(tail,'upper'), ... 
    'TAIL must be ''lower'' or ''upper''.');%MATLAB:gammainc:InvalidTailArg
b = eml_scalexp_alloc(complex(real(eml_scalar_eg(x,a))),x,a);
% Upper limit for series and continued fraction.
ONE = ones(class(b));
ZERO = zeros(class(b));
AMAX = eml_const(cast(2^20,class(b)));
THIRD = eml_const(cast(eml_rdivide(1,3),class(b)));
AMAXMTHIRD = eml_const(cast((2^20)-eml_rdivide(1,3),class(b)));
% Approximation for a > amax.  Accurate to about 5.e-5.
for k = 1:eml_numel(b)
    b(k) = eml_guarded_nan(class(b));
    ak = cast(eml_scalexp_subsref(a,k),class(b));
    xk = cast(eml_scalexp_subsref(x,k),class(b));
    if ak > AMAX
        xk = max(AMAXMTHIRD + sqrt(eml_rdivide(AMAX,ak))*(xk-(ak-THIRD)),ZERO);
        ak = AMAX;
    end
    if ak < ZERO
        eml_error('MATLAB:gammainc:NegativeArg','A must be non-negative.');
    elseif ak == ZERO
        if lower
            b(k) = ONE;
        else
            b(k) = ZERO;
        end
    elseif xk == ZERO
        if lower
            b(k) = ZERO;
        else
            b(k) = ONE;
        end
    elseif xk < ak + ONE
        ap = ak;
        del = ONE;
        sum = del;
        while abs(del) >= 100*eps(abs(sum))
            ap = ap + ONE;
            del = eml_rdivide(xk*del,ap);
            sum = sum + del;
        end
        bk = sum * exp(-xk + ak * log(complex(xk)) - gammaln(ak+1));
        % For very small a, the series may overshoot very slightly.
        if (xk > ZERO) && (bk > ONE) % bk is real when xk > 0
            bk = ONE;
        end
        if lower
            b(k) = bk;
        else
            b(k) = ONE - bk;
        end
    elseif xk >= ak + ONE
        a0 = ONE;
        a1 = xk;
        b0 = ZERO;
        b1 = a0;
        fac = eml_rdivide(ONE,a1);
        n = 1;
        g = b1 * fac;
        gold = b0;
        while abs(g-gold) >= 100*eps(abs(g))
            gold = g;
            ana = n - ak;
            a0 = (a1 + a0 * ana) * fac;
            b0 = (b1 + b0 * ana) * fac;
            anf = n*fac;
            a1 = xk * a0 + anf * a1;
            b1 = xk * b0 + anf * b1;
            fac = eml_rdivide(ONE,a1);
            g = b1 * fac;
            n = n + 1;
        end
        bk = exp(-xk + ak*log(complex(xk)) - gammaln(ak)) * g;
        if lower
            b(k) = ONE - bk;
        else
            b(k) = bk;
        end
    end
end
