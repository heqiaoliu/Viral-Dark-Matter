function Terms = elimZW(b2,d12,c2,d21,d22,tau)
%ELIMZW  Eliminates Z,W variable for state-space models whose transfer 
%        function depends multi-linearly on the internal delays.
%
%   Computes the affine expansion:
%
%    [B2;D12] * Delta_tau * inv(I-D22*Delta_tau) * (C2 x(t) + D21 u(t))
%             
%                      =  sum_j  [0 Bj;Cj Dj]  [x(t-theta_j) ; u(t-theta_j)]
%
%   assuming:
%     * D22 is structurally nilpotent
%     * B2 * Delta_tau * inv(I-D22*Delta_tau) * C2 = 0
%     * All delays TAU are positive.
%
%   The output TERMS is a struct array storing Bj,Cj,Dj,thetaj data for each
%   term of the expansion.

%	 Author: P. Gahinet
%   Copyright 1986-2007 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:32:14 $
nfd = length(tau);
nx = size(b2,1);
ny = size(d12,1);
nu = size(d21,2);
bd = [b2;d12];
cd = [c2';d21'];

% Relative tolerance for delay comparison
rtol = 1e4*eps;

% Sort TAU
[tau,is] = sort(tau);
bd = bd(:,is);
cd = cd(:,is);
d22 = d22(is,is);

% Initialize:
%   * TERMS = data structure storing Bj,Cj,Dj and thetaj
%   * S = data structure keeping track of terms in expansion 
%          Delta_tau * (D22*Delta_tau)^k * (C2 x + D21 u) = 
%              sum_j  uj * vj'  [x(t-theta_j) ; u(t-theta_j)]
%     as k increases.
identity = eye(nfd);
s = struct('theta',cell(nfd,1),'u',[],'v',[]);
last_tau = -1;
sptr = 0;
for ct=1:nfd
   if tau(ct)>(1+rtol)*last_tau,
      % Move to next entry in S
      sptr = sptr+1;
      last_tau = tau(ct);
      s(sptr).theta = last_tau;
   end
   s(sptr).u = [s(sptr).u , identity(:,ct)];
   s(sptr).v = [s(sptr).v , cd(:,ct)];
end
s = s(1:sptr);
ns = length(s);
Terms = struct('theta',cell(ns,1),'b',[],'c',[],'d',[]);
for ct=1:ns
   u = bd * s(ct).u;
   v = s(ct).v;
   Terms(ct).theta = s(ct).theta;
   Terms(ct).b = u(1:nx,:) * v(nx+1:nx+nu,:)';
   Terms(ct).c = u(nx+1:nx+ny,:) * v(1:nx,:)';   
   Terms(ct).d = u(nx+1:nx+ny,:) * v(nx+1:nx+nu,:)';   
end

% Expand Delta_tau * (D22*Delta_tau)^k * [C2,D21] for increasing k and
% add cumulative contribution to TERMS.
while ns>0
   % Multiply S = sum_j  uj * vj'  [x(t-theta_j) ; u(t-theta_j)] by D22
   NonZeroTerm = true(1,ns);
   for ct=1:ns
      u = d22 * s(ct).u; 
      nzc = any(u,1);  % look for zero columns
      if any(nzc)
         s(ct).u = u(:,nzc);
         s(ct).v = s(ct).v(:,nzc);
      else
         NonZeroTerm(ct) = false;
      end
   end
   s = s(NonZeroTerm);
   ns = length(s);

   % Apply Delta_tau to resulting S
   theta = [s.theta];
   snew = struct('theta',cell(ns*nfd,1),'u',[],'v',[]);
   % Compute and sort all combined delays tau_i + theta_j
   [th,ta] = ndgrid(theta,tau);
   [ith,itau] = ndgrid(1:ns,1:nfd);
   [thta,is] = sort(th(:) + ta(:));  % tau_i + theta_j
   ith = ith(is);  itau = itau(is);
   % Compute all terms in expansion of
   %    Delta_tau * (D22*Delta_tau)^(k+1) * [C2,D21]
   % skipping zero terms
   last_delay = -1;
   sptr = 0;
   for ct=1:ns*nfd
      % Skip if ei'*uj=0
      innerprod = s(ith(ct)).u(itau(ct),:);
      if any(innerprod)
         if thta(ct)>(1+rtol)*last_delay,
            % Move to next entry in SNEW
            sptr = sptr+1;
            last_delay = thta(ct);
            snew(sptr).theta = last_delay;
         end
         idx = itau(ct) + zeros(size(innerprod));
         snew(sptr).u = [snew(sptr).u , identity(:,idx)];
         snew(sptr).v = [snew(sptr).v , lrscale(s(ith(ct)).v,[],innerprod)];
      end
   end
   % Update S
   s = snew(1:sptr);
   ns = length(s);
   
   % Add new terms to TERMS
   th = [Terms.theta];
   tnew = struct('theta',cell(ns,1),'b',[],'c',[],'d',[]);
   nnew = 0;
   for ct=1:ns,
      theta = s(ct).theta;
      u = bd * s(ct).u;
      v = s(ct).v;
      b = u(1:nx,:) * v(nx+1:nx+nu,:)';
      c = u(nx+1:nx+ny,:) * v(1:nx,:)';
      d = u(nx+1:nx+ny,:) * v(nx+1:nx+nu,:)';
      idx = find(abs(theta-th)<rtol*theta,1);
      if isempty(idx)
         % New term
         nnew = nnew + 1;
         tnew(nnew).theta = theta;
         tnew(nnew).b = b;
         tnew(nnew).c = c;
         tnew(nnew).d = d;
      else
         % Additional contribution to existing term
         Terms(idx).b = Terms(idx).b + b;
         Terms(idx).c = Terms(idx).c + c;
         Terms(idx).d = Terms(idx).d + d;   
      end
   end
   Terms = [Terms ; tnew(1:nnew)];      
end

% Eliminate zero terms. This occurs in, e.g.,
%   sys = ss(1,1,1,0,'inputd',.6,'outputd',.6,'iodelay',.1)
%   sysd = c2d(sys,.5)
% (two terms for theta=0.1 are zero)
nt = length(Terms);
ZeroTerm = false(nt,1);
for ct=1:nt
   ZeroTerm(ct) = norm(Terms(ct).b,1)==0 && ...
      norm(Terms(ct).c,1)==0 && norm(Terms(ct).d,1)==0;
end
Terms(ZeroTerm) = [];

