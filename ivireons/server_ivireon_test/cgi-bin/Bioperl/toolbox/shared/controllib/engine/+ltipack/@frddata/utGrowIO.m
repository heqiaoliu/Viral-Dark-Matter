function D = utGrowIO(D,ny,nu)
% Grows I/O size of FRD model.

%   Copyright 1986-2003 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:30:04 $
[ny0,nu0,junk] = size(D.Response);
if ny>ny0 || nu>nu0
   D.Response(ny,nu,1:length(D.Frequency)) = 0;
   % Delays
   D.Delay.IO(ny,nu) = 0;
   if nu>nu0
      D.Delay.Input(nu0+1:nu,:) = NaN;
   end
   if ny>ny0
      D.Delay.Output(ny0+1:ny,:) = NaN;
   end
end