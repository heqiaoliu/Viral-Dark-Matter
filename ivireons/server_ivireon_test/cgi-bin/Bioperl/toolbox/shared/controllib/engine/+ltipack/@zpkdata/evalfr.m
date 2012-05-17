function fr = evalfr(D,s)
%EVALFR  Evaluates frequency response at a single (complex) frequency.

%   Author(s):  P. Gahinet  5-13-96
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:33:30 $
[ny,nu] = size(D.k);
fr = zeros(ny,nu);
Td = getIODelay(D,'total');  % total I/O delays

if isnan(s)
   fr(:) = NaN;
elseif isinf(s)
   for ct=1:ny*nu
      reldeg = length(D.z{ct})-length(D.p{ct});
      if D.k(ct)==0 || reldeg<0
         fr(ct) = 0;
      elseif reldeg>0
         fr(ct) = Inf;
      elseif Td(ct)~=0
         fr(ct) = NaN;
      else
         fr(ct) = D.k(ct);
      end
   end
else
   % Response at finite point
   for ct=1:ny*nu
      zs = s - D.z{ct};
      ps = s - D.p{ct};
      if any(ps==0)
         fr(ct) = Inf;
      elseif ~any(zs==0)
         % RE: Beware of overflow in prod(zs) or prod(ps)
         fr(ct) = D.k(ct) * pow2(sum(log2(zs)) - sum(log2(ps)));
      end
   end
   if any(Td(:))
      if D.Ts~=0
         fr = s.^(-Td) .* fr;
      else
         fr = exp(-s*Td) .* fr;
      end
   end
   if isreal(s) && isreal(D)
      fr = real(fr);
   end
end
