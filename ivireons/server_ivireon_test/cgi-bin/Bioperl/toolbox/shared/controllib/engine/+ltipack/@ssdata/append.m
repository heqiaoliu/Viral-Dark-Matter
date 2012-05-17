function D1 = append(D1,D2)
% Appends inputs and outputs of two models.

%   Copyright 1986-2010 The MathWorks, Inc.
%	 $Revision: 1.1.8.2 $  $Date: 2010/03/31 18:36:14 $

% Sizes
nfd1 = length(D1.Delay.Internal);
nfd2 = length(D2.Delay.Internal);
nx1 = size(D1.a,1);
nx2 = size(D2.a,1);

% Compute realization for concatenation
D1.a = [D1.a zeros(nx1,nx2) ; zeros(nx2,nx1) D2.a];
D1.e = utBlkDiagE(D1.e,D2.e,nx1,nx2);
if nfd1==0 && nfd2==0
   % No internal delays
   [ny1,nu1] = size(D1.d);
   [ny2,nu2] = size(D2.d);
   D1.b = [D1.b zeros(nx1,nu2) ; zeros(nx2,nu1) D2.b];
   D1.c = [D1.c zeros(ny1,nx2) ; zeros(ny2,nx1) D2.c];
   D1.d = [D1.d zeros(ny1,nu2); zeros(ny2,nu1) D2.d];
else
   % Account for internal delays
   [rs1,cs1] = size(D1.d);
   [rs2,cs2] = size(D2.d);
   ny1 = rs1-nfd1;  nu1 = cs1-nfd1;
   ny2 = rs2-nfd2;  nu2 = cs2-nfd2;
   D1.b = [blkdiag(D1.b(:,1:nu1),D2.b(:,1:nu2)) ,...
         blkdiag(D1.b(:,nu1+1:cs1),D2.b(:,nu2+1:cs2))];
   D1.c = [blkdiag(D1.c(1:ny1,:),D2.c(1:ny2,:)) ;...
         blkdiag(D1.c(ny1+1:rs1,:),D2.c(ny2+1:rs2,:))];
   D1.d = [blkdiag(D1.d(1:ny1,1:nu1),D2.d(1:ny2,1:nu2)) , ...
         blkdiag(D1.d(1:ny1,nu1+1:cs1),D2.d(1:ny2,nu2+1:cs2)) ; ...
         blkdiag(D1.d(ny1+1:rs1,1:nu1),D2.d(ny2+1:rs2,1:nu2)) , ...
         blkdiag(D1.d(ny1+1:rs1,nu1+1:cs1),D2.d(ny2+1:rs2,nu2+1:cs2))];
end
D1.Scaled = false;

% Delays and state info
D1.Delay = appendDelay(D1,D2);
if nx2>0 % performance optimization
   if ~(isempty(D1.StateName) && isempty(D2.StateName))
      D1.StateName = [ltipack.fullstring(D1.StateName,nx1) ; ltipack.fullstring(D2.StateName,nx2)];
   end
   if ~(isempty(D1.StateUnit) && isempty(D2.StateUnit))
      D1.StateUnit = [ltipack.fullstring(D1.StateUnit,nx1) ; ltipack.fullstring(D2.StateUnit,nx2)];
   end
end