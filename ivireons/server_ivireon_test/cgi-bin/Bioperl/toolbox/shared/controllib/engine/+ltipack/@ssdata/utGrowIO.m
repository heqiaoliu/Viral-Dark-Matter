function D = utGrowIO(D,ny,nu)
% Grows I/O size of SS model.

%   Copyright 1986-2007 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:32:04 $
[ny0,nu0] = iosize(D);
if ny>ny0 || nu>nu0
   nx = size(D.a,1);
   [rs,cs] = size(D.d);
   if nu>nu0
      % Resize B, D, and input delay
      D.b = [D.b(:,1:nu0) , zeros(nx,nu-nu0) , D.b(:,nu0+1:cs)];
      D.Delay.Input(nu0+1:nu,:) = NaN;
   end
   if ny>ny0
      % Resize C, D, and output delay
      D.c = [D.c(1:ny0,:) ; zeros(ny-ny0,nx) ; D.c(ny0+1:rs,:)];
      D.Delay.Output(ny0+1:ny,:) = NaN;
   end
   D.d = [D.d(1:ny0,1:nu0) zeros(ny0,nu-nu0) D.d(1:ny0,nu0+1:cs);...
             zeros(ny-ny0,nu+cs-nu0);...
             D.d(ny0+1:rs,1:nu0) zeros(rs-ny0,nu-nu0) D.d(ny0+1:rs,nu0+1:cs)];
end
