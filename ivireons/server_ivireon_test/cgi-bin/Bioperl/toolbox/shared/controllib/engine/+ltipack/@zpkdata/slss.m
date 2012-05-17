function Dss = slss(D)
% State-space realization of SISO transfer function for LTIMASK.
%
% This realization ensures that the order is always equal to the
% denominator order. Delays are ignored.

%   Author(s): P. Gahinet
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision $  $Date: 2009/11/09 16:33:54 $
if ~isproper(D)
   ctrlMsgUtils.error('Control:general:NotSupportedSimulationImproperSys')
end
k = D.k;
[ny,nu] = size(k);
if nu~=1 || ny~=1
    ctrlMsgUtils.error('Control:general:FirstArgSISOModel','slss')
end

% Special handling of zero transfer function
ZeroTF = (k==0);
if ZeroTF
   k = 1;
end

% Realize with COMPREAL
[a,b,c,d] = zpkreal(D.z{1},D.p{1},k);
if ZeroTF
   c(:) = 0;
   d = 0;
end

% State-space object
Dss = ltipack.ssdata(a,b,c,d,[],D.Ts);

