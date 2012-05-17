function result = eml_erfcore(x,jint)
%Embedded MATLAB Private Function

%   Copyright 1984-2010 The MathWorks, Inc.
%#eml

eml_assert(nargin == 2, 'Not enough input arguments.');
eml_assert(isa(x,'float'), 'Inputs must be single or double.');
eml_assert(isreal(x), 'Input must be real.');
eml_assert(eml_is_const(jint), 'Second input must be a constant.');
eml_assert(jint == 0 || jint == 1 || jint == 2 || jint == 3 || jint == 4, ...
    'Second input must be 0, 1, 2, 3, or 4.');
result = eml.nullcopy(x);
if (jint == 0) || (jint == 1) || (jint == 2)
    xbreak = 0.46875;
    a = [3.16112374387056560e00; 1.13864154151050156e02;
        3.77485237685302021e02; 3.20937758913846947e03;
        1.85777706184603153e-1];
    b = [2.36012909523441209e01; 2.44024637934444173e02;
        1.28261652607737228e03; 2.84423683343917062e03];
    c = [5.64188496988670089e-1; 8.88314979438837594e00;
        6.61191906371416295e01; 2.98635138197400131e02;
        8.81952221241769090e02; 1.71204761263407058e03;
        2.05107837782607147e03; 1.23033935479799725e03;
        2.15311535474403846e-8];
    d = [1.57449261107098347e01; 1.17693950891312499e02;
        5.37181101862009858e02; 1.62138957456669019e03;
        3.29079923573345963e03; 4.36261909014324716e03;
        3.43936767414372164e03; 1.23033935480374942e03];
    p = [3.05326634961232344e-1; 3.60344899949804439e-1;
        1.25781726111229246e-1; 1.60837851487422766e-2;
        6.58749161529837803e-4; 1.63153871373020978e-2];
    q = [2.56852019228982242e00; 1.87295284992346047e00;
        5.27905102951428412e-1; 6.05183413124413191e-2;
        2.33520497626869185e-3];
    for k = 1:eml_numel(x)
        xk = x(k);
        if jint == 2 && isinf(xk) && xk < 0
            result(k) = eml_guarded_inf;
        elseif isnan(xk)
            result(k) = eml_guarded_nan;
        else
            absxk = abs(xk);
            if absxk <= xbreak % evaluate  erf  for  |x| <= 0.46875
                y = absxk;
                z = y * y;
                xnum = a(5)*z;
                xden = z;
                for i = 1:3
                    xnum = (xnum + a(i)) * z;
                    xden = (xden + b(i)) * z;
                end
                result(k) = eml_rdivide(xk*(xnum + a(4)),xden + b(4));
                if jint ~= 0, result(k) = 1 - result(k); end
                if jint == 2, result(k) = exp(z) * result(k); end
            elseif absxk <= 4.0 % evaluate  erfc  for 0.46875 <= |x| <= 4.0
                y = absxk;
                xnum = c(9)*y;
                xden = y;
                for i = 1:7
                    xnum = (xnum + c(i)) * y;
                    xden = (xden + d(i)) * y;
                end
                result(k) = eml_rdivide(xnum + c(8),xden + d(8));
                if jint ~= 2
                    z = eml_rdivide(fix(y*16),16);
                    del = (y-z)*(y+z);
                    result(k) = exp(-z*z) * exp(-del) * result(k);
                end
            else % evaluate  erfc  for |x| > 4.0
                y = absxk;
                z = eml_rdivide(1,y*y);
                xnum = p(6)*z;
                xden = z;
                for i = 1:4
                    xnum = (xnum + p(i)) * z;
                    xden = (xden + q(i)) * z;
                end
                result(k) = eml_rdivide(z*(xnum + p(5)),xden + q(5));
                result(k) = eml_rdivide(eml_rdivide(1,sqrt(pi)) - result(k),y);
                if jint ~= 2
                    z = eml_rdivide(fix(y*16),16);
                    del = (y-z)*(y+z);
                    result(k) = exp(-z*z) * exp(-del) * result(k);
                    if ~isfinite(result(k))
                        result(k) = 0.0;
                    end
                end
            end
            % fix up for negative argument, erf, etc.
            if (jint == 0) && (absxk > xbreak)
                if xk > xbreak
                    result(k) = (0.5 - result(k)) + 0.5;
                elseif xk < -xbreak
                    result(k) = (-0.5 + result(k)) - 0.5;
                end
            elseif (jint == 1) && (xk < -xbreak)
                result(k) = 2. - result(k);
            elseif xk < -xbreak  % jint must = 2
                if xk < -26.628
                    result(k) = eml_guarded_inf;
                else
                    z = eml_rdivide(fix(xk*16),16);
                    del = (xk-z)*(xk+z);
                    y = exp(z*z) * exp(del);
                    result(k) = (y+y) - result(k);
                end
            end
        end
    end
