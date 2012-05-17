function w = log1p(z)
%LOG1P  Compute log(1+z) accurately.
%   LOG1P(Z) computes log(1+z), without computing 1+z for small z.
%   For small z, log1p(z) should be approximately z, whereas the computed
%   value of log(1+z) can be zero or have high relative error.
%   Complex z is acceptable.
%
%   See also LOG, EXPM1.

%   Copyright 1984-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2010/04/21 21:31:33 $

% Initialize.  Retain this result for small z.

w = z;
z = z(:);
u = 1+z;

if isreal(z)
    
    % Real z, abs(z) not too large, and z not so small that 1+z == 1.
    % Algorithm due to W. Kahan, from unpublished course notes.
    p = (u<=0) | ~isfinite(u);
    m = ~(u==1 | p);
    um = u(m);
    w(m) = log(um).*(z(m)./(um-1));
    w(p) = log(u(p));
    
else
    
    % Large abs(z), including nan and inf.
    m = abs(z) > 1/eps(class(z)) | ~isfinite(z);
    w(m) = log(u(m));

    % Real z, abs(z) not too large, and z not so small that 1+z == 1.
    % Algorithm due to W. Kahan, from unpublished course notes.
    k = ~m & (imag(u) == 0) & (u ~= 1);
    uk = u(k);
    w(k) = log(uk).*(z(k)./(uk-1));

    % Complex z, abs(z) not too large, real(z) < -1/2.
    % OK to compute log(1+z)
    cmplz = ~m & imag(z) ~= 0;
    lefthalf = real(z) < -.5;
    k = cmplz & lefthalf;
    w(k) = log(u(k));

    % Complex z, abs(z) not too large, real(z) >= -1/2.
    % Let 1+z = r*exp(i*theta), then log(1+z) = log(r^2)/2+i*theta.
    % Do not actually compute r, but use log1p recursively with r^2-1.
    k = cmplz & ~lefthalf;
    zk = z(k);
    x = real(zk);
    y = imag(zk);
    w(k) = log1p(2*x+x.^2+y.^2)/2 + atan2(y,1+x)*1i;
        
end