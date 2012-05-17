function D = pade(D,Ni,No,Nio)
% Pade approximation of delays in FRD models.

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:32:54 $
if ~hasdelay(D)
   return
end
Delay = D.Delay;
[ny,nu] = size(D.num);

% Check arguments
[Ni,No,Nio] = checkPadeOrders(D,Ni,No,Nio);

% Approximate delays
IsAppx = (isfinite(Nio) & Delay.IO>0);
if any(IsAppx(:))
   for j=1:nu,
      for i=1:ny,
         if IsAppx(i,j) && Nio(i,j)>0
            [npio,dpio] = pade(Delay.IO(i,j),Nio(i,j));
            D.num{i,j} = conv(D.num{i,j},npio);
            D.den{i,j} = conv(D.den{i,j},dpio);
         end
      end
   end
   Delay.IO(IsAppx) = 0;
end

idx = find(isfinite(Ni) & Delay.Input>0);
for ct=1:length(idx)
   j = idx(ct);
   if Ni(j)>0
      [npi,dpi] = pade(Delay.Input(j),Ni(j));
      for i=1:ny,
         D.num{i,j} = conv(D.num{i,j},npi);
         D.den{i,j} = conv(D.den{i,j},dpi);
      end
   end
end
Delay.Input(idx,:) = 0;

idx = find(isfinite(No) & Delay.Output>0);
for ct=1:length(idx)
   i = idx(ct);
   if No(i)>0
      [npo,dpo] = pade(Delay.Output(i),No(i));
      for j=1:nu,
         D.num{i,j} = conv(D.num{i,j},npo);
         D.den{i,j} = conv(D.den{i,j},dpo);
      end
   end
end
Delay.Output(idx,:) = 0;

D.Delay = Delay;