elseif jint == 3
    ainv = [0.886226899; -1.645349621; 0.914624893; -0.140543331];
    binv = [-2.118377725; 1.442710462; -0.329097515; 0.012229801];
    cinv = [-1.970840454; -1.624906493; 3.429567803; 1.641345311];
    dinv = [3.543889200; 1.637067800];
    x0 = 0.7;
    tosp = 1.1283791670955126645; % 2/sqrt(pi)
    for k = 1:eml_numel(x)
        absxk = abs(x(k));
        xk = x(k);
        % Central range
        if absxk <= x0
            z = xk*xk;
            result(k) = eml_rdivide(xk*(((ainv(4)*z+ainv(3))*z+ainv(2))*z+ainv(1)), ...
                (((binv(4)*z+binv(3))*z+binv(2))*z+binv(1))*z+1);
            % Near end points of range
        elseif (x0 < xk) && (xk < 1)
            z = sqrt(-log(eml_rdivide(1-xk,2)));
            result(k) = eml_rdivide(((cinv(4)*z+cinv(3))*z+cinv(2))*z+cinv(1), ...
                (dinv(2)*z+dinv(1))*z+1);
        elseif (-x0 > xk) && (xk > -1)
            z = sqrt(-log(eml_rdivide(1+xk,2)));
            result(k) = eml_rdivide(-(((cinv(4)*z+cinv(3))*z+cinv(2))*z+cinv(1)), ...
                (dinv(2)*z+dinv(1))*z+1);
            % Exceptional cases
        elseif xk == -1
            result(k) = -eml_guarded_inf;
            continue
        elseif xk  == 1
            result(k) = eml_guarded_inf;
            continue
        else % absxk > 1 || isnan(xk)
            result(k) = eml_guarded_nan;
            continue
        end
        % The relative error of the approximation has absolute value less
        % than 8.9e-7.  One iteration of Halley's rational method (third
        % order) gives full machine precision.
        % Newton's method: new x = x - f/f'
        % Halley's method: new x = x - 1/(f'/f - (f"/f')/2)
        % This function: f = erf(x) - y, f' = 2/sqrt(pi)*exp(-x^2), f" = -2*x*f'
        % Newton's correction
        erfx = eml_erfcore(result(k),0);
        u = eml_rdivide(erfx - xk,tosp*exp(-result(k)*result(k)));
        % Halley's step
        result(k) = result(k) - eml_rdivide(u,1+result(k)*u);
    end
elseif jint == 4
    a = [1.370600482778535e-02; -3.051415712357203e-01;
        1.524304069216834; -3.057303267970988;
        2.710410832036097; -8.862269264526915e-01];
    b = [-5.319931523264068e-02; 6.311946752267222e-01;
        -2.432796560310728; 4.175081992982483;
        -3.320170388221430];
    c = [5.504751339936943e-03; 2.279687217114118e-01;
        1.697592457770869; 1.802933168781950;
        -3.093354679843504; -2.077595676404383];
    d = [7.784695709041462e-03; 3.224671290700398e-01;
        2.445134137142996; 3.754408661907416];
    xlow = 0.0485;
    xhigh = 1.9515;
    tosp = 1.1283791670955126645;
    for k = 1:eml_numel(x)
        xk = x(k);
        % Rational approximation for central region
        if (xlow <= xk) && (xk <= xhigh)
            q = xk - 1;
            r = q*q;
            result(k) = eml_rdivide((((((a(1)*r+a(2))*r+a(3))*r+a(4))*r+a(5))*r+a(6))*q, ...
                ((((b(1)*r+b(2))*r+b(3))*r+b(4))*r+b(5))*r+1);
            % Rational approximation for lower region
        elseif (0 < xk) && (xk < xlow)
            q = sqrt(-2*log(eml_rdivide(xk,2)));
            result(k) = eml_rdivide(((((c(1)*q+c(2))*q+c(3))*q+c(4))*q+c(5))*q+c(6), ...
                (((d(1)*q+d(2))*q+d(3))*q+d(4))*q+1);
            % Rational approximation for upper region
        elseif (xhigh < xk) && (xk < 2)
            q = sqrt(-2*log(1-eml_rdivide(xk,2)));
            result(k) = eml_rdivide(-(((((c(1)*q+c(2))*q+c(3))*q+c(4))*q+c(5))*q+c(6)), ...
                (((d(1)*q+d(2))*q+d(3))*q+d(4))*q+1);
            % Exceptional cases
        elseif xk == 0
            result(k) = eml_guarded_inf;
            continue
        elseif xk == 2
            result(k) = -eml_guarded_inf;
            continue
        else % xk < 0 || xk > 2 || isnan(xk)
            result(k) = eml_guarded_nan;
            continue
        end
        % The relative error of the approximation has absolute value less
        % than 1.13e-9.  One iteration of Halley's rational method (third
        % order) gives full machine precision.
        % Newton's method: new x = x - f/f'
        % Halley's method: new x = x - 1/(f'/f - (f"/f')/2)
        % This function: f = erfc(x) - y, f' = -2/sqrt(pi)*exp(-x^2), f" = -2*x*f'
        % Newton's correction
        erfcx = eml_erfcore(result(k),1);
        u = eml_rdivide(erfcx - xk,-tosp*exp(-result(k)*result(k)));
        result(k) = result(k) - eml_rdivide(u,1+result(k)*u);
    end
end
