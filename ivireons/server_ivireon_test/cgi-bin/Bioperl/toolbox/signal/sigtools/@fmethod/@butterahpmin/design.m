function Ha = design(h,hs)
%DESIGN   

%   Author(s): R. Losada
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2007/10/23 18:49:57 $

Ha = sosminabutterhp(h,hs,h.MatchExactly);

%--------------------------------------------------------------------------
function Ha = sosminabutterhp(h,hs,str)
%SOSMINABUTTERHP Highpass analog Butterworth filter second-order sections.
%   Ha = SOSMINABUTTERHP(Wp,Ws,Rp,Rs) designs a minimum-order highpass
%   analog Butterworth filter that meets the specifications Wp, Ws, Rp, and
%   Rs.
%
%   Ha = SOSMINABUTTHP(Wp,Ws,Rp,Rs,EXORD) specifies a string on how to
%   use any excess order resulting from rounding the minimum-order required
%   to an integer. EXORD can be one of: 'passband' to meet the passband
%   specification exactly (and exceed the stopband specification) or 'stopband' to
%   meet the stopband specification exactly (and exceed the passband
%   specification). EXORD defaults to 'stopband'.


hlp = fmethod.butteralpmin;
hlp.MatchExactly=str;
hslp = fspecs.alpmin(1/hs.Wpass,1/hs.Wstop,hs.Apass,hs.Astop);
Halp = design(hlp,hslp);
[shp,ghp] = lp2hp(Halp);
Ha = afilt.sos(shp,ghp);

% [EOF]
