function Dm = mpower(D,m)
% Integer powers of FRD models.
% Note: m can be positive or negative.

%   Author(s): P. Gahinet
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:29:41 $
Dm = D;
[n,n,nf] = size(D.Response);
if m==0
   Dm.Response = repmat(eye(n),[1 1 nf]);
   Dm.Delay.Input = zeros(n,1);
   Dm.Delay.Output = zeros(n,1);
   Dm.Delay.IO = zeros(n);
else
   % General case: perform M-1 products
   for j=2:abs(m),
      Dm = mtimes(Dm,D);
   end
   % Invert result if m<0
   if m<0
      Dm = inv(Dm);
   end
end
