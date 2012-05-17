function D = inv(D)
% Computes inv(D)

%   Copyright 1986-2009 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:31:14 $
[a,b1,b2,c1,c2,d11,d12,d21,d22,e] = getBlockData(D);
nu = size(d11,2); % d11 is square
nx = size(a,1);
Ts = D.Ts;

% Error if inverse is not causal
if any(D.Delay.Input) || any(D.Delay.Output) || ...
      (~isempty(d22) && localIsRankDeficient(a,b1,c1,d11,e,Ts))
   ctrlMsgUtils.error('Control:transformation:inv1')
end

% Build and simplify inverse system
ai = [a b1;c1 d11];
bi = [zeros(nx,nu) b2; -eye(nu) d12];
ci = [zeros(nu,nx) eye(nu);c2 d21];
di = blkdiag(zeros(nu),d22);
if isempty(D.e)
   % Explicit model: eliminate algebraic variables when numerically safe
   [D.a,D.b,D.c,D.d,D.e] = elimAV(ai,bi,ci,di,[],Ts,nx);
else
   % Descriptor model: augment state vector with NU algebraic variables
   D.a = ai;  D.b = bi;  D.c = ci;  D.d = di;  D.e = blkdiag(e,zeros(nu));
end
if ~isempty(D.StateName)
   D.StateName(nx+1:size(D.a,1),:) = {''};
end
if ~isempty(D.StateUnit)
   D.StateUnit(nx+1:size(D.a,1),:) = {''};
end
D.Scaled = false;


%--------------

function boo = localIsRankDeficient(a,b,c,d,e,Ts)
% Checks if D+C*inv(sE-A)*B has less-than-full normal rank
[a,b,c,e] = smreal(a,b,c,e);
[a,b,c,e] = xscale(a,b,c,d,e,Ts,'Warn',false);
boo = ltipack.utSingularAE([a b;c d],blkdiag(e,zeros(size(d))));
