function [g,factor,power] = dcgain(D)
% Computes DC gain and DC equivalent

%   Author(s): P. Gahinet
%   Copyright 1986-2005 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:32:32 $
[ny,nu] = size(D.num);
g = zeros(ny,nu);
factor = zeros(ny,nu);
power = zeros(ny,nu);

% Tolerance
if nargout<2
   tol = 0;  % hard zeros required
else
   tol = sqrt(eps); % for dc equivalent computation
end

for ct=1:ny*nu
   n = D.num{ct};
   d = D.den{ct};
   if any(n),
      % Find number of roots at s=0 or z=1 in num and den
      if D.Ts==0,
         in = find(n);
         zn = length(n) - in(end);
         id = find(d);
         zd = length(d) - id(end);
         % G(ct) ~ f * s^m  as s-> 0
         m = zn - zd;
         f = n(in(end))/d(id(end));
      else
         zn = 0;
         while ~isempty(n) && abs(sum(n))<=tol*max(abs(n))
            zn = zn + 1;
            % remove root at z=1
            n = fliplr(filter(-1,[1 -1],fliplr(n(2:end))));
         end
         zd = 0;
         while ~isempty(d) && abs(sum(d))<=tol*max(abs(d))
            zd = zd + 1;
            d = fliplr(filter(-1,[1 -1],fliplr(d(2:end))));
         end
         % G(ct) ~ f * (z-1)^m  as z->1
         m = zn - zd;
         f = sum(n)/sum(d);
      end
      
      % Set value of G(ct) and dceq(ct)
      if m<0,
         g(ct) = Inf;
      elseif m>0,
         g(ct) = 0;
      else
         g(ct) = f;
      end
      factor(ct) = f;
      power(ct) = m;
   end
end  % end for

