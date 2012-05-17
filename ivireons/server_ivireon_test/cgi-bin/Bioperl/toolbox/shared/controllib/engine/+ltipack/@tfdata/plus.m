function D = plus(D1,D2)
% Adds two transfer functions.

%   Copyright 1986-2010 The MathWorks, Inc.
%	 $Revision: 1.1.8.2 $  $Date: 2010/02/08 22:48:06 $

% Consolidate I/O delays (must match in CT)
if hasdelay(D1) || hasdelay(D2)
   ZeroIO1 = cellfun(@localIsZero,D1.num);
   ZeroIO2 = cellfun(@localIsZero,D2.num);
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
[ny,nu] = size(D1.num);
num = cell(ny,nu);
den = cell(ny,nu);
for ct=1:ny*nu
   [num{ct},den{ct}] = utAddSISO(D1.num{ct},D1.den{ct},D2.num{ct},D2.den{ct});
end
% Eliminate leading zeros generated, e.g., in s^2+s
[num,den] = utRemoveLeadZeros(num,den);

D = ltipack.tfdata(num,den,D1.Ts);
D.Delay = Delay;


function boo = localIsZero(x)
boo = all(x==0);
