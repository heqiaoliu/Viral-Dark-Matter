function fr = evalfr(D,s)
%EVALFR  Evaluates frequency response at a single (complex) frequency.

%   Author(s):  P. Gahinet  5-13-96
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:32:35 $
[ny,nu] = size(D.num);
fr = zeros(ny,nu);
Td = getIODelay(D,'total');  % total I/O delays
if isnan(s)
   fr(:) = NaN;
elseif isinf(s)
   for ct=1:ny*nu
      if D.den{ct}(1)==0
         fr(ct) = Inf;
      elseif Td(ct)~=0 && D.num{ct}(1)~=0
         fr(ct) = NaN;
      else
         fr(ct) = D.num{ct}(1)/D.den{ct}(1);
      end
   end
else
   % Response at finite point
   for ct=1:ny*nu
      Denom = polyval(D.den{ct},s);
      if Denom==0
         fr(ct) = Inf;
      else
         fr(ct) = polyval(D.num{ct},s) / Denom;
      end
   end
   if any(Td(:))
      if D.Ts
         fr = s.^(-Td) .* fr;
      else
         fr = exp(-s*Td) .* fr;
      end
   end
end
