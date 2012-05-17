function D = pade(D,Ni,No,Nio)
% Pade approximation of delays in FRD models.

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:33:49 $
if ~hasdelay(D)
   return
end
Delay = D.Delay;
[ny,nu] = size(D.k);

% Check arguments
[Ni,No,Nio] = checkPadeOrders(D,Ni,No,Nio);

% Approximate delays
IsAppx = (isfinite(Nio) & Delay.IO>0);
if any(IsAppx(:))
   for j=1:nu,
      for i=1:ny,
         if IsAppx(i,j) && Nio(i,j)>0
            [zio,pio,kio] = pade(Delay.IO(i,j),Nio(i,j));
            D.z{i,j} = [D.z{i,j} ; zio];
            D.p{i,j} = [D.p{i,j} ; pio];
            D.k(i,j) = D.k(i,j) * kio;
         end
      end
   end
   Delay.IO(IsAppx) = 0;
end

idx = find(isfinite(Ni) & Delay.Input>0);
for ct=1:length(idx)
   j = idx(ct);
   if Ni(j)>0
      [zi,pi,ki] = pade(Delay.Input(j),Ni(j));
      for i=1:ny,
         D.z{i,j} = [D.z{i,j} ; zi];
         D.p{i,j} = [D.p{i,j} ; pi];
         D.k(i,j) = D.k(i,j) * ki;
      end
   end
end
Delay.Input(idx,:) = 0;

idx = find(isfinite(No) & Delay.Output>0);
for ct=1:length(idx)
   i = idx(ct);
   if No(i)>0
      [zo,po,ko] = pade(Delay.Output(i),No(i));
      for j=1:nu,
         D.z{i,j} = [D.z{i,j} ; zo];
         D.p{i,j} = [D.p{i,j} ; po];
         D.k(i,j) = D.k(i,j) * ko;
      end
   end
end
Delay.Output(idx,:) = 0;

D.Delay = Delay;
