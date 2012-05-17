function D = exp(D)
% Computes exp(-M*s) (entry-wise) for M>=0

%   Copyright 1986-2009 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:33:31 $

if hasdelay(D)
    ctrlMsgUtils.error('Control:transformation:exp2')
end

% Compute the static gain exp(A) and the I/O delays -B;
[ny,nu] = size(D.k);
iod = zeros(ny,nu);
for ct=1:ny*nu
   z = D.z{ct};
   k = D.k(ct);
   lz = length(z);
   switch lz
      case 0
         if k~=0
             ctrlMsgUtils.error('Control:transformation:exp2')
         else
            iod(ct) = 0;
         end
      case 1
         if z~=0
             ctrlMsgUtils.error('Control:transformation:exp2')
         else
            iod(ct) = -k;
         end
      otherwise
          ctrlMsgUtils.error('Control:transformation:exp2')
   end
   D.z{ct} = zeros(0,1);
   D.k(ct) = 1;
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
