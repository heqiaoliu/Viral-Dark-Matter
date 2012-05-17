function Dss = slss(D)
% State-space realization of SISO transfer function for LTIMASK.
%
% This realization ensures that the order is always equal to the
% denominator order. Delays are ignored.

%   Author(s): P. Gahinet
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision $  $Date: 2009/11/09 16:32:59 $
if ~isproper(D)
   ctrlMsgUtils.error('Control:general:NotSupportedSimulationImproperSys')
end

[ny,nu] = size(D.num);
if nu~=1 || ny~=1
    ctrlMsgUtils.error('Control:general:FirstArgSISOModel','slss')
end

% Special handling of zero transfer function
num = D.num{1};
ZeroTF = all(num==0);
if ZeroTF
   num = [num(1:end-1) 1];
end

% Realize with COMPREAL
[a,b,c,d] = compreal(num,D.den{1});
if ZeroTF
   c(:) = 0;
   d = 0;
end

% State-space object
Dss = ltipack.ssdata(a,b,c,d,[],D.Ts);

