function boo = isExplicitODE(D)
% Checks whether DDAE can be reduced to ODE.

%	 Author: P. Gahinet
%   Copyright 1986-2006 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:31:17 $
boo = true;
nfd = length(D.Delay.Internal);
if nfd>0
   % Has internal delays
   [rs,cs] = size(D.d);
   nu = cs-nfd;
   ny = rs-nfd;
   b2 = D.b(:,nu+1:cs);
   c2 = D.c(ny+1:rs,:);
   d22 = D.d(ny+1:rs,nu+1:cs);
   nx = size(b2,1);
   boo = isNilpotent(d22~=0) && (nx==0 || isempty(smreal(d22,c2,b2,[])));
end
