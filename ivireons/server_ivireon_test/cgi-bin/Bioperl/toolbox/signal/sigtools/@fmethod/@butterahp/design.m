function Ha = design(h,hs)
%DESIGN   

%   Author(s): R. Losada
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2007/10/23 18:49:54 $

Ha = sosabutterhp(h,hs);

%------------------------------------------------------------------
function Ha = sosabutterhp(h,hs)
%SOSABUTTHP Highpass analog Butterworth filter second-order sections.

% Compute corresponding lowpass
hlp = fdmethod.butteralp;
hslp = fspecs.alpcutoff(hs.FilterOrder,1/hs.Wcutoff);
Halp = design(hlp,hslp);

% Transform to highpass
[shp,ghp] = lp2hp(Halp);
Ha = afilt.sos(shp,ghp);

% [EOF]
