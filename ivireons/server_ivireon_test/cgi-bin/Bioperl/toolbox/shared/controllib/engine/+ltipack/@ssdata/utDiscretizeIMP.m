function [Ddisc,XMap,ICMap] = utDiscretizeIMP(Dc,Ts,XMap)
% Impulse-invariant discretization of state-space model.
%
%   XMAP     Keeps track of where original states are in discretized state vector
%   ICMAP    Matrix mapping continuous-time initial conditions (xc0,uc0) to
%            discrete-time initial condition xd0.
%
% Note:: Assumes zero internal delays have already been eliminated

%   James G. Owen
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:31:59 $

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
      [a,Terms,thn,rho,nzB,nzC] = c2dSetUp(Dc,Ts,fid,fod,tol);
      [ny,nu] = size(Terms(1).d);
      
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
      bDelays = unique([0;floor(uDelays)]);
      cDelays = unique([0;ceil(xDelays)]);
      nbt = length(bDelays);   nud = nu*nbt;   bMats = zeros(nx,nud);
      cTerms = struct('delay',num2cell(cDelays),'coeff',0);
      dTerms = struct('delay',cell(0,1),'coeff',0); 
      
      % Construct ib s.t. bDelays(ib(j+1)) = j
      bdrf = zeros(1,bDelays(end)+1);
      bdrf(1+bDelays) = 1:nbt;
      
      % Integration loop: update
      %    x(k+e_m) = Ad x[k] + sum Bp * u[k-Np]
      % at the events e_1,...,e_M:
      ad = eye(nx);
      xnxt = 1;  unxt = 1;
      % RE: Use tolerance for event matching to avoid dropping D terms when 
      % 1-rho(j)=t0+o(eps) instead of t0 due to rounding errors
      for m=1:length(Events)-1
         t0 = Events(m);
         t1 = Events(m+1);
         % Add contribution of x(t0-) to y[k]
         if t0==0
            idxC = find(rho==0 & nzC);
         elseif xnxt<=length(xEvents) && abs(t0-xEvents(xnxt))<tol
            idxC = find(1-rho==xEvents(xnxt) & nzC);  xnxt = xnxt+1;
         else
            idxC = [];
         end
         for ct=1:length(idxC)
            cj = Terms(idxC(ct)).c;
            Nj = ceil(thn(idxC(ct)));
            cTerms = c2dUpdateTerm(cTerms,Nj,cj*ad);
            for i=1:nbt,
               bi = bMats(:,nu*(i-1)+1:nu*i);
               if norm(bi,1)>0
                  dTerms = c2dUpdateTerm(dTerms,Nj+bDelays(i),cj*bi);
               end
            end
         end
         % Compute x(t0+) and update BMATS and y[k]
         if t0==0
            idxB = find(rho==t0 & nzB);
         elseif unxt<=length(uEvents) && abs(t0-uEvents(unxt))<tol
            idxB = find(rho==uEvents(unxt) & nzB);  unxt = unxt+1;
         else
            idxB = [];
         end
         for ct=1:length(idxB)
            Nj = floor(thn(idxB(ct)));
            bj = Terms(idxB(ct)).b;
            offset = nu*(bdrf(Nj+1)-1);
            bMats(:,offset+1:offset+nu) = bMats(:,offset+1:offset+nu) + bj;
            % Add contribution of x(t0+)-x(t0-) to y[k]
            for ct2=1:length(idxC)
               dTerms = c2dUpdateTerm(dTerms,...
                  Nj+ceil(thn(idxC(ct2))),Terms(idxC(ct2)).c * bj);
            end
         end         
         % Integrate
         %    dx/dt = a * x 
         % over (t0,t1) and update AD and BMATS
         h = (t1-t0)*Ts;
         ah = utScaledExpm(h * a);
         ad = ah * ad;
         bMats = ah * bMats; 
      end
    
      % Construct DDAE realization of discretized model
      bTerms = struct('delay',num2cell(bDelays),'coeff',mat2cell(bMats,nx,nu*ones(1,nbt))');
      [dTN,is] = sort([dTerms.delay]);
      dTerms = dTerms(is(dTN>=0));
      [bd,cd,dd,Delay] = aff2ddae(ny,nu,ad,bTerms,cTerms,dTerms,Delay);
      Ddisc = ltipack.ssdata(ad,bd,cd,dd,[],Ts);
      Ddisc.Delay = Delay;
      
      % Mapping ICMAP from continuous initial conditions (xc0,uc0) to xd0
      ICMap = [eye(nx) , zeros(nx,nu)];   
      
   else
      % General case: not supported
      ctrlMsgUtils.error('Control:transformation:c2d04')
   end

else
   % Only input and output delays (after eliminating zero internal delays)
   [A,B,C,D] = getABCD(Dc);
   [ny,nu] = size(D);
   nx = size(A,1);

   % Delay preprocessing
   fiod = fod(:,ones(1,nu)) + fid(:,ones(1,ny))'; % normalized
   iPosFOD = find(fod>0);
   iZeroFID = find(fid==0);
   iZeroFOD = find(fod==0);

   % Discretized state matrices
   %    x[k+1]  = Ad x[k] + Bd u[k]
   %    y1[k]   = Cd1 x[k] + Dd1 u[k]   % fod = 0
   %    y2[k+1] = Cd2 x[k] + Dd2 u[k]   % fod > 0
   Ad = utScaledExpm(A*Ts);
   Bd = zeros(nx,nu);  Bd(:,iZeroFID) = Ad * B(:,iZeroFID);
   Cd = C;
   Dd = zeros(ny,nu);
   % Dd1 portion: contribution of impulses at t=k*Ts
   Dd(iZeroFOD,iZeroFID) = C(iZeroFOD,:) * B(:,iZeroFID);

   % Collect all values delta for which expm(A*Ts*(1-delta)) is needed.
   % These include positive input and output delays, and combinations
   % in(j)+out(i) with out(i)>0 and in(j)+out(i)<=1.
   % Note: Do not evaluate expm(A*(1-mu-nu)) as expm(A*(1-mu))*expm(-A*nu).
   % While more efficient, this is numerically unstable when A has poles
   % with large negative real part.
   fiod(iZeroFOD,:) = 0;   fiod(fiod>1+tol) = 0;   pfiod = fiod(fiod>0);
   Deltas = unique([fid(fid>0) ; fod(iPosFOD) ; pfiod(:)]); % all in (0,1]
   deltaLastUpdate = 0;  expA = eye(nx);
   for ct=1:length(Deltas)
      delta = Deltas(ct);
      % Recompute EXPM only when delta varies by more than TOL
      if delta>deltaLastUpdate+tol
         expA = utScaledExpm(A*((1-delta)*Ts));
         deltaLastUpdate = delta;
      end
      % Contribution to Bd
      j = find(fid==delta);
      Bd(:,j) = expA * B(:,j);
      % Contribution to Cd2
      i = find(fod==delta);
      Cd(i,:) = C(i,:) * expA;
      % Contribution to Dd2
      [i,j] = find(fiod==delta);
      for k=1:length(i)
         ik = i(k);  jk = j(k);
         Dd(ik,jk) = C(ik,:) * expA * B(:,jk);
      end
   end

   % Increment discrete output delay for channels with FOD>0
   Delay.Output(iPosFOD) = Delay.Output(iPosFOD)+1;

   % Store data
   Ddisc = ltipack.ssdata(Ad,Bd,Cd,Dd,[],Ts);
   Ddisc.Delay = Delay;

   % Mapping ICMAP from continuous initial conditions (xc0,uc0) to xd0
   ICMap = [eye(nx),zeros(nx,nu)];

end

Ddisc.StateName = Dc.StateName;
Ddisc.StateUnit = Dc.StateUnit;

