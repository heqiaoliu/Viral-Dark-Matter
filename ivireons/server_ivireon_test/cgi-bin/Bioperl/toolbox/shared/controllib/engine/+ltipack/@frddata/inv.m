function Dinv = inv(D)
% Computes inv(D)

%   Copyright 1986-2010 The MathWorks, Inc.
%	 $Revision: 1.1.8.2 $  $Date: 2010/02/08 22:46:55 $
% RE: no input or output delays, square system
[ny,nu,nf] = size(D.Response);
if ny==0 || nu==0
   Dinv = transpose(D);
elseif hasdelay(D)
   ctrlMsgUtils.error('Control:transformation:inv1')
else
   Dinv = D;
   sw = ctrlMsgUtils.SuspendWarnings; %#ok<NASGU>
   for ct=1:nf
      m = inv(D.Response(:,:,ct));
      if hasInfNaN(m)
         Dinv.Response(:,:,ct) = Inf;
      else
         Dinv.Response(:,:,ct) = m;
      end
   end
end
