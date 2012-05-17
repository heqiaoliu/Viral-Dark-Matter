function D = exp(D)
% Computes exp(-M*s) (entrywise) for M>=0

%   Copyright 1986-2007 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:32:36 $

if hasdelay(D)
    ctrlMsgUtils.error('Control:transformation:exp2')
end

% Compute the I/O delays M;
[ny,nu] = size(D.num);
iod = zeros(ny,nu);
for ct=1:ny*nu
   num = D.num{ct};
   den = D.den{ct};
   ln = length(num);
   switch ln
      case 1
         if num~=0
             ctrlMsgUtils.error('Control:transformation:exp2')
         else
            iod(ct) = 0;
         end
      case 2
         if num(2)~=0 || den(1)~=0
             ctrlMsgUtils.error('Control:transformation:exp2')
         else
            iod(ct) = -num(1)/den(2);
         end
      otherwise
          ctrlMsgUtils.error('Control:transformation:exp2')
   end
   D.num{ct} = 1;
   D.den{ct} = 1;
end

% Check causality
if any(iod(:)<0)
    ctrlMsgUtils.error('Control:transformation:exp3')
end
   
% Factor out input and output delays (minimizing overall number of
% channel delays)
if ny<=nu
   od = min(iod,[],2);
   iod = iod - repmat(od,[1 nu]);
   id = min(iod,[],1);
   iod = iod - repmat(id,[ny 1]);
else
   id = min(iod,[],1);
   iod = iod - repmat(id,[ny 1]);
   od = min(iod,[],2);
   iod = iod - repmat(od,[1 nu]);
end

% Update delays
D.Delay.Input = id(:);
D.Delay.Output = od;
D.Delay.IO = iod;
