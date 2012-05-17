function [y,t,focus,x] = timeresp(D,RespType,t,x0)
%TIMERESP  Time response of a single LTI model
%
%   [Y,T,FOCUS,X] = TIMERESP(D,RESPTYPE,T,X0) computes one of 
%   the following time response as specified by RESPTYPE:
%      * step response
%      * impulse response
%      * response to initial condition (X0 required)
%   The input T is either a time vector, a final time, or []
%   for infinite-horizon simulations.
%   
%   When T=[], FOCUS is set the preferred simulation horizon.
%   Otherwise FOCUS is equal to T(END) unless the final time
%   has to be reduced to prevent overflow (for unstable systems
%   only).

%	 Author: P. Gahinet, 4-98
%   Copyright 1986-2009 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:30:27 $

% RE: 1) single  model
%     2) RESPTYPE is 'step', 'impulse', or 'initial'
[ny,nu] = iosize(D);
isCT = (D.Ts==0);
ComputeX = (nargout>3 && ~utIgnoreX(D));

% Validate D
% 1) Remove zero internal delays (can create artificial DDAEs). Do it in 
% discrete time as well (g353999) and before ISPROPER to deal with singular loops
% 2) Eliminate E matrix especially in discrete time (g560840, g346680)
[isProper,D] = isproper(elimZeroDelay(D),'explicit');
if ~isProper
   ctrlMsgUtils.error('Control:general:NotSupportedSimulationImproperSys')
elseif ~isreal(D)
   ctrlMsgUtils.error('Control:general:NotSupportedSimulationComplexData')
end

% Interpret T (start, stop, step size)
[t,t0,tf,dt] = LocalGetTimeInfo(D,t);

% Initial condition
if strcmp(RespType,'initial')
   % INITIAL: eliminate input channels
   D = getsubsys(D,':',[]);
   nu = 1;
   x0 = x0(:);
   % Consistency check
   if length(x0)~=order(D)
      ctrlMsgUtils.error('Control:analysis:timeresp1')
   end
else
   % IC immaterial for step/impulse
   x0 = [];
end

% Quick exit for systems w/o inputs (step/impulse only)
if nu==0  % note: excludes initial
   if isempty(tf)  % infinite horizon
      focus = [];  tf = 1;
   else
      focus = [t0,tf];
   end
   if isempty(t)
      t = [0;tf];
   end
   Ns = length(t);
   y = zeros(Ns,ny,0);
   if ComputeX
      x = zeros(Ns,order(D),0);
   end
   return
end

% Determine if fixed-step integration is possible
isDDAE = (isCT && ~isExplicitODE(D));
if ~isDDAE
   % Compute discrete model for fixed-step integration
   % Note: TF may be adjusted for divergent systems
   [Dsim,dt,tf,SimInfo] = trespSetUp(D,RespType,dt,tf,x0);
   xx = cell(1,ComputeX);
end

