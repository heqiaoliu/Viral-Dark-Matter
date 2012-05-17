function D = plus(D1,D2)
% Adds two ZPK models.

%   Copyright 1986-2010 The MathWorks, Inc.
%	 $Revision: 1.1.8.2 $  $Date: 2010/02/08 22:48:17 $

% Consolidate I/O delays (must match in CT)
if hasdelay(D1) || hasdelay(D2)
   ZeroIO1 = (D1.k==0);
   ZeroIO2 = (D2.k==0);
   [Delay,D1,D2,ElimFlag] = plusDelay(D1,D2,...
      struct('Input',all(ZeroIO1,1),'Output',all(ZeroIO1,2),'IO',ZeroIO1),...
      struct('Input',all(ZeroIO2,1),'Output',all(ZeroIO2,2),'IO',ZeroIO2));
   if ElimFlag
      ctrlMsgUtils.warning('Control:ltiobject:UseSSforInternalDelay')
   end
else
   Delay = D1.Delay;
end

% Compute resulting model
Ts = D1.Ts;
[ny,nu] = size(D1.k);
z = cell(ny,nu);
p = cell(ny,nu);
k = zeros(ny,nu);
for ct=1:ny*nu
   [z{ct},p{ct},k(ct)] = ...
      LocalAddSISO(D1.z{ct},D1.p{ct},D1.k(ct),D2.z{ct},D2.p{ct},D2.k(ct),Ts);
end

D = ltipack.zpkdata(z,p,k,Ts);
D.Delay = Delay;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [z,p,k] = LocalAddSISO(z1,p1,k1,z2,p2,k2,Ts)
%SISOPLUS  Addition of SISO ZPK models
% Discard dynamics when gain is zero
if k1==0,
   z1 = zeros(0,1);  p1 = zeros(0,1);
elseif k2==0,
   z2 = zeros(0,1);  p2 = zeros(0,1);
end

% Build SS representation of the SISO sum to compute zeros and gain
[a1,b1,c1,d1,e1] = zpkreal(z1,p1,k1);
[a2,b2,c2,d2,e2] = zpkreal(z2,p2,k2);
[a,b,c,d,e] = ssops('add',a1,b1,c1,d1,e1,a2,b2,c2,d2,e2);

% Compute dynamics
[z,p,k] = utSS2ZPK(a,b,c,d,e,Ts,[p1;p2]);
if k==0
   z = zeros(0,1);  p = zeros(0,1);
end
