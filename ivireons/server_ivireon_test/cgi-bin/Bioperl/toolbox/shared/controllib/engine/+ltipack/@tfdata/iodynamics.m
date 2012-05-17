function [z,p,k] = iodynamics(D)
% Computes the s-minimal set of poles and zeros for each I/O transfer
% (with all delays set to zero).

%   Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/11/09 16:32:43 $
[ny,nu] = size(D.den);
p = cell(ny,nu);
z = cell(ny,nu);
k = zeros(ny,nu);
for ct=1:ny*nu
   n = D.num{ct};
   d = D.den{ct};
   % poles and zeros
   if all(isfinite(n))
      z{ct} = roots(n);
      p{ct} = roots(d);
      % gain = ratio of leading num/den coefficients
      idxnum = find(n);
      idxden = find(d);
      if ~isempty(idxnum)
         k(ct) = n(idxnum(1))/d(idxden(1));
      end
   else
      % Beware that roots(NaN) = error
      z{ct} = zeros(0,1);
      p{ct} = zeros(0,1);
      k(ct) = NaN;
   end
end
