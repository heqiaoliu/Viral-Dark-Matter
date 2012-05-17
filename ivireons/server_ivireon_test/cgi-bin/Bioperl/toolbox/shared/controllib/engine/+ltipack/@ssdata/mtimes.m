function D1 = mtimes(D1,D2,ScalarFlags)
% Multiplies two state-space models D = D1 * D2

%   Copyright 1986-2010 The MathWorks, Inc.
%	 $Revision: 1.1.8.3 $  $Date: 2010/03/31 18:36:19 $
if nargin<3
   ScalarFlags = false(1,2);
elseif ScalarFlags(1)
   D1 = diagrep(D1,length(D2.Delay.Output));
elseif ScalarFlags(2)
   D2 = diagrep(D2,length(D1.Delay.Input));
end

% Fold in delays along the inner dimension
% 1) May redistribute delays at the inputs of D1 and outputs of D2
%    to minimize overall number of internal delays
% 2) This may compromise static gains and cause sample time inconsistencies 
%    so sampling time matching call should precede this (g369887). Try, e.g.,
%    ss(1,[2 2],[3;3],0,.1,'inputd',2) * [1 2;3 4]
[Delay,D1,D2] = mtimesDelay(D1,D2,ScalarFlags);
   
% Internal delays and states
[n,nu2] = iosize(D2);
nfd1 = length(D1.Delay.Internal);
nfd2 = length(D2.Delay.Internal);
nx1 = size(D1.a,1);
nx2 = size(D2.a,1);

% Compute realization for product D1 * D2
D1.a = [D1.a , D1.b(:,1:n)*D2.c(1:n,:) ; zeros(nx2,nx1) , D2.a];
D1.e = utBlkDiagE(D1.e,D2.e,nx1,nx2);
if nfd1==0 && nfd2==0
   % No internal delays
   %     [ a1  b1*c2 ]       [ b1*d2 ]
   % A = [  0    a2  ]   B = [   b2  ]
   %
   % C = [ c1  d1*c2 ]   D =  d1*d2
   D1.b = [D1.b*D2.d ; D2.b];
   D1.c = [D1.c , D1.d*D2.c];
   D1.d = D1.d * D2.d;
else
   b = [D1.b(:,1:n)*D2.d(1:n,:) ; D2.b];
   D1.b = [b(:,1:nu2) [D1.b(:,n+1:n+nfd1);zeros(nx2,nfd1)] b(:,nu2+1:nu2+nfd2)];
   D1.c = [D1.c , D1.d(:,1:n)*D2.c(1:n,:) ; ...
         zeros(nfd2,nx1) , D2.c(n+1:n+nfd2,:)];
   d = [D1.d(:,1:n)*D2.d(1:n,:) ; D2.d(n+1:n+nfd2,:)];
   D1.d = [d(:,1:nu2) [D1.d(:,n+1:n+nfd1);zeros(nfd2,nfd1)] d(:,nu2+1:nu2+nfd2)];
end
D1.Scaled = false;

D1.Delay = Delay;
if ~(isempty(D1.StateName) && isempty(D2.StateName))
   D1.StateName = [ltipack.fullstring(D1.StateName,nx1) ; ltipack.fullstring(D2.StateName,nx2)];
end
if ~(isempty(D1.StateUnit) && isempty(D2.StateUnit))
   D1.StateUnit = [ltipack.fullstring(D1.StateUnit,nx1) ; ltipack.fullstring(D2.StateUnit,nx2)];
end

