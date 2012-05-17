function [g,factor,power] = dcgain(D)
% Computes DC gain and DC equivalent

%   Author(s): P. Gahinet
%   Copyright 1986-2007 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:30:52 $
hw = ctrlMsgUtils.SuspendWarnings; %#ok<NASGU>
Ts = D.Ts;
if Ts==0,
   r0 = 0;
else
   r0 = 1;
end

% Compute DC gain
% Do not attempt to detect when A is singular. Some systems have poorly
% conditioned A but finite DC gain, e.g., ss(zpk(1e10,[1e11 -1e11 1 -1],1e12))
g = evalfr(D,r0);
if hasInfNaN(g)
   % Look for I/O pairs with finite DC gain due to structural cancellations 
   % at s=0 or z=1. For example,  ss([1 ; tf(1,[1 0])]) has dc gain [1;Inf] 
   % but EVALFR(D,R0) returns [NaN Inf]
   [a,b1,b2,c1,c2,d11,d12,d21,d22,e] = getBlockData(D);
   [ny,nu] = size(d11);
   nfd = size(d22,1);
   xdkeep = iosmreal([a b2;c2 d22],[b1;d21],[c1 d12],blkdiag(e,eye(nfd)));
   for j=1:nu
      for i=1:ny
         % Use s-minimal realization for each I/O pair
         g(i,j) = evalfr(localGetSubSys(D,ny,nu,xdkeep(:,i,j),i,j),r0);
      end
   end
   g(~isfinite(g)) = Inf;
end
            
% DC equivalent
if nargout>1
   if hasInfNaN(g)
      % Model with integrators: find equivalent 1/s^k power near s=0
      try
         % RE: may fail if some delay loop is singular at s=0, see g173557
         [a,b,c,d] = getABCD(D);
      catch ME
          ctrlMsgUtils.error('Control:analysis:dcgain1')
      end
      nx = size(a,1);
      aa = r0 * eye(nx) - a;

      % Balancing
      [aa,b,c] = xscale(aa,b,c,d,[],Ts);

      % Compute DC gain as limit for s->0 of D+C*inv(sI-A)*B
      % Perform staircase reduction of sI+AA to
      %    [ sI+Ai    0  ]
      %    [   As   sI-L ]
      % with Ai invertible and L strictly lower triangular (nilpotent)
      % RE: L -> inv. subspace for s=0
      tolzer = 1e3*eps;  % rel. tolerance for zero detection
      [aa,b,c,nxi] = localStairCase(aa,b,c,tolzer);

      % Block diagonalize to decouple the finite (sI+Ai)
      % and infinite (sI-L) contributions to G(s) near s=0
      Ai = aa(1:nxi,1:nxi);
      L = -aa(nxi+1:nx,nxi+1:nx);
      T = lyap(L,Ai,aa(nxi+1:nx,1:nxi));
      b(nxi+1:nx,:) = b(nxi+1:nx,:) + T * b(1:nxi,:);
      c(:,1:nxi) = c(:,1:nxi) - c(:,nxi+1:nx) * T;

      % The gain near s=0 is
      %    G(s) = D + Ci*(Ai\Bi) + Cs*Q(s) + o(s)
      % where
      %    Q(s) = (sI-L)\Bs = Bs/s + L*Bs/s^2 + ... L^(n-1)*Bs/s^n
      % First evaluate finite part
      g = d + c(:,1:nxi)*(Ai\b(1:nxi,:));
      factor = g;
      power = zeros(size(g));

      % Add infinite contribution of Cs*Q(s) = G1/s +... Gn/s^n
      cs = c(:,nxi+1:nx);
      tol = tolzer * norm(c,1);
      q = b(nxi+1:nx,:);  % q = bs
      nq = norm(b,1);     % scale of q
      k = 1;              % power of 1/s
      while any(q(:)),
         gk = cs*q;                     % Gk = Cs*L^(k-1)*Bs
         nzk = (abs(gk) > tol * nq);    % non zero entries in Gk
         g(nzk) = Inf;                  % G(i,j)=Inf if Gk(i,j)~=0
         factor(nzk) = gk(nzk);
         power(nzk) = -k;
         % k -> k+1 update
         q = L * q;
         nq = max(nq,norm(q,1));
         k = k+1;
      end
   else
      % All finite entries -> zero-order equivalent
      factor = g;
      power = zeros(size(g));
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function D = localGetSubSys(D,ny,nu,xdkeep,i,j)
% Compute realization of H(s) or H(i,j)(s) keeping only the 
% states/delays specified by XDKEEP
nx = size(D.a,1);
ix = find(xdkeep(1:nx));
id = find(xdkeep(nx+1:end))';
ir = [i , ny+id];
ic = [j , nu+id];
D.a = D.a(ix,ix);
if ~isempty(D.e)
   D.e = D.e(ix,ix);
end
D.b = D.b(ix,ic);
D.c = D.c(ir,ix);
D.d = D.d(ir,ic);
D.Delay.Input = D.Delay.Input(j);
D.Delay.Output = D.Delay.Output(i);
D.Delay.Internal = D.Delay.Internal(id);


%--------------------------------------------------------

function [a,b,c,nxi] = localStairCase(a,b,c,tolzer)
%STAIRCASE  Reduction to staircase form.
%
%   Reduces (A,B) to the lower triangular staircase form
%
%          [  Ai 0   ...  0  ]        [ B1 ]
%          [  *  0   ...  0  ]        [ B2 ]
%     A -> [  *  *  0     0  ]   B -> [ :  ]
%          [  :  :    ..  :  ]        [ :  ]
%          [  *  *        0  ]        [ :  ]
%
%   with Ai invertible of size NXI.

nxi = size(a,1);

% Column compression A -> [V'*A*V1 , 0]
[u,s,v] = svd(a);
s = diag(s);
nzsv = (s>tolzer*max(s));  % nonzero singular values

% Iterative reduction to staircase form
while ~all(nzsv),
   % Perform compression A(1:NXI,1:NXI) -> [V'*A(1:NXI,1:NXI)*V1,0]
   v1 = v(:,nzsv);
   a(1:nxi,1:nxi) = [v'*a(1:nxi,1:nxi)*v1 , zeros(nxi,nxi-size(v1,2))];
   a(nxi+1:end,1:nxi) = a(nxi+1:end,1:nxi) * v;
   b(1:nxi,:) = v'*b(1:nxi,:);
   c(:,1:nxi) = c(:,1:nxi)*v;
   
   % New "A" block is A(1:NXI,1:NXI) where NXI = col. size of V1
   nxi = size(v1,2);
   [u,s,v] = svd(a(1:nxi,1:nxi));
   s = diag(s);
   nzsv = (s>tolzer*max(s));  % invertible singular values
end







