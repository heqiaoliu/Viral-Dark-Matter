function c0 = commEDGE_getLinearizedGMSKPulse(Nsamp)
% commEDGE_getLinearizedGMSKPulse Design a pulse shaping filter for EDGE
% system as defined in [1].  This filter is a linearised GMSK pulse, i.e.
% the main component in a Laurant decomposition of the GMSK modulation.
%
% c0 = commEDGE_getLinearisezGMSKPulse(Nsamp) design a filter with Nsamp
% samples per symbol and returns in c0.
%
% Reference 1: 3GPP TS 45.004 v7.2.0, GSM/EDGE Radio Access Network;
% Modulation, Release 7

%   Copyright 2008-2009 The MathWorks, Inc.

delta = 1/Nsamp;

% First calculate S(t) for 0<=t<=8T.  Note that we are using normalized
% time.
cnt = 1;
s = zeros(1, ceil(8/delta)+1);
for t = 0:delta:4
    s(cnt) = sin(pi*intg(t, delta));
    cnt = cnt + 1;
end    
for t = delta:delta:4
    s(cnt) = sin(pi/2 - pi*intg(t, delta));
    cnt = cnt + 1;
end

%  Calculate c0
s0 = s(1:5*Nsamp+1);
s1 = s(1+Nsamp:6*Nsamp+1);
s2 = s(1+2*Nsamp:7*Nsamp+1);
s3 = s(1+3*Nsamp:8*Nsamp+1);
c0 = s0.*s1.*s2.*s3;

%===========================================================================
% Helper functions
function x = intg(t, delta)
% Calculate integral 0 to t of g(t)
if t
    n = 0:delta/10:t;
    g = (1/(2))*(Q(2*pi*0.3*(n-5/2)/(sqrt(log(2)))) ...
        - Q(2*pi*0.3*(n-3/2)/(sqrt(log(2)))));
    x = trapz(n, g);
else
    x = 0;
end
%---------------------------------------------------------------------------
function y = Q(x)
% Calculate Q function using complementary error function
y = 0.5*erfc(x/sqrt(2));

% [EOF]