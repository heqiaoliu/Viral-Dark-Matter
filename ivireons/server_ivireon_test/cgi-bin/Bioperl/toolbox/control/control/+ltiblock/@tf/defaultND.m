function [num,den] = defaultND(nz,np,Ts)
% Default initialization of block parameters.

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2010/04/11 20:29:26 $

% Pick pole frequencies
if np==0
   wp = zeros(1,0);
else
   wp = logspace(-1,1,np);
end

% Pick zero frequencies
if nz==0
   wz = zeros(1,0);
else
   wz = sqrt(wp(1:np-1).*wp(2:np));
   wz = wz(1:min(nz,np-1));   % zero feedthrough
end

if Ts==0
   num = poly(-wz);
   den = poly(-wp);
   % Enforce unit DC gain
   num = (den(np+1)/num(end)) * num;
else
   fs = pi/50; 
   num = poly(exp(-wz*fs));
   den = poly(exp(-wp*fs));
   % Enforce unit DC gain
   num = (sum(den)/sum(num)) * num;
end

if nz==np
   % Set feedthrough to zero to avoid offset in LFT models
   num = [0 num(1:nz)];
end
