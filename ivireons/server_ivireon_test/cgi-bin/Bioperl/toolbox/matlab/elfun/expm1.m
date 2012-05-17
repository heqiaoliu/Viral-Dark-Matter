function w = expm1(z)
%EXPM1  Compute exp(z)-1 accurately.
%    EXPM1(Z) computes exp(z)-1, compensating for the roundoff in exp(z).
%    For small z, expm1(z) should be approximately z, whereas the computed
%    value of exp(z)-1 can be zero or have high relative error.
%    Complex z is acceptable.
%
%    See also EXP, LOG1P.

%   Copyright 1984-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2010/04/21 21:31:32 $

% Algorithm due to W. Kahan, unpublished course notes.

% Initialize.  Retain for z small enough that exp(z)==1.
w = z;
z = z(:);
u = exp(z);

if isreal(z)
    
    % Exceptional cases and when z is not small.
    p = u==0 | ~isfinite(u) | abs(z) > 0.5;
    w(p) = u(p)-1;
    
    %Correction
    m = ~p & u~=1;
    um = u(m);
    w(m) = (um-1).*(z(m)./log(um));

else
    
    % Exceptional cases.
    p = (u==0) | ~isfinite(u) | abs(imag(z))>pi/2;
    w(p) = u(p)-1;

    % Correction, right half plane.
    m = ~p & (real(u)>=.5) & (u~=1);
    um = u(m);
    w(m) = (um-1).*(z(m)./log1p(um-1));

    % Correction, left half plane.
    m = ~p & (real(u)<.5);
    um = u(m);
    w(m) = (um-1).*(z(m)./log(um));
    
end
