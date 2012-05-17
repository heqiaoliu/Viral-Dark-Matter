function D1 = plus(D1,D2)
% Adds two state-space models.

%   Copyright 1986-2010 The MathWorks, Inc.
%	 $Revision: 1.1.8.3 $  $Date: 2010/03/31 18:36:20 $
[ny,nu] = iosize(D1);

% Fold in non-matching delays at the inputs or outputs
if hasdelay(D1) || hasdelay(D2)
   [Delay,D1,D2] = plusDelay(D1,D2,...
      struct('Input',all([D1.b(:,1:nu);D1.d(:,1:nu)]==0,1),...
             'Output',all([D1.c(1:ny,:),D1.d(1:ny,:)]==0,2)),...
      struct('Input',all([D2.b(:,1:nu);D2.d(:,1:nu)]==0,1),...
             'Output',all([D2.c(1:ny,:),D2.d(1:ny,:)]==0,2)));
else
   Delay = D1.Delay;
end

% Sizes
nfd1 = length(D1.Delay.Internal);
nfd2 = length(D2.Delay.Internal);
nx1 = size(D1.a,1);
nx2 = size(D2.a,1);

% Compute realization for sum
D1.a = [D1.a zeros(nx1,nx2) ; zeros(nx2,nx1) D2.a];
D1.e = utBlkDiagE(D1.e,D2.e,nx1,nx2);
if nfd1==0 && nfd2==0
   % No internal delays
   D1.b = [D1.b ; D2.b];
   D1.c = [D1.c , D2.c];
   D1.d = D1.d + D2.d;
else
   D1.b = [[D1.b(:,1:nu) ; D2.b(:,1:nu)] , ...
         blkdiag(D1.b(:,nu+1:nu+nfd1),D2.b(:,nu+1:nu+nfd2))];
   D1.c = [[D1.c(1:ny,:) , D2.c(1:ny,:)] ;...
         blkdiag(D1.c(ny+1:ny+nfd1,:),D2.c(ny+1:ny+nfd2,:))];
   D1.d = [D1.d(1:ny,1:nu)+D2.d(1:ny,1:nu) , ...
         [D1.d(1:ny,nu+1:nu+nfd1),D2.d(1:ny,nu+1:nu+nfd2)] ; ...
         [D1.d(ny+1:ny+nfd1,1:nu);D2.d(ny+1:ny+nfd2,1:nu)] , ...
         blkdiag(D1.d(ny+1:ny+nfd1,nu+1:nu+nfd1),D2.d(ny+1:ny+nfd2,nu+1:nu+nfd2))];
end
D1.Scaled = false;

D1.Delay = Delay;
if ~(isempty(D1.StateName) && isempty(D2.StateName))
   D1.StateName = [ltipack.fullstring(D1.StateName,nx1) ; ltipack.fullstring(D2.StateName,nx2)];
end
if ~(isempty(D1.StateUnit) && isempty(D2.StateUnit))
   D1.StateUnit = [ltipack.fullstring(D1.StateUnit,nx1) ; ltipack.fullstring(D2.StateUnit,nx2)];
end

