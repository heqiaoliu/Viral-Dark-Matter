function [num,den] = randND(nz,np,Ts)
% Random sampling of block parameters.

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2010/04/11 20:29:27 $
wp = 10.^(2*rand(1,np)-1);
wz = 10.^(2*rand(1,nz)-1);
g = 10^(2*rand-1);
if Ts==0
   num = g * poly(-wz);
   den = poly(-wp);   % Enforce unit DC gain
else
   fs = pi/50;
   num = g * poly(exp(-wz*fs));
   den = poly(exp(-wp*fs));
end
