function [Dd,XMap,ICMap] = utDiscretizeFOH(Dc,Ts,XMap)
% FOH discretization of state-space models.
%
% Note:: Assumes zero internal delays have already been eliminated

%   Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:31:58 $

% TOLINT: tolerance for comparing delay times
tol = 1e4*eps;

% Decompose external delays into entire + fractional delays
[Delay,fid,fod] = discretizeDelay(Dc,Ts);

% Discretization algorithm
nfd = length(Dc.Delay.Internal);
if nfd>0
   % Model has internal delays
   nx = size(Dc.a,1);
   if isExplicitODE(Dc)
      % DDAE is equivalent to ODE of the form
      %     dx/dt = a x + sum Bj u(t-theta_j)
      %     y = sum Cj x(t-thetaj) + Dj u(t-theta_j)
      % Gather (thetaj,Bj,Cj,Dj) data.
      %   thn: normalized delays thetaj/Ts
      %   rho: decimal part of thn (rho in [0,1))
      %   nzB,nzC,nzD: true for terms with nonzero B,C,D matrices resp.
      [a,Terms,thn,rho,nzB,nzC,nzD] = c2dSetUp(Dc,Ts,fid,fod,tol);
      [ny,nu] = size(Terms(1).d);
      nt = length(Terms);

      % Build list of integration milestones
      uEvents = unique(rho(nzB & rho>0));    uDelays = thn(nzB);
      xEvents = unique(1-rho(nzC & rho>0));  xDelays = thn(nzC);
      Events = unique([0 ; uEvents ; xEvents ; 1]);

      % The discretized state-space equations are of the form
      %   x[k+1] = A x[k] + sum Bp u[k-Np]
      %     y[k] = sum Cq x[k-Nq] + sum Dr u[k-Nr]
      % Allocate space for keeping track of Bp, Cq, Dr matrices:
      %   * Bp u[k-Np] is captured in bDelays(p) and bMats(:,nu*(p-1)+1:nu)
      %   * Cq x[k-Nq] is captured in cTerms(cTerms.delay==Nq)
      %   * Dr u[k-Nr] is captured in dTerms(dTerms.delay==Nr)
      aux = floor(uDelays);
      bDelays = unique([-1;0;aux;aux-1;ceil(uDelays)]); % -1 -> u[k+1]
      cDelays = unique([0;ceil(xDelays)]);
      nbt = length(bDelays);   nud = nu*nbt;   bMats = zeros(nx,nud);
      cTerms = struct('delay',num2cell(cDelays),'coeff',0);
      dTerms = struct('delay',cell(0,1),'coeff',0);

      % Initialize
      %  * cTerms with contributions of Cj x(t-thetaj) where rhoj=0
      %  * dTerms with contributions of Dj u(t-thetaj)
      for j=1:nt
         Nj = floor(thn(j));   rhoj = rho(j);
         if nzC(j) && rhoj==0
            cTerms = c2dUpdateTerm(cTerms,Nj,Terms(j).c);
         end
         if nzD(j)
            dj = Terms(j).d;
            if rhoj==0
               dTerms = c2dUpdateTerm(dTerms,Nj,dj);
            else
               dTerms = c2dUpdateTerm(dTerms,Nj,(1-rhoj)*dj);
               dTerms = c2dUpdateTerm(dTerms,Nj+1,rhoj*dj);
            end
         end
      end

      % Integration loop: update
      %    x(k+e_m) = Ad x[k] + sum Bp * u[k-Np]
      % at the events e_1,...,e_M:
      ad = eye(nx);
      phi = cell(bDelays(end)+2,1); phi(2+bDelays) = {zeros(nx,nu)};
      psi = cell(bDelays(end)+2,1); psi(2+bDelays) = {zeros(nx,nu)};
      for j=1:nt
         if nzB(j)
            Nj = floor(thn(j));  rhoj = rho(j);  bj = Terms(j).b;
            if rhoj==0
               phi{Nj+2} = phi{Nj+2} + bj;
               psi{Nj+1} = psi{Nj+1} + bj;
               psi{Nj+2} = psi{Nj+2} - bj;
            else
               phi{Nj+2} = phi{Nj+2} + (1-rhoj) * bj; % u[k-Nj]
               phi{Nj+3} = phi{Nj+3} + rhoj * bj;     % u[k-Nj-1]
               psi{Nj+2} = psi{Nj+2} + bj;
               psi{Nj+3} = psi{Nj+3} - bj;
            end
         end
      end
      unxt = 1;  xnxt = 1;
      for m=1:length(Events)-1
         t0 = Events(m);
         t1 = Events(m+1);
         % Integrate
         %    dx/dt = a * x + phi*[u[k-Ns]] + (t/Ts-k) * psi*[u[k-Ns]]
         % over [t0,t1)
         h = (t1-t0)*Ts;
         M = utScaledExpm(h * [a psi{2+bDelays} phi{2+bDelays};...
            zeros(nud,nx+nud) eye(nud)/Ts ; zeros(nud,nx+2*nud)]);
         ah = M(1:nx,1:nx);
         % Update AD and BTERMS
         ad = ah * ad;
         bMats = t0 * M(1:nx,nx+1:nx+nud) + M(1:nx,nx+nud+1:end) + ah * bMats;
         % Update PHI,PSI matrices when traversing U event (term u(t-thetaj) in state equation)
         if unxt<=length(uEvents) && t1==uEvents(unxt)
            idx = find(rho==t1 & nzB);
            for ct=1:length(idx)
               bj = Terms(idx(ct)).b;   Nj = floor(thn(idx(ct)));
               phi{Nj+2} = phi{Nj+2}+2*t1*bj;  psi{Nj+2} = psi{Nj+2}-2*bj;
               phi{Nj+1} = phi{Nj+1}-t1*bj;    psi{Nj+1} = psi{Nj+1}+bj;
               phi{Nj+3} = phi{Nj+3}-t1*bj;    psi{Nj+3} = psi{Nj+3}+bj;
            end
            unxt = unxt + 1;
         end
         % Update y[k] when traversing X event (term x(t-thetaj) in output equation)
         if xnxt<=length(xEvents) && t1==xEvents(xnxt)
            idx = find(1-rho==t1 & nzC);
            for ct=1:length(idx)
               cj = Terms(idx(ct)).c;
               Nj = ceil(thn(idx(ct))); % >0
               cTerms = c2dUpdateTerm(cTerms,Nj,cj*ad);
               for i=1:nbt,
                  bi = bMats(:,nu*(i-1)+1:nu*i);
                  if norm(bi,1)>0
                     dTerms = c2dUpdateTerm(dTerms,Nj+bDelays(i),cj*bi);
                  end
               end
            end
            xnxt = xnxt+1;
         end
      end

      % Get rid of u[k+1] in bTerms by redefining x[k]->x[k]-g*u[k]
      g = bMats(:,1:nu);  % for bDelays=-1
      if norm(g,1)>0
         bMats(:,nu+1:2*nu) = bMats(:,nu+1:2*nu) + ad * g;
         for ct=1:length(cDelays)
            Nk = cDelays(ct);   ck = cTerms(ct).coeff;
            if norm(ck,1)>0
               dTerms = c2dUpdateTerm(dTerms,Nk,ck*g);
            end
         end
         bTerms = struct('delay',num2cell(bDelays(2:nbt)),...
            'coeff',mat2cell(bMats(:,nu+1:nu*nbt),nx,nu*ones(1,nbt-1))');
      else
         bTerms = struct('delay',num2cell(bDelays),'coeff',mat2cell(bMats,nx,nu*ones(1,nbt))');
      end

      % Construct DDAE realization of discretized model
      [dTN,is] = sort([dTerms.delay]);
      dTerms = dTerms(is(dTN>=0));
      [bd,cd,dd,Delay] = aff2ddae(ny,nu,ad,bTerms,cTerms,dTerms,Delay);
      Dd = ltipack.ssdata(ad,bd,cd,dd,[],Ts);
      Dd.Delay = Delay;

      % Mapping ICMAP from continuous initial conditions (xc0,uc0) to xd0
      ICMap = [eye(nx) , -g];

   else
      % General case: discretize rational part H(s) of delay model
      ctrlMsgUtils.warning('Control:transformation:C2dApproximate')
      [fdint,ffd] = ltipack.splitDelay(Dc.Delay.Internal,Ts);
      nu = length(fid);
      ny = length(fod);
      % Absorb fractional internal delays into H(s)
      Dc.Delay.Internal = zeros(0,1);
      Dc.Delay.Output = [Dc.Delay.Output ; ffd*Ts];
      Dc.Delay.Input = [Dc.Delay.Input ; zeros(nfd,1)];
      % Discretize H(s)
      [Dd,~,ICMap] = utDiscretizeFOH(Dc,Ts,XMap);
      Dd.Delay.Internal = fdint + Dd.Delay.Input(nu+1:end,:) + Dd.Delay.Output(ny+1:end,:);
      Dd.Delay.Output = Dd.Delay.Output(1:ny,:);
      Dd.Delay.Input = Dd.Delay.Input(1:nu,:);
      ICMap = ICMap(:,1:nx+nu);
      
      % Eliminate zero discrete internal delays
      Dd = elimZeroDelay(Dd);
      if ~isempty(Dd.e)
         ctrlMsgUtils.error('Control:transformation:c2d12') % non causal
      end
   end


else
   % Only input and output delays (after eliminating zero internal delays)
   [a,b,c,d] = getABCD(Dc);
   [ny,nu] = size(d);
   nx = size(a,1);

   % Perform ZOH discretization
   fid = reshape(fid,[1 nu]);
   fod = reshape(fod,[1 ny]);
   zfid = (fid<=tol);
   zfod = (fod<=tol);
   jdelay = find(~zfid);  % delayed input channels
   nid = length(jdelay);  % number of nonzero input delays
   if all(zfid) && all(zfod),
      % Delay-free conversion
      M = [a , b , zeros(nx,nu)  ; ...
         zeros(nu,nx+nu)  eye(nu)/Ts ; ...
         zeros(nu,nx+2*nu)];
      s = utScaledExpm(M*Ts);
      F1 = s(1:nx,nx+1:nx+nu);
      F2 = s(1:nx,nx+nu+1:nx+2*nu);

      % Discrete-time matrices
      E = s(1:nx,1:nx);
      F = F1 + E*F2 - F2;
      G = c;
      H = d + c*F2;

      % Continuous to discrete initial condition map
      ICMap = [eye(nx) , -F2];

   else
      % Discretization with fractional delays
      Tmat = [a , b , zeros(nx,nu)  ; ...
         zeros(nu,nx+nu)  eye(nu)/Ts ; ...
         zeros(nu,nx+2*nu)];      % transition matrix
      cdaux = [c , d];

      % Initialize the piecewise integration at t=0, and update the
      % linear relation
      %    X(t) = E(t) * Xk + F1(t) * U[k] + F2(t) * (U[k+1]-U[k])
      %    Y(t) = G(t) * Xk + H1(t) * U[k] + H2(t) * (U[k+1]-U[k])
      % where
      %   * X(t) = [x(t) ; uj(t-id(j)) ; Ts * dt/dt(uj(t-id(j))) ],  j=1:m
      %   * Xk = [ x[k] ; us[k-1] ]  where s=find(id)
      %   * U[k]  = [ u1[k] ; ... ; um[k] ]
      % Initial E,F1,F2 matrices are such that
      %    X(0) = E * Xk + F1 * U[k] + F2 * (U[k+1]-U[k])
      nxaug = nx+nid;
      E = blkdiag(eye(nx),zeros(2*nu,nid));
      E(nx+jdelay,nx+1:nxaug) = diag(fid(~zfid));
      E(nx+nu+jdelay,nx+1:nxaug) = -eye(nid);
      F1 = [zeros(nx,nu) ; diag(1-fid) ; diag(~zfid)];
      F2 = [zeros(nx+nu,nu) ; diag(zfid)];
      G = zeros(ny,nxaug);
      H1 = zeros(ny,nu);
      H2 = zeros(ny,nu);

      % Y updates for delay-free outputs
      G(zfod,:) = [c(zfod,:) , d(zfod,:)*E(nx+1:nx+nu,nx+1:nxaug)];
      H1(zfod,:) = d(zfod,:) * F1(nx+1:nx+nu,:);

      % Sort the integration events
      Events = unique([0 fid 1-fod 1]);
      fod(zfod) = -1;  % to prevent output update at t=1

      % Piecewise integration over intervals [Events(j-1),Events(j)]
      % RE: To guard against events differing by o(eps), integrate
      % only when the step size is > TOL and treat nearby events
      % as a single event to synchronize updates
      t0 = 0;
      for j=2:length(Events),
         t1 = Events(j);
         % Integrate state equation on [T0,T1]
         if t1>t0+tol
            h = (t1-t0)*Ts;
            ehTmat = utScaledExpm(h*Tmat);
            ehTmat = ehTmat(1:nx+nu,:);
            E(1:nx+nu,:) = ehTmat * E;
            F1(1:nx+nu,:) = ehTmat * F1;
            F2(1:nx+nu,:) = ehTmat * F2;
            t0 = t1;
         end

         % Find inputs updated at t=T1 (within TOL) and update E,F1,F2 accordingly
         iu = find(abs(fid-t1)<tol);
         liu = length(iu);
         E([nx+iu,nx+nu+iu],:) = 0;
         F1([nx+iu,nx+nu+iu],iu) = [eye(liu) ; zeros(liu)];
         F2(nx+nu+iu,iu) = eye(liu);
         fid(iu) = -1;  % make sure each delay is processed only once

         % Find delayed outputs updated at t=T1, and update G,H accordingly
         % Note: gives value of y[k+1]
         iy = find(abs(1-fod-t1)<tol);
         G(iy,:) = cdaux(iy,:) * E(1:nx+nu,:);
         H1(iy,:) = cdaux(iy,:) * F1(1:nx+nu,:);
         H2(iy,:) = cdaux(iy,:) * F2(1:nx+nu,:);
         fod(iy) = -1;
      end

      % Extract relevant rows of final E,F1,F2 matrices
      % and build coefficients of the recursion
      %   Xk+1 = E * Xk + F1 * U[k] + F2 * (U[k+1]-U[k])
      E = E([1:nx , nx+jdelay],:);
      F1 = [F1(1:nx,:) ; zeros(nid,nu)];
      F1(nx+1:nxaug,~zfid) = eye(nid);
      F2 = [F2(1:nx,:) ; zeros(nid,nu)];

      % Reduce state equation to
      %   Zk+1 = E * Zk + F * Uk  where Zk = Xk - F2 * U[k+1]
      F = F1 + E*F2 - F2;

      % Apply z^-1 shift to all output channels with fractional delays
      % Note: work with output equation
      %         Y[k+1] - H2 * U[k+1] = G * Zk + (G*F2+H1-H2) U[k]
      % Use output delay when H2(i,:)=0 (Yi[k] does not depend on U[k])
      % and extra state otherwise
      zH2 = all(H2==0,2)';
      ix = find(~zfod & zH2);
      Delay.Output(ix) = Delay.Output(ix)+1;
      [E,F,G,H] = localDelayOutput(E,F,G,G*F2+H1-H2,~(zfod | zH2));
      H = H + H2;

      % Map from continuous initial conditions (xc0,uc0) to xd0
      ICMap = [[eye(nxaug,nx) -F2] ; zeros(size(E,1)-nxaug,nx+nu)];
   end

   % Store data
   Dd = ltipack.ssdata(E,F,G,H,[],Ts);
   Dd.Delay = Delay;
end


% Clear state names (because xd[k] = xc(k*Ts)-F2*u[k]) and update XMap
nxd = size(Dd.a,1);
XMap = [XMap ; zeros(nxd-nx,1)];

%----------------------- Local functions --------------------------------

function [a,b,c,d] = localDelayOutput(a,b,c,d,hasDelay)
% Delays outputs selected by HASDELAY by z^-1
ny = length(hasDelay);
nd = sum(hasDelay);
a0 = zeros(nd);
b0 = zeros(nd,ny); b0(:,hasDelay) = eye(nd);
c0 = b0';
d0 = diag(double(~hasDelay));

% Series connection with (AO,BO,CO,DO) * (A,B,C,D)
% RE: Leave A's states in first position
nx = size(a,1);
a = [a , zeros(nx,nd) ; b0*c , a0];
b = [b ; b0 * d];
c = [d0 * c , c0];
d = d0 * d;

