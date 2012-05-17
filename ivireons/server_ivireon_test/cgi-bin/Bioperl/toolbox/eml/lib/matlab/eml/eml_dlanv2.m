function [rt1r,rt1i,rt2r,rt2i,a,b,c,d,cs,sn] = eml_dlanv2(a,b,c,d)
%Embedded MATLAB Private Function

%    Based on:
%    -- LAPACK driver routine (version 3.2) --
%    SUBROUTINE DLANV2(A,B,C,D,RT1R,RT1I,RT2R,RT2I,CS,SN)
%    DLANV2 computes the Schur factorization of a real 2-by-2 nonsymmetric
%    matrix in standard form:
%    [ A  B ] = [ CS -SN ] [ AA  BB ] [ CS  SN ]
%    [ C  D ]   [ SN  CS ] [ CC  DD ] [-SN  CS ]

%   Copyright 2010 The MathWorks, Inc.
%#eml

multpl = 4;
zero = eml_scalar_eg(a,b,c,d);
one = ones(class(zero));
if c == zero
    cs = one;
    sn = zero;
elseif b == zero
    % Swap rows and columns
    cs = zero;
    sn = one;
    temp = d;
    d = a;
    a = temp;
    b = -c;
    c = zero;
elseif ((a-d) == zero) && ((b < 0) ~= (c < 0))
    cs = one;
    sn = zero;
else
    temp = a - d;
    p = 0.5*temp;
    bcmax = max(abs(b),abs(c));
    bcmis = min(abs(b),abs(c))*fortran_sign(one,b)*fortran_sign(one,c);
    scale = max(abs(p),bcmax);
    z = (p / scale)*p + (bcmax / scale)*bcmis;
    % If Z is of the order of the machine accuracy,postpone the
    % decision on the nature of eigenvalues
    if z >= multpl*eps
        % Real eigenvalues. Compute A and D.
        z = p + fortran_sign(sqrt(scale)*sqrt(z),p);
        a = d + z;
        d = d - (bcmax / z)*bcmis;
        % Compute B and the rotation matrix
        tau = eml_dlapy2(c,z);
        cs = z / tau;
        sn = c / tau;
        b = b - c;
        c = zero;
    else
        % Complex eigenvalues, or real (almost) equal eigenvalues.
        % Make diagonal elements equal.
        sigma = b + c;
        tau = eml_dlapy2(sigma,temp);
        cs = sqrt(0.5*(one+abs(sigma) / tau));
        sn = -(p / (tau*cs))*fortran_sign(one,sigma);
        % Compute [ AA  BB ] = [ A  B ] [ CS -SN ]
        % [ CC  DD ]   [ C  D ] [ SN  CS ]
        aa = a*cs + b*sn;
        bb = -a*sn + b*cs;
        cc = c*cs + d*sn;
        dd = -c*sn + d*cs;
        % Compute [ A  B ] = [ CS  SN ] [ AA  BB ]
        % [ C  D ]   [-SN  CS ] [ CC  DD ]
        a = aa*cs + cc*sn;
        b = bb*cs + dd*sn;
        c = -aa*sn + cc*cs;
        d = -bb*sn + dd*cs;
        temp = 0.5*(a+d);
        a = temp;
        d = temp;
        if c ~= zero
            if b ~= zero
                if (b < 0) == (c < 0)
                    % Real eigenvalues: reduce to upper triangular form
                    sab = sqrt(abs(b));
                    sac = sqrt(abs(c));
                    p = fortran_sign(sab*sac,c);
                    tau = one / sqrt(abs(b+c));
                    a = temp + p;
                    d = temp - p;
                    b = b - c;
                    c = zero;
                    cs1 = sab*tau;
                    sn1 = sac*tau;
                    temp = cs*cs1 - sn*sn1;
                    sn = cs*sn1 + sn*cs1;
                    cs = temp;
                end
            else
                b = -c;
                c = zero;
                temp = cs;
                cs = -sn;
                sn = temp;
            end
        end
    end
end
% Store eigenvalues in (RT1R,RT1I) and (RT2R,RT2I).
rt1r = a;
rt2r = d;
if c == zero
    rt1i = zero;
    rt2i = zero;
else
    rt1i = sqrt(abs(b))*sqrt(abs(c));
    rt2i = -rt1i;
end
% End of DLANV2

%--------------------------------------------------------------------------

function y = fortran_sign(a,b)
eml_must_inline;
if (b < 0) == (a < 0)
    y = a;
else
    y = -a;
end

%--------------------------------------------------------------------------
