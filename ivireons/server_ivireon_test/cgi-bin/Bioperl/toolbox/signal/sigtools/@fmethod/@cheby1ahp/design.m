function Ha = design(h,N,wp,rp)
%DESIGN   

%   Author(s): R. Losada
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2007/10/23 18:51:39 $

% Compute corresponding lowpass
hlp = fmethod.cheby1alp;
Halp = design(hlp,N,1/wp,rp);

% Transform to highpass
[s,g] = lp2hp(Halp);
Ha = afilt.sos(s,g);

% [EOF]
