function Dt = ctranspose(D)
% Pertransposition of ZPK models.

%   Author(s): A. Potvin, P. Gahinet
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:33:24 $
[ny,nu] = size(D.k);
if ny==0 || nu==0
   Dt = transpose(D); return
end
Dt = D;
Dt.Delay = transposeDelay(D);

z = D.z;
p = D.p;
k = D.k;
if D.Ts==0,
   % Continuous-time case: replace s by -s
   for j=1:ny*nu,
      z{j} = -sort(conj(z{j}));
      p{j} = -sort(conj(p{j}));
      dl = length(p{j}) - length(z{j});
      if mod(dl,2),  
          k(j) = -k(j);  
      end
      k(j) = conj(k(j));
   end
else
   % Discrete-time case: replace z by z^-1
   for j=1:ny*nu,
      zj = sort(conj(z{j}));   
      pj = sort(conj(p{j}));
      idz = find(zj==0);   zj(idz) = [];
      idp = find(pj==0);   pj(idp) = [];
      k(j) = conj(k(j)) * prod(-zj) / prod(-pj);
      zj = 1./zj;  
      pj = 1./pj;
      zpow = length(idp) + length(pj) - (length(idz) + length(zj));
      z{j} = [zj ; zeros(zpow,1)];
      p{j} = [pj ; zeros(-zpow,1)];
   end
end
Dt.z = z';
Dt.p = p';
Dt.k = k.';
