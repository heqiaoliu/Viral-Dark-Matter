function A = loadbalance(A)
%LOADBALANCE  Permute columns of codistributed array
%   A = loadbalance(A)
%   The columns of A are grouped into numlabs equal-sized panels
%   on each processor.  These panels are exchanged between processors
%   to produce a column ordering that balances the computational
%   load for triangular factorizations like LU and QR.
%   The function is its own inverse.

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:57:25 $

s = size(A);
aDist = getCodistributor(A);
d = aDist.Dimension;
Aloc = getLocalPart(A);
n = s(2);
np = numlabs;
w = floor(n/np^2);
nloc = size(Aloc,2);
mwTag1 = 31642;
mwTag2 = 31643;
for p = 1:np
   for r = p+1:np
      if p == labindex
         j = nloc - (np+1-r)*w + (1:w);
         T = Aloc(:,j);
         Aloc(:,j) = labReceive(r,mwTag1);
         labSend(T,r,mwTag2);
      elseif r == labindex
         j = (p-1)*w + (1:w);
         labSend(Aloc(:,j),p,mwTag1);
         Aloc(:,j) = labReceive(p,mwTag2);
      end
   end
end
A = codistributed.build(Aloc,codistributor('1d',d), 'obsolete:matchLocalParts');
