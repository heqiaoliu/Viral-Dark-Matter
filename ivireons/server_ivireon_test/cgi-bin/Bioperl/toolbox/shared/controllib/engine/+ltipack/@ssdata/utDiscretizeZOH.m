function [Dd,XMap,ICMap] = utDiscretizeZOH(Dc,Ts,XMap)
% ZOH discretization of state-space model
%
%   XMAP     Keeps track of where original states are in discretized state vector
%   ICMAP    Matrix mapping continuous-time initial conditions (xc0,uc0) to 
%            discrete-time initial condition xd0.
%
%   Note:: Assumes zero internal delays have already been eliminated

%   Author: P. Gahinet  2-98
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:32:01 $

% TOL: tolerance for comparing normalized delays (valued in [0,1])
tol = 1e4*eps;

% Decompose external delays into entire + (normalized) fractional delays
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
      bDelays = unique([0;floor(uDelays);ceil(uDelays)]);
      cDelays = unique([0;ceil(xDelays)]);
      nbt = length(bDelays);   nud = nu*nbt;   bMats = zeros(nx,nud);
      cTerms = struct('delay',num2cell(cDelays),'coeff',0);
      dTerms = struct('delay',cell(0,1),'coeff',0); 
         
      % Initialize 
      %  * cTerms with contributions of Cj x(t-thetaj) where rhoj=0
      %  * dTerms with contributions of Dj u(t-thetaj)
      for j=1:nt
         Nj = ceil(thn(j));   
         if nzC(j) && rho(j)==0
            cTerms = c2dUpdateTerm(cTerms,Nj,Terms(j).c);
         end
         if nzD(j)
            dTerms = c2dUpdateTerm(dTerms,Nj,Terms(j).d);
         end
      end

      % Integration loop: update
      %    x(k+e_m) = Ad x[k] + sum Bp * u[k-Np]
      % at the events e_1,...,e_M:
      ad = eye(nx);  
      psi = cell(bDelays(end)+1,1);
      psi(1+bDelays) = {zeros(nx,nu)};
      for j=1:nt
         if nzB(j)
            Nj = ceil(thn(j));
            psi{Nj+1} = psi{Nj+1} + Terms(j).b;
         end
      end
      unxt = 1;  xnxt = 1;
      for m=1:length(Events)-1
         t0 = Events(m);
         t1 = Events(m+1);
         % Integrate
         %    dx/dt = a * x + psi * [u[k-Ns]]
         % over [t0,t1)
         h = (t1-t0)*Ts;
         M = utScaledExpm(h * [a psi{1+bDelays};zeros(nud,nx+nud)]);
         ah = M(1:nx,1:nx);        
         % Update AD and BTERMS
         ad = ah * ad;
         bMats = M(1:nx,nx+1:nx+nud) + ah * bMats; 
         % Update PSI matrix when traversing U event (term u(t-thetaj) in state equation)
         if unxt<=length(uEvents) && t1==uEvents(unxt)
            idx = find(rho==t1 & nzB);
            for ct=1:length(idx)
               bj = Terms(idx(ct)).b;
               Nj = ceil(thn(idx(ct)));
               psi{Nj+1} = psi{Nj+1} - bj;   
               psi{Nj} = psi{Nj} + bj;
            end
            unxt = unxt + 1;
         end
         % Update y[k] when traversing X event (term x(t-thetaj) in output equation)
         if xnxt<=length(xEvents) && t1==xEvents(xnxt)
            idx = find(1-rho==t1 & nzC);
            for ct=1:length(idx)
               cj = Terms(idx(ct)).c;
               Nj = ceil(thn(idx(ct)));
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
      
      % Construct DDAE realization of discretized model
      bTerms = struct('delay',num2cell(bDelays),'coeff',mat2cell(bMats,nx,nu*ones(1,nbt))');
      [dTN,is] = sort([dTerms.delay]);
      dTerms = dTerms(is(dTN>=0));
      [bd,cd,dd,Delay] = aff2ddae(ny,nu,ad,bTerms,cTerms,dTerms,Delay);
      Dd = ltipack.ssdata(ad,bd,cd,dd,[],Ts);
      Dd.StateName = Dc.StateName;
      Dd.StateUnit = Dc.StateUnit;
      Dd.Delay = Delay;
      
      % Mapping ICMAP from continuous initial conditions (xc0,uc0) to xd0
      ICMap = [eye(nx) , zeros(nx,nu)];   
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
      [Dd,~,ICMap] = utDiscretizeZOH(Dc,Ts,XMap);
      Dd.Delay.Internal = fdint + Dd.Delay.Input(nu+1:end,:) + Dd.Delay.Output(ny+1:end,:);
      Dd.Delay.Output = Dd.Delay.Output(1:ny,:);
      Dd.Delay.Input = Dd.Delay.Input(1:nu,:);
      ICMap = ICMap(:,1:nx+nu);
      
      % Eliminate zero discrete internal delays
      % Note: Because small internal delays are mapped to output delays for H,
      % this should never give rise to algebraic loops
      Dd = elimZeroDelay(Dd);
   end

else
   % Model has only input and output delays (after eliminating zero internal delays)
   [a,b,c,d] = getABCD(Dc);
   [ny,nu] = size(d);
   nx = size(a,1);
   
   % Perform ZOH discretization
   fid = reshape(fid,[1 nu]);
   fod = reshape(fod,[1 ny]);
   zfid = (fid==0);
   zfod = (fod==0);
   if all(zfid) && all(zfod),
      % Delay-free case
      s = utScaledExpm([[a b]*Ts; zeros(nu,nx+nu)]);
      E = s(1:nx,1:nx);
      F = s(1:nx,nx+1:nx+nu);
      G = c;
      H = d;
      
   else
      % Discretization with fractional delays
      jdelay = find(~zfid);  % delayed input channels
      nid = length(jdelay);  % number of nonzero input delays
      Tmat = [a , b ; zeros(nu,nx+nu)];  % transition mat.
      cdaux = [c , d];
      
      % Initialize the piecewise integration at t=0, and update the 
      % linear relation
      %    X(t) = E(t) * Xk + F(t) * Uk
      %    Y(t) = G(t) * Xk + H(t) * Uk
      % where
      %   * X(t) = [ x(t) ; u1(t-id(1)) ; ... ; um(t-id(m)) ]  
      %   * Xk = [ x[k] ; us[k-1] ]  where s=find(id)
      %   * Uk  = [ u1[k] ; ... ; um[k] ]
      % Initial E,F matrices pertain to
      %    X(0) = E * Xk + F * Uk
      E = blkdiag(eye(nx),zeros(nu,nid));
      E(nx+jdelay,nx+1:nx+nid) = eye(nid);
      % Need to fix concate to respect type of empty so double not needed
      F = [zeros(nx,nu) ; double(diag(zfid))];
      G = zeros(ny,nx+nid);  
      H = zeros(ny,nu);
      
      % Y updates for delay-free outputs
      G(zfod,:) = [c(zfod,:) , d(zfod,~zfid)];
      H(zfod,zfid) = d(zfod,zfid);
      
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
            E(1:nx,:) = ehTmat(1:nx,:) * E;
            F(1:nx,:) = ehTmat(1:nx,:) * F;
            t0 = t1;
         end

         % Find inputs updated at t=T1 (within TOL) and update E,F accordingly
         iu = find(abs(fid-t1)<tol);
         E(nx+iu,:) = 0;
         F(nx+iu,iu) = eye(length(iu));
         fid(iu) = -1;  % make sure each delay is processed only once

         % Find delayed outputs updated at t=T1 and update G,H accordingly
         % Note: gives value of y[k+1]
         iy = find(abs(1-fod-t1)<tol);
         G(iy,:) = cdaux(iy,:) * E;
         H(iy,:) = cdaux(iy,:) * F;
         fod(iy) = -1;
      end
      
      % Extract relevant rows of final E,F matrices
      xkeep = [1:nx , nx+jdelay];
      E = E(xkeep,:);
      F = F(xkeep,:); 
      
      % Apply z^-1 shift to all output channels with fractional delays
      Delay.Output(~zfod) = Delay.Output(~zfod)+1;
   end
   
   % Store data
   Dd = ltipack.ssdata(E,F,G,H,[],Ts);
   nxnew = size(E,1)-nx;
   if ~isempty(Dc.StateName)
      Dd.StateName = [Dc.StateName ; repmat({''},nxnew,1)];
   end
   if ~isempty(Dc.StateUnit)
      Dd.StateUnit = [Dc.StateUnit ; repmat({''},nxnew,1)];
   end
   Dd.Delay = Delay;

   % Mapping ICMAP from continuous initial conditions (xc0,uc0) to xd0
   % ICMap = blkdiag(eye(nx),zeros(nxnew,nu));
   nxtotal = nx+nxnew;
   ICMap = zeros(nxtotal,nx+nu);
   ICMap(1:nxtotal+1:nxtotal*nx) = 1;
end

% Update XMap
XMap = [XMap ; zeros(size(Dd.a,1)-nx,1)];

