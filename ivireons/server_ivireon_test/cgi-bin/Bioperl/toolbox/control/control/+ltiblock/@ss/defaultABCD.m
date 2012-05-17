function [a,b,c,d] = defaultABCD(Astruct,nx,ny,nu,Ts)
% Default initialization of block parameters.

%   Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:25:07 $
d = zeros(ny,nu);
if nx==0
   a = [];  b = zeros(0,nu);  c = zeros(ny,0);
elseif Ts==0
   w = logspace(-1,2,nx).';
   if strcmp(Astruct(1),'c')
      % Companion
      p = poly(-w);
      a = balance([-p(:,2:nx+1) ; eye(nx-1,nx)]);
      b = eye(nx,nu);
      c = ones(ny,nx);
   else
      % Use sum(wj/(s+wj))
      a = diag(-w);
      sw = sqrt(w);
      b = repmat(sw,[1 nu]);
      c = repmat(sw.',[ny 1]);
   end
else
   Ts = abs(Ts);
   lnf = log10(pi/Ts);
   w = logspace(lnf-2,lnf-0.5,nx).';
   z = exp(-w*Ts);
   if strcmp(Astruct(1),'c')
      % Companion
      p = poly(z);
      a = balance([-p(:,2:nx+1) ; eye(nx-1,nx)]);
      b = eye(nx,nu);
      c = ones(ny,nx);
   else
      % Use sum((1-exp(-wj*Ts))/(z-exp(-wj*Ts))
      a = diag(z);
      sw = sqrt(1-z);
      b = repmat(sw,[1 nu]);
      c = repmat(sw.',[ny 1]);
   end      
end