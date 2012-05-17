function [a,b1,b2,c1,c2,d11,d12,d21,d22,e] = getBlockData(D)
% Extract state-space equation matrices.

%   Copyright 1986-2007 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:31:05 $
a = D.a;
b = D.b;
c = D.c;
d = D.d;
e = D.e;
nx = size(a,1);
if nargout<10
   % Explicit form
   if ~isempty(e)
      % Absorb E into A,B
      ab = e\[a,b];
      if hasInfNaN(ab)
          ctrlMsgUtils.error('Control:ltiobject:getBlockData1')
      end
      a = ab(:,1:nx);
      b = ab(:,nx+1:end);
   end
else
   % Descriptor form. Set E=I if empty
   if isempty(e)
      e = eye(nx);
   end
end

% Dimensions
nfd = length(D.Delay.Internal);
[rs,cs] = size(d);
nu = cs-nfd;
ny = rs-nfd;

% Partition matrices
b1 = b(:,1:nu);
b2 = b(:,nu+1:cs);
c1 = c(1:ny,:);
c2 = c(ny+1:rs,:);
d11 = d(1:ny,1:nu);
d12 = d(1:ny,nu+1:cs);
d21 = d(ny+1:rs,1:nu);
d22 = d(ny+1:rs,nu+1:cs);
