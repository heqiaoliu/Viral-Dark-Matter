function y = betainc(x,a,b,tail)
%Embedded MATLAB Library Function

%   Copyright 1984-2008 The MathWorks, Inc.
%#eml

eml_assert(nargin >= 3, 'Not enough input arguments.');
eml_assert(isa(x,'float') && isa(a,'float') && isa(b,'float'), ...
    'Inputs must be single or double.');
eml_assert(isreal(x) && isreal(a) && isreal(b), 'Inputs must be real.');
lower = nargin < 4 || strcmp(tail, 'lower');
eml_assert(lower || strcmp(tail,'upper'), ...
    'TAIL must be ''lower'' or ''upper''.');%MATLAB:betainc:BadTail
y = eml_scalexp_alloc(complex(eml_scalar_eg(x,a,b)),x,a,b);
if lower
    M3SQRT2 = cast(eml_rdivide(-3,sqrt(2)),class(y));
else
    M3SQRT2 = cast(eml_rdivide(3,sqrt(2)),class(y));
end
THIRD = cast(eml_rdivide(1,3),class(y));
for k = 1:eml_numel(y)
    xk = cast(eml_scalexp_subsref(x,k),class(y));
    ak = cast(eml_scalexp_subsref(a,k),class(y));
    bk = cast(eml_scalexp_subsref(b,k),class(y));
    if xk < 0 || xk > 1 || isnan(xk)
        eml_error('MATLAB:betainc:XoutOfRange', ...
            'X must be in the interval [0,1].');
        y(k) = eml_guarded_nan;
    elseif ak < 0 || isnan(ak)
        eml_error('MATLAB:betainc:PositiveZ', ...
            'Z must be real and nonnegative.');
        y(k) = eml_guarded_nan;
    elseif bk < 0 || isnan(bk)
        eml_error('MATLAB:betainc:PositiveW', ...
            'W must be real and nonnegative.');
        y(k) = eml_guarded_nan;
    else
        if xk == 0
            y(k) = ~lower;
        elseif xk == 1
            y(k) = lower;
        end
        akpbk = ak + bk;
        approx = akpbk > 1e7;
        if lower || approx
            onemxk = 1 - xk;
        else
            % swap to equivalent lower-tail problem
            onemxk = xk;
            xk = 1 - xk;
            temp = ak;
            ak = bk;
            bk = temp;
        end
        if ~approx
            ab1 = eml_rdivide(ak+1,akpbk+2);
            if xk < ab1
                btk = exp(gammaln(akpbk) - gammaln(ak+1) - gammaln(bk) + ...
                    ak*log(xk) + bk*log1p(-xk));
                [yk,approx] = betacore(xk,ak,bk);
                y(k) = btk*yk;
            elseif onemxk > 0
                btk = exp(gammaln(akpbk) - gammaln(ak) - gammaln(bk+1) + ...
                    ak*log(xk) + bk*log1p(-xk));
                [yk,approx] = betacore(onemxk,bk,ak);
                y(k) = 1 - btk*yk;
            end
        end
        % NaNs may have come from a=b=0, leave those alone.  Otherwise if
        % the continued fraction in betacore failed to converge, or if we
        % didn't use it, use approximations.
        if approx || (isnan(y(k)) && akpbk > 0)
            akpbkm1 = akpbk - 1;
            if akpbkm1*onemxk <= 0.8
                s = 0.5*(akpbkm1*(3-xk)-(bk-1)).*onemxk;
                if lower
                    y(k) = gammainc(s,bk,'upper');
                else
                    y(k) = gammainc(s,bk,'lower');
                end
            else
                w1 = (bk*xk)^THIRD;
                w2 = (ak*onemxk)^THIRD;
                t1 = 1 - eml_rdivide(1,9*bk);
                t2 = 1 - eml_rdivide(1,9*ak);
                y(k) = 0.5*erfc(eml_rdivide(M3SQRT2*(t1*w1-t2*w2), ...
                    sqrt(eml_rdivide(w1*w1,bk)+eml_rdivide(w2*w2,ak))));
            end
        end
    end
end

%--------------------------------------------------------------------------

function [y,flag] = betacore(x,a,b)
%BETACORE Core algorithm for the incomplete beta function.
%   Y = BETACORE(X,A,B) computes a continued fraction expansion used by
%   BETAINC.  Specifically,
%
%      BETAINC(X,A,B) = BETACORE(X,A,B) * (X^A * (1-X)^B) / (A*BETA(A,B)).
%
%   X must be strictly between 0 and 1.  Returns NaN if continued fraction
%   does not converge.
aplusb = a + b;
aplus1 = a + 1;
aminus1 = a - 1;
C = 1 + eml_scalar_eg(x,a,b); % ensure that C has the right datatype
% When called from BETAINC, Dinv can never be zero unless (a+b) or (a+1)
% round to a.
Dinv = 1 - eml_rdivide(aplusb*x,aplus1);
y = eml_rdivide(C,Dinv);
flag = true;
maxiter = 1000;
for m = 1:maxiter
    yold = y;
    twom = 2*m;
    d = eml_rdivide(m*(b - m)*x,(aminus1 + twom)*(a + twom));
    C = 1 + eml_rdivide(d,C);
    % Using Dinv, not D, ensures that C = 1/D will be a stable fixed point
    Dinv = 1 + eml_rdivide(d,Dinv);
    y = y*eml_rdivide(C,Dinv);
    d = eml_rdivide(-(a + m)*(aplusb + m)*x,(a + twom)*(aplus1 + twom));
    C = 1 + eml_rdivide(d,C);
    Dinv = 1 + eml_rdivide(d,Dinv);
    y = y*eml_rdivide(C,Dinv);
    flag = abs(y-yold) > 1000*eps(y);
    if ~flag
        return
    end
end
y = eml_guarded_nan(class(C));

%--------------------------------------------------------------------------
