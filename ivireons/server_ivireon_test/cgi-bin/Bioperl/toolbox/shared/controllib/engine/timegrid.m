function [Ts,Tf,StableFlag] = timegrid(a,x0,c,d,MaxDelay,Tf)
%TIMEGRID  Estimates sampling time and simulation horizon for 
%          continuous-time responses.
%
%   [TS,TF] = TIMEGRID(A,X0,C,D,MAXDELAY) computes an adequate fixed step  
%   size TS for simulating the time response of the affine ODE
%       dx/dt = Ax        x(0) = x0
%          y  = Cx + D
%   TIMEGRID also returns an estimate TF of how long the response takes
%   to settle.  For unstable systems, TF is the suggested simulation horizon.  
%   X0 can be a matrix, in which case TIMEGRID selects adequate TS and TF 
%   for the set of simulations with initial conditions X0(:,1), X0(:,2),...
%
%   TS = TIMEGRID(A,X0,C,D,MAXDELAY,TF) estimates the step size TS given
%   the simulation horizon TF in seconds.
%
%   TIMEGRID attempts to produce a simulation time TF that ensures the
%   output responses have decayed to approximately 1% of their initial
%   or peak values. 

%   Author: P. Gahinet, 4-18-96
%   Copyright 1986-2009 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:11:08 $
NoTf = (nargin<6 || isempty(Tf));
StableFlag = true;
[ny,nu] = size(d);
nx = size(a,1);
Tfmin = 2*MaxDelay;

% Parameters
toljw = sqrt(eps);
Nsmin = 100;    % min number of time steps
Nsu = 400;      % number of points for unstable sim.
SettlingThresh = 0.005;   % settling threshold
DominantThresh = 0.01;    % threshold to pick dominant modes

% Compute eigendecomposition
[v,p] = eig(a);
p = diag(p);    % system poles 
rp = real(p);

% Quick exit if output is constant
if norm(x0,1)==0 || norm(c,1)==0
   Ts = 0.1;
   if NoTf,  Tf = max(1,Tfmin);  end
   return
end

% Treat unstable, marginally stable, and stable cases separately
if any(rp>toljw) || hasInfNaN(x0)
   % Unstable system or infinite dc gain (pole at s=0)
   rp(rp<=toljw) = 1e-2;  % integrators
   if NoTf,  
      % Simulate until exp(m*t)>realmax^0.1 if no Tf specified
      Tf = max(0.1*log(realmax)/max(rp),Tfmin);
   end
   Ts = Tf/Nsu;
   StableFlag = false;

else
   % Stable or stable with integral action
   % Treat together to be robust to cancelling pseudo-integrators (g338843)
   gamma = abs(c*v);
   % RE: Do not make TOL too large, affects ability to estimate DC contribution
   % REVISIT: use rank-revealing QR instead of SVD
   beta = abs(pinv(v,1e-8)*x0);
      
   % Find dominant modes 
   relContrib = zeros(nx,1);  % relative contributions to DC value
   for j=1:nu
      for i=1:ny
         contrib = gamma(i,:).' .* beta(:,j);
         maxc = max(contrib);
         if maxc>0
            relContrib = max(relContrib,contrib/maxc);
         end
      end
   end
   isDominant = (relContrib > DominantThresh);
   if any(isDominant)
      p = p(isDominant);
      rp = rp(isDominant);
      relContrib = relContrib(isDominant);
   end
   
   % Time constants for stable dominant modes
   isStable = (rp<-toljw);
   StableFlag = all(isStable);
   timct = log(SettlingThresh)./rp(isStable); % time constants
   
   % Final time
   if NoTf
      % Show contribution of slowest stable mode and marginally
      % stable mode with largest period
      Tf = max([30./(1+abs(p(~isStable))) ; max(timct) ; Tfmin]); % always >0
   end
   
   % Sample time
   % Modes with most contribution are finely gridded, modes with little
   % contribution are coarsely gridded
   Ts = min([Inf ; timct./(1+100*relContrib(isStable))]);
   % At least 20 points/period for underdamped modes
   pRes = p(abs(rp)<abs(p)/2);
   if ~isempty(pRes)
      Ts = min(Ts,pi/10/max(abs(pRes)));
   end
   % Use NSU points for models with only marginally stable modes
   if isinf(Ts)
      Ts = Tf/Nsu;
   end

   % Out of memory safeguards
   if NoTf
      % Unspecified final time: protect against ultrafast dynamics or very HF modes
      Ts = max(Ts,Tf/10000);
   else
      % Specified final time: protect against final time much larger than
      % system's time constant (can happen in FILLRESP, see g258770), and
      % ensure at least NSMIN steps in simulation
      Ns = min(max(Nsmin,round(Tf/Ts)),50000);
      Ts = Tf/Ns;  % to ensure simulation actually stops at Tf
   end

end
