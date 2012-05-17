function [alpha1,x,tau] = eml_matlab_zlarfg(n,alpha1,x,ix0,incx)
%Embedded MATLAB Private Function

%   LAPACK ZLARFG(N,ALPHA,X(IX0),INCX,TAU)

%   Copyright 2007-2010 The MathWorks, Inc.
%#eml

tau = eml_scalar_eg(x);
if n <= 0
    return
end
nm1 = n - 1;
SCALAR_CASE = eml_is_const(nm1) && nm1 == 1;
if SCALAR_CASE
    xnorm = abs(x(ix0));
else
    xnorm = eml_xnrm2(nm1,x,ix0,incx);
end
if xnorm ~= 0 || imag(alpha1) ~= 0
    if isreal(alpha1)
        beta1 = eml_dlapy2(alpha1,xnorm);
    else
        beta1 = eml_dlapy3(real(alpha1),imag(alpha1),xnorm);
    end
    if real(alpha1) >= 0
        beta1 = -beta1;
    end
    SAFMIN = eml_rdivide(realmin(class(x)),eps(class(x)));
    RSAFMIN = eml_rdivide(1,SAFMIN);
    if abs(beta1) < SAFMIN
        % XNORM, BETA may be inaccurate; scale X and recompute them
        knt = zeros(eml_index_class);
        while true
            knt = eml_index_plus(knt,1);
            if SCALAR_CASE
                x(ix0) = RSAFMIN*x(ix0);
            else
                x = eml_xscal(nm1,RSAFMIN,x,ix0,incx);
            end
            beta1 = beta1*RSAFMIN;
            alpha1 = alpha1*RSAFMIN;
            if abs(beta1) >= SAFMIN
                break
            end
        end
        % New BETA is at most 1, at least SAFMIN
        if SCALAR_CASE
            xnorm = abs(x(ix0));
        else
            xnorm = eml_xnrm2(nm1,x,ix0,incx);
        end
        if isreal(alpha1)
            beta1 = eml_dlapy2(real(alpha1),xnorm);
        else
            beta1 = eml_dlapy3(real(alpha1),imag(alpha1),xnorm);
        end
        if real(alpha1) >= 0
            beta1 = -beta1;
        end
        tau = eml_div(beta1-alpha1,beta1);
        alpha1 = eml_div(1,alpha1-beta1);
        if SCALAR_CASE
            x(ix0) = alpha1*x(ix0);
        else
            x = eml_xscal(nm1,alpha1,x,ix0,incx);
        end
        % If alpha1 is subnormal, it may lose rel. accuracy
        for k = 1:knt
            beta1 = beta1*SAFMIN;
        end
        alpha1 = beta1;
    else
        tau = eml_div(beta1-alpha1,beta1);
        alpha1 = eml_div(1,alpha1-beta1);
        if SCALAR_CASE
            x(ix0) = alpha1*x(ix0);
        else
            x = eml_xscal(nm1,alpha1,x,ix0,incx);
        end
        alpha1 = beta1;
    end
end
