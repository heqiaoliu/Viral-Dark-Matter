function D = utGrowIO(D,ny,nu)
% Grows I/O size of TF model.

%   Copyright 1986-2003 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:33:13 $
[ny0,nu0] = size(D.num);
if ny>ny0 || nu>nu0
   num = cell(ny,nu);  num(:) = {0};
   den = cell(ny,nu);  den(:) = {1};
   num(1:ny0,1:nu0) = D.num;
   den(1:ny0,1:nu0) = D.den;
   D.num = num;
   D.den = den;
   % Delays
   D.Delay.IO(ny,nu) = 0;
   if nu>nu0
      D.Delay.Input(nu0+1:nu,:) = NaN;
   end
   if ny>ny0
      D.Delay.Output(ny0+1:ny,:) = NaN;
   end
end