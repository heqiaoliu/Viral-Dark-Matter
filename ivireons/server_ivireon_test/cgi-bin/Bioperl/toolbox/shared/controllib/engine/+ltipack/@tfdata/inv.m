function Dinv = inv(D)
% Computes inv(D)

%   Copyright 1986-2008 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:32:41 $
% RE: no input or output delays, square system
[ny,nu] = size(D.num);
if ny==0 || nu==0
   Dinv = transpose(D);
elseif hasdelay(D)
   ctrlMsgUtils.error('Control:transformation:inv1')
elseif ny==1
   % SISO system w/o delays
   Dinv = D;
   if all(D.num{1}==0)
      % INV(0) is NaN
      ctrlMsgUtils.warning('Control:ltiobject:SingularDescriptor')
      Dinv.num = {NaN};
      Dinv.den = {1};
   else
      Dinv.num = D.den;
      Dinv.den = D.num;
   end
else
   % Convert to state-space
   try
      Dinv = tf(inv(ss(D)));
   catch E
      throw(E)
   end
end
