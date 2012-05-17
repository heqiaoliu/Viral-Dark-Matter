function Dm = mpower(D,m)
% Integer powers of ZPK models.
% Note: m can be positive or negative.

%   Author(s): P. Gahinet, 1-98
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:33:46 $
M = abs(m);
Dm = D;
if m==0
   n = size(D.k,1);
   Dm.z(:) = {zeros(0,1)};
   Dm.p(:) = {zeros(0,1)};
   Dm.k = eye(n);
   Dm.Delay.Input = zeros(n,1);
   Dm.Delay.Output = zeros(n,1);
   Dm.Delay.IO = zeros(n);
elseif isscalar(D.k)
   % SISO case
   Dm.z{1} = repmat(D.z{1},M,1);
   Dm.p{1} = repmat(D.p{1},M,1);
   Dm.k = D.k^M;
   Dm.Delay.IO = M*D.Delay.IO + (M-1)*(D.Delay.Input+D.Delay.Output);
   % Invert result if m<0
   if m<0
      Dm = inv(Dm);
   end 
elseif m~=1
   % MIMO case: go to state space for efficiency and accuracy
   Dm = zpk(mpower(ss(D),m));
end
