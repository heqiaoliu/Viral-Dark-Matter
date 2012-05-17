function D = augstate(D)
% Appends states as outputs.

%   Copyright 1986-2008 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:30:40 $
nx = size(D.a,1);
nfd = length(D.Delay.Internal);
if nfd==0
   % No internal delays
   D.c = [D.c ; eye(nx)];
   D.d = [D.d ; zeros(nx,size(D.d,2))];
else
   [rs,cs] = size(D.d);
   ny = rs-nfd;
   D.c = [D.c(1:ny,:) ; eye(nx) ; D.c(ny+1:rs,:)];
   D.d = [D.d(1:ny,:) ; zeros(nx,cs) ; D.d(ny+1:rs,:)];
end
D.Delay.Output = [D.Delay.Output ; zeros(nx,1)];
D.Scaled = false;
