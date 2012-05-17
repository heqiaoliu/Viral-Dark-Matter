function D1 = iocat(dim,D1,D2)
% Concatenates models along input (2) or output (1) dimension.

%   Copyright 1986-2010 The MathWorks, Inc.
%	 $Revision: 1.1.8.3 $  $Date: 2010/03/31 18:36:17 $

% Map non-matching portion of codimension delays to internal delays  
[Delay,D1,D2] = catDelay(D1,D2,dim);

% Sizes
nfd1 = length(D1.Delay.Internal);
nfd2 = length(D2.Delay.Internal);
nx1 = size(D1.a,1);
nx2 = size(D2.a,1);

% Compute realization for concatenation
D1.a = [D1.a zeros(nx1,nx2) ; zeros(nx2,nx1) D2.a];
D1.e = utBlkDiagE(D1.e,D2.e,nx1,nx2);
if dim==1
   % Output concatenation
   if nfd1==0 && nfd2==0
      % No internal delays
      ny1 = size(D1.d,1);
      ny2 = size(D2.d,1);
      D1.b = [D1.b ; D2.b];
      D1.c = [D1.c zeros(ny1,nx2) ; zeros(ny2,nx1) D2.c];
      D1.d = [D1.d ; D2.d];
   else
      % Account for internal delays
      [rs1,cs1] = size(D1.d);
      [rs2,cs2] = size(D2.d);
      ny1 = rs1-nfd1;
      ny2 = rs2-nfd2;
      nu = cs1-nfd1;  % = cs2-nfd2
      D1.b = [[D1.b(:,1:nu) ; D2.b(:,1:nu)] , ...
            blkdiag(D1.b(:,nu+1:cs1),D2.b(:,nu+1:cs2))];
      D1.c = [blkdiag(D1.c(1:ny1,:),D2.c(1:ny2,:)) ; ...
            blkdiag(D1.c(ny1+1:rs1,:),D2.c(ny2+1:rs2,:))];
      D1.d = [[D1.d(1:ny1,1:nu) ; D2.d(1:ny2,1:nu)] , ...
            blkdiag(D1.d(1:ny1,nu+1:cs1),D2.d(1:ny2,nu+1:cs2)) ; ...
            [D1.d(ny1+1:rs1,1:nu);D2.d(ny2+1:rs2,1:nu)] , ...
            blkdiag(D1.d(ny1+1:rs1,nu+1:cs1),D2.d(ny2+1:rs2,nu+1:cs2))];
   end
else
   % Input concatenation
   if nfd1==0 && nfd2==0
      % No internal delays
      nu1 = size(D1.d,2);
      nu2 = size(D2.d,2);
      D1.b = [D1.b zeros(nx1,nu2) ; zeros(nx2,nu1) D2.b];
      D1.c = [D1.c , D2.c];
      D1.d = [D1.d , D2.d];
   else
      % Account for internal delays
      [rs1,cs1] = size(D1.d);
      [rs2,cs2] = size(D2.d);
      ny = rs1-nfd1;  % = rs2-nfd2
      nu1 = cs1-nfd1;
      nu2 = cs2-nfd2;
      D1.b = [blkdiag(D1.b(:,1:nu1),D2.b(:,1:nu2)) , ...
            blkdiag(D1.b(:,nu1+1:cs1),D2.b(:,nu2+1:cs2))];
      D1.c = [[D1.c(1:ny,:) D2.c(1:ny,:)] ;...
            blkdiag(D1.c(ny+1:rs1,:),D2.c(ny+1:rs2,:))];
      D1.d = [[D1.d(1:ny,1:nu1) D2.d(1:ny,1:nu2)] ,...
            [D1.d(1:ny,nu1+1:cs1) D2.d(1:ny,nu2+1:cs2)] ;...
            blkdiag(D1.d(ny+1:rs1,1:nu1),D2.d(ny+1:rs2,1:nu2)) ,...
            blkdiag(D1.d(ny+1:rs1,nu1+1:cs1),D2.d(ny+1:rs2,nu2+1:cs2))];
   end
end
D1.Scaled = false;

% Construct result
D1.Delay = Delay;
if ~(isempty(D1.StateName) && isempty(D2.StateName))
   D1.StateName = [ltipack.fullstring(D1.StateName,nx1) ; ltipack.fullstring(D2.StateName,nx2)];
end
if ~(isempty(D1.StateUnit) && isempty(D2.StateUnit))
   D1.StateUnit = [ltipack.fullstring(D1.StateUnit,nx1) ; ltipack.fullstring(D2.StateUnit,nx2)];
end
