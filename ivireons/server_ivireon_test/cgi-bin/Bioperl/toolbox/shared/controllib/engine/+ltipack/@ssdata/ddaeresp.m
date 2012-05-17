function [y,t,Tfocus,SimInfo,xch] = ddaeresp(D,t,Tf,ComputeX)
% Step response of continuous-time state-space models with state delays.

%	 Author: P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:30:53 $
[ny,nu] = iosize(D);
nx = size(D.a,1);
xch = cell(nu,1);
XMap = (1:nx)';

% Resolve sim horizon
if isempty(Tf)
   if isempty(t)
      Tf = inf;
   else
      % user-defined time grid T
      Tf = t(end);
   end
end
InfHorizon = (isinf(Tf));

% Allocate SimInfo struct
SimInfo = struct(...
   'FinalValue',[],...       % anticipated final value (assuming convergence)
   'IC',[],...               % initial condition x[0]
   'MaxSample',10000,...     % max number of time steps in simulation
   'DivThreshold',1e100,...  % divergence threshold (|y|>DivThreshold -> diverged)
   'XMap',{cell(nu,1)});     % to recover state of original model from

% Final value data (infinite-horizon sim only)
if InfHorizon
   SimInfo.FinalValue = dcgain(D);
end
   
% Extract s-minimal realization for each input channel
for j=nu:-1:1
   [Dsim(j,1),xkeep] = getsubsys(D,':',j,'min');
   % XMap keeps track of where the remaining states are in
   % the original state vector
   SimInfo.XMap{j,1} = XMap(xkeep);
end

% Extract and package data for simulating each input channel
[Data,DiscSet] = localBuildSolverData(Dsim,Tf,nx);

% Integrate DDAE
% Sol: nu-by-1 struct array of time histories for each input channel
rtol = 1e-3;  atol = 1e-8;
[Sol,Tfocus,yf] = ddaeresp(Data,SimInfo,atol,rtol);

% Project simulations onto common time grid
Dout = D.Delay.Output;
if ComputeX
   [y,t,xch] = mergeresp(Sol,Dout,DiscSet,t,Tfocus);
   for ct=1:length(xch)
      % Note: Account for scaling in localBuildSolverData
      xch{ct} = lrscale(xch{ct}.',[],Data(ct).s);
   end
else
   [y,t] = mergeresp(Sol,Dout,DiscSet,t,Tfocus);
end

% Add t=Inf point to (t,y) to avoid recomputing response when x limits change
if InfHorizon
   t = [t; 1e10*t(end)];
   y = cat(1,y,reshape(yf,[1 ny nu]));
end


%---------------- Local Functions ----------------------

function [Data,DiscSet] = localBuildSolverData(Dsim,Tf,nxf)
% Constructs data structure for DDAERESP solver
%   * Tf: final time
%   * nxf: full order of MIMO model
hw = ctrlMsgUtils.SuspendWarnings; %#ok<NASGU>
nu = length(Dsim);
% Coefficients for two-point Radau IIA implicit Runge-Kutta method.
x11 = 5/12; x12 = -1/12; x21 = 0.75; x22 = 0.25;

Data = struct('nx',cell(nu,1),'ulag',[],'zlags',[],...
   'D',[],'ABCD',[],'H',[],'U',[],'s',[]);
jfull = 0;
for j=1:nu
   % Extract and package data for j-th channel
   Dj = Dsim(j);
   [a,~,b2,~,c2,~,~,d21,d22] = getBlockData(Dj);
   nx = size(a,1);
   % Scale state vector for numerical stability
   if nx<nxf || jfull==0
      % Scale A matrix of zero-order Pade appx (good approximation of DC dynamics)
      sm = a+b2*((eye(size(d22))-d22)\c2);
      if hasInfNaN(sm)
         sm = a;
      end
      s = mscale(sm,'noperm','safebal');
   else
      % Reuse previously computed scaling for full order
      s = Data(jfull).s;
   end
   a = lrscale(a,1./s,s);
   Data(j).ABCD = [a lrscale(Dj.b,1./s,[]) ; lrscale(Dj.c,[],s) Dj.d];   
   Data(j).nx = nx;   
   Data(j).s = s;
   % Compute Hessenberg form of kron(x,a)
   if nx<nxf || jfull==0
      [Data(j).U,Data(j).H] = hess([x11*a x12*a;x21*a x22*a]);
      if nx==nxf
         jfull = j;
      end
   else
      Data(j).U = Data(jfull).U;  
      Data(j).H = Data(jfull).H;
   end
   % Construct vector of discontinuity points for x'(t)
   zlags = Dj.Delay.Internal;
   ulag = Dj.Delay.Input;
   if isempty(zlags)
      Data(j).D = [ulag Tf];
   else
      lags = sort(zlags);
      lags(diff(lags)==0,:) = [];
      if norm(d21,inf)==0 || norm(d22,inf)==0
         maxlevel = 1;
      else
         maxlevel = 4;
      end
      Data(j).D = propagate(ulag,lags,Tf,maxlevel);
   end
   Data(j).zlags = zlags;
   Data(j).ulag = ulag;
end
   
% All discontinuity points
DiscSet = sort(cat(2,Data.D));
DiscSet = DiscSet([true,diff(DiscSet)>0]);
