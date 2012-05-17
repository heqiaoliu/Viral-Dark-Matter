function [s,g] = design(h,wp,ws,rp,rs)
%DESIGN   

%   Author(s): R. Losada
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2007/10/23 18:53:12 $

if wp <= 0 ,
    error(generatemsgid('invalidSpec'), 'Passband-edge frequency must be greater than zero.');
end
if ws <= 0 ,
    error(generatemsgid('invalidSpec'), 'Stopband-edge frequency must be greater than zero.');
end
if rp <= 0,
    error(generatemsgid('invalidSpec'), 'Passband ripple must be greater than zero.');
end
if rs <= 0,
    error(generatemsgid('invalidSpec'), 'Stopband ripple must be greater than zero.');
end

[s,g] = sosminacheby2lp(h,wp,ws,rp,rs,h.MatchExactly);

%--------------------------------------------------------------------------
function [s,g] = sosminacheby2lp(h,wp,ws,rp,rs,str)
%SOSMINACHEBY2LP Lowpass analog Type II Chebyshev filter second-order sections.
%   [S,G] = SOSMINACHEBY2LP(Wp,Ws,Rp,Rs) designs a minimum-order lowpass
%   analog type II Chebyshev filter that meets the specifications Wp, Ws,
%   Rp, and  Rs.
%
%   [S,G] = SOSMINACHEBY2LP(Wp,Ws,Rp,Rs,EXORD) specifies a string on how to
%   use any excess order resulting from rounding the minimum-order required
%   to an integer. EXORD can be one of: 'passband' to meet the passband
%   specification exactly (and exceed the stopband specification) or 'stopband' to
%   meet the stopband specification exactly (and exceed the passband
%   specification). EXORD defaults to 'stopband'.


% Compute minimum order
[N,rs] = cheby2ord(h,wp,ws,rp,rs,str);

hlp = fmethod.cheby2alp;
[s,g] = design(hlp,N,ws,rs);

% [EOF]
