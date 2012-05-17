function D = utGrowIO(D,ny,nu)
% Grows I/O size of ZPK model.

%   Copyright 1986-2003 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:34:07 $
[ny0,nu0] = size(D.k);
if ny>ny0 || nu>nu0
   z = cell(ny,nu);  z(:) = {zeros(0,1)};
   p = cell(ny,nu);  p(:) = {zeros(0,1)};
   z(1:ny0,1:nu0) = D.z;
   p(1:ny0,1:nu0) = D.p;
   D.z = z;
   D.p = p;
   D.k(ny,nu) = 0;
   % Delays
   D.Delay.IO(ny,nu) = 0;
   if nu>nu0
      D.Delay.Input(nu0+1:nu,:) = NaN;
   end
   if ny>ny0
      D.Delay.Output(ny0+1:ny,:) = NaN;
   end
end