function [alpha1,x,tau] = eml_matlab_zlarfp(n,alpha1,x,ix0,incx)
%Embedded MATLAB Private Function

%   LAPACK ZLARFP(N,ALPHA,X(IX0),INCX,TAU)

%   Copyright 2009-2010 The MathWorks, Inc.
%#eml

tau = eml_scalar_eg(x);
if n <= 0
    return
end
nm1 = eml_index_minus(n,1);
xnorm = eml_xnrm2(nm1,x,ix0,incx);
if xnorm == 0
    % H  =  [1-alpha/abs(alpha) 0; 0 I], sign chosen so ALPHA >= 0.
    if imag(alpha1) == 0
        % When TAU.eq.ZERO, the vector is special-cased to be
        % all zeros in the application routines.  We do not need
        % to clear it.
        if ~(real(alpha1) >= 0)
            % However, the application routines rely on explicit
            % zero checks when TAU.ne.ZERO, and we must clear X.
            tau = tau + 2;
            for k = 1:nm1
                x(eml_index_plus(ix0,eml_index_times(eml_index_minus(k,1),incx))) = 0;
            end
            alpha1 = -alpha1;
        end
    else
        % Only "reflecting" the diagonal entry to be real and non-negative.
        xnorm = eml_dlapy2(real(alpha1),imag(alpha1));
        tau = 1 - eml_div(alpha1,xnorm);
        for k = 1:nm1
            x(eml_index_plus(ix0,eml_index_times(eml_index_minus(k,1),incx))) = 0;
        end
        alpha1(1) = xnorm;
    end
else
    % general case
    % BETA = SIGN( DLAPY3( ALPHR, ALPHI, XNORM ), ALPHR )
    if isreal(alpha1)
        beta1 = eml_dlapy2(alpha1,xnorm);
    else
        beta1 = eml_dlapy3(real(alpha1),imag(alpha1),xnorm);
    end
    if real(alpha1) < 0
        beta1 = -beta1;
    end
    SAFMIN = eml_rdivide(realmin(class(x)),eps(class(x)));
    RSAFMIN = eml_rdivide(1,SAFMIN);
    knt = zeros(eml_index_class);
    if abs(beta1) < SAFMIN
        % XNORM, BETA may be inaccurate; scale X and recompute them
        while true
            knt = eml_index_plus(knt,1);
            x = eml_xscal(nm1,RSAFMIN,x,ix0,incx);
            beta1 = beta1*RSAFMIN;
            alpha1 = alpha1*RSAFMIN;
            if abs(beta1) >= SAFMIN
                break
            end
        end
        % New BETA is at most 1, at least SAFMIN
        xnorm = eml_xnrm2(nm1,x,ix0,incx);
        if isreal(alpha1)
            beta1 = eml_dlapy2(real(alpha1),xnorm);
        else
            beta1 = eml_dlapy3(real(alpha1),imag(alpha1),xnorm);
        end
        if real(alpha1) < 0
            beta1 = -beta1;
        end
    end
    alpha1 = alpha1 + beta1;
    if beta1 < 0
        beta1 = -beta1;
        tau = -alpha1 / beta1;
    else
        % ALPHR = ALPHI * (ALPHI/real( ALPHA ))
        % ALPHR = ALPHR + XNORM * (XNORM/real( ALPHA ))
        % TAU = DCMPLX( ALPHR/BETA, -ALPHI/BETA )
        % ALPHA = DCMPLX( -ALPHR, ALPHI )
        if isreal(alpha1)
            alpha1 = xnorm*(xnorm / alpha1);
            tau = alpha1 / beta1;
            alpha1 = -alpha1;
        else
            alphr = imag(alpha1)*(imag(alpha1)/real(alpha1));
            alphr = alphr + xnorm*(xnorm/real(alpha1));
            tau = complex(alphr/beta1,-imag(alpha1)/beta1);
            alpha1 = complex(-alphr,imag(alpha1));
        end
    end
    alpha1 = eml_div(1,alpha1);
    x = eml_xscal(nm1,alpha1,x,ix0,incx);
    % If BETA is subnormal, it may lose relative accuracy
    for k = 1:knt
        beta1 = beta1*SAFMIN;
    end
    alpha1 = beta1;
end