% Simulate response
if isempty(tf)
   % Infinite horizon simulation with on-the-fly settling time detection
   % Note: Last point is always (t,y)=(Inf,y(Inf))
   if isDDAE
      % Requires variable-step solver to integrate state equations
      [y,t,tFocus,SimInfo,xx{1}] = ddaeresp(D,[],[],ComputeX);
      % Set focus
      switch tFocus
         case 0 % marginally stable
            tFocus = 0.1*t(end-1);
         case -1 % divergent
            tFocus = localDivergentFocusVS(t,abs(y),getMaxDelay(D));  % divergent case
      end
      focus = [t0 , tFocus];
   else
      % Can be simulated using fixed-step discretization
      if isCT
         % Adjustable step size
         % Note: This value should be larger than the max number of samples in TIMEGRID
         SimInfo.MaxSample = 15000;
      else
         % Fixed step size, unknown horizon
         SimInfo.MaxSample = 100000; 
      end
      SimInfo.DivThreshold = 1e100; % declare divergence if |y|>1e100

      % Simulate
      [y,Nfocus,xx{:}] = tresp(Dsim,RespType,[],SimInfo);
      if Nfocus==0 && isCT
         % Response has neither settled nor diverged. Retry with larger step size
         Dsim = trespSetUp(D,RespType,50*dt,[],x0);
         xx1 = cell(1,ComputeX);
         [y1,Nfocus,xx1{:}] = tresp(Dsim,RespType,[],SimInfo);
         if Nfocus~=0
            % Use second simulation if converged or diverged
            y = y1;  xx = xx1;  dt = 50*dt;
         end
      end
      Nf = size(y,1)-1;   % watch for extra point (t,y)=(Inf,y(Inf))
      
      % Adjust focus in nonconvergent cases
      switch Nfocus
         case 0 
            % Marginally stable: focus on beginning
            Nfocus = round(Nf/10);  
         case -1 
            % Divergent
            Nfocus = localDivergentFocusFS(abs(y),getMaxDelay(Dsim));
      end

      % Set time grid and focus
      t = dt*[0:Nf-1 , 1e10*Nf].';
      if isstatic(D)
         focus = []; % no focus for static gain (e.g., step(tf(1),tf(100,[1 100]))
      else
         focus = [t0,Nfocus*dt];
      end
   end

else
   % Finite-horizon simulation
   if isDDAE
      % Requires variable-step solver
      [y,t,junk,SimInfo,xx{1}] = ddaeresp(D,t,tf,ComputeX); %#ok<ASGLU>
   else
      % Can be simulated using fixed-step discretization
      Nf = ceil((1-1e3*eps)*(tf/dt));  % watch for adding extra sample when TF/DT = NF + o(eps)
      t = dt*(0:Nf).';
      [y,junk,xx{:}] = tresp(Dsim,RespType,Nf+1,SimInfo); %#ok<ASGLU>
   end
   focus = [t0,tf];

end

% State output
if ComputeX
   % Note: No X value for t=Inf in infinite-horizon case
   nx = size(D.a,1);
   x = zeros(size(y,1)-(isempty(tf)),nx,nu);
   xch = xx{1};
   for j=1:nu
      XMap = SimInfo.XMap{j};
      idxs = find(XMap>0);
      x(:,XMap(idxs),j) = xch{j}(:,idxs);
   end
   % For IMPULSE, set x(1,:,:) to x(0)+ for consistency with y1=y(0)+
   % and to enforce y = c*x
   if isCT && strcmp(RespType,'impulse')
      jzd = find(D.Delay.Input==0);
      for ct=1:length(jzd)
         j = jzd(ct);   x(1,:,j) = D.b(:,j)';
      end
   end
else
   x = [];
end

% Clip response if T0>0
if t0>0,
   keep = find(t>=t0);
   y = y(keep,:,:);
   t = t(keep);
   if ComputeX
      x = x(keep,:,:);
   end
end


%-------------------- Local Functions ---------------------------

function [t,t0,tf,dt] = LocalGetTimeInfo(D,t)
% Extracts specifications from input T to time response functions.

% Defaults
t0 = 0;
tf = [];
Ts = D.Ts;

% Final time specified
if length(t)==1
   % T is final time, not time vector
   tf = t;   t = [];
   if Ts == -1
      % Adjust tf when the sample time is unspecified
      % N samples -> simulate from 0 to N-1 (note: harmless when tf=[])
      tf = tf-1;   % n samples -> 0 to n-1
   end
end

% Time vector specified
% Assumes that T has been validated with checkTimeVector
if ~isempty(t),
   t = t(:);
   t0 = t(1);
   tf = t(end);
   % Extent T to include t=0
   dt  = t(2)-t(1);
   nt0 = round(t0/dt);
   t = [(0:dt:(nt0-1)*dt)'; t];
end

% Step size
if Ts~=0
   dt = abs(Ts);
elseif ~isempty(t),
   dt = t(2)-t(1);
else
   dt = [];
end

%----------------------------

function Nfocus = localDivergentFocusFS(y,MaxDelay)
% Adjusts focus of divergent simulations (fixed step case). Goal is to 
% avoid plots looking like _|. Require that |y|>a*ymax for some t<(1-a)*tf
% where a<0.1
a = 0.05;
Nfocus = size(y,1);
Nmin = max(50,2*MaxDelay);
while Nfocus>2*Nmin && ...
      any(max(y(1:round((1-a)*Nfocus),:)) < a*max(y(1:Nfocus-1,:)))
   Nfocus = round(Nfocus/2);
end


%----------------------------

function tFocus = localDivergentFocusVS(t,y,MaxDelay)
% Adjusts focus of divergent simulations (variable step case)
a = 0.05;
tFocus = t(end-1);
tmin = max(t(min(50,end)),2*MaxDelay);
while tFocus>2*tmin && ...
      any(max(y(t<(1-a)*tFocus,:)) < a*max(y(t<tFocus,:)))
   tFocus = t(find(t>tFocus/2,1));
end
