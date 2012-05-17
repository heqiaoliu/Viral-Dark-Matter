function Dm = mpower(D,m)
% Integer powers of state-space models.
% Note: m can be positive or negative.

%   Author(s): P. Gahinet, 1-98
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:31:28 $
if m==0
   [~,nio] = iosize(D);
   Dm = ltipack.ssdata([],zeros(0,nio),zeros(nio,0),eye(nio),[],D.Ts);
else
   % General case: perform M-1 products
   Dm = D;
   for j=2:abs(m),
      Dm = mtimes(Dm,D);
   end
   % Invert result if m<0
   if m<0
      Dm = inv(Dm);
   end
end
