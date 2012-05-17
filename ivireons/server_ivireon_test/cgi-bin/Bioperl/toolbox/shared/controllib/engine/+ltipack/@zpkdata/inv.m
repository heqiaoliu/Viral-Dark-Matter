function Dinv = inv(D)
% Computes inv(D)

%   Copyright 1986-2008 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:33:36 $

% RE: no input or output delays, square system
[ny,nu] = size(D.k);
if ny==0 || nu==0
   Dinv = transpose(D);
elseif hasdelay(D)
   ctrlMsgUtils.error('Control:transformation:inv1')
elseif ny==1
   % SISO system w/o delays
   Dinv = D;
   if D.k==0
      % INV(0) is NaN
      ctrlMsgUtils.warning('Control:ltiobject:SingularDescriptor')
      Dinv.z = {zeros(0,1)};
      Dinv.p = {zeros(0,1)};
      Dinv.k = NaN;
   else
      Dinv.z = D.p;
      Dinv.p = D.z;
      Dinv.k = 1/D.k;
   end
else
   % Convert to state-space
   try
      Dinv = zpk(inv(ss(D)));
   catch E
      throw(E)
   end
end
