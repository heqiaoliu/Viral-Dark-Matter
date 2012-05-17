function boo = hasDelayDynamics(D,pzflag)
% Checks if dynamics (poles, zeros, or both) depend on the internal delays.
%
%   TF = HASDELAYDYNAMICS(D) checks if the poles or zeros depend on the
%   delays.
%
%   TF = HASDELAYDYNAMICS(D,'pole') checks if the poles depend on the delays.
%
%   TF = HASDELAYDYNAMICS(D,'zero') checks if the transmission zeros depend 
%   on the delays.

%   Copyright 1986-2005 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:31:10 $
boo = false;
if hasInternalDelay(D)
   % Sizes
   [rs,cs] = size(D.d);
   iDelay = D.Delay.Internal;
   nfd = length(iDelay);
   nu = cs-nfd;
   ny = rs-nfd;
   % Ignore zero internal delays
   isp = find(iDelay>0);
   b2 = D.b(:,nu+isp);
   c2 = D.c(ny+isp,:);
   d22 = D.d(ny+isp,nu+isp);
      
   % Check if poles are delay independent (e.g., 1+exp(-tau*s))
   if nargin==1 || strncmpi(pzflag,'p',1)
      % Determine hard zeros in H22(s)
      xkeep = iosmreal(D.a,b2,c2,D.e);
      nzH22 = (d22~=0 | reshape(any(xkeep,1),size(d22)));
      boo = ~isNilpotent(nzH22);
   end

   % Check if zeros are delay independent (e.g., (s-1)/(1-exp(-tau*s))
   if (~boo && nargin==1) || strncmpi(pzflag,'z',1)
      % Solid sufficient condition lacking here
      if ny<=1 && nu<=1
         % SISO case: check if all delays enter linearly
         boo = hasInfNaN(getIODelay(D));
      else
         % Sufficient condition: [D11(theta) C1(theta);B1(theta) A(theta)-sE]
         % is independent of theta
         boo = ~isempty(smreal(d22,[D.d(ny+isp,1:nu),c2],[D.d(1:ny,nu+isp);b2],[]));
      end
   end
end
