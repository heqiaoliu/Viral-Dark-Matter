function [y,x] = ddaesim(D,u,t,InterpRule)
% Linear simulation of continuous-time state-space model with internal delays.

%	 Author(s): L. Shampine, P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:30:54 $
ns = length(t);
nx = size(D.a,1);
[ny,nu] = iosize(D);
t = t - t(1);
ComputeX = (nargout>1);

% Integrate DDAE
y = zeros(ns,ny);
if strcmp(InterpRule,'zoh')
   % Piecewise constant input
   % Compute response of each input channel to step input
   [ys,~,~,SimInfo,xch] = ddaeresp(D,t,t(end),ComputeX);
   if ComputeX
      xs = zeros(ns,nx,nu);
      for j=1:nu
         XMap = SimInfo.XMap{j};
         idxs = find(XMap>0);
         xs(:,XMap(idxs),j) = xch{j}(:,idxs);
      end
      x = zeros(ns,nx);
   end
   
   % Construct simulation output by superposition
   for j=1:nu
      du = diff([0;u(:,j)]);
      iJump = find(du~=0);
      for ct=1:length(iJump),
         i = iJump(ct);
         jump = du(i);
         y(i:ns,:) = y(i:ns,:) + jump * ys(1:ns-i+1,:,j);
         if ComputeX
            x(i:ns,:) = x(i:ns,:) + jump * xs(1:ns-i+1,:,j);
         end
      end
   end
   
else
   % Piecewise linear input
   % Package data for DDAESIM mex file
   [Data,DiscSet] = localBuildSolverData(D,u,t);
   ylags = D.Delay.Output;

   % Integrate DDAE
   rtol = 1e-3;  atol = 1e-8;
   Sol = ddaesim(Data,u,t(2)-t(1),atol,rtol);
   
   % Interpolate solution onto time grid T
   for i=1:ny
      y(:,i) = interpresp(t-ylags(i),DiscSet,...
         Sol.t,Sol.y(i,:),Sol.yL1(i,:),Sol.yL3(i,:));
   end
   if ComputeX
      x = interpresp(t,DiscSet,Sol.t,Sol.x,Sol.xL1,Sol.xL3);
      x = lrscale(x.',[],Data.s);
   end
end

  
%---------------- Local Functions ----------------------

function [Data,DiscSet] = localBuildSolverData(D,u,t)
% Constructs data structure for DDAESIM solver
[a,~,b2,~,c2,~,~,d21,d22] = getBlockData(D);

% Construct vector of discontinuity points for x'(t)
Tf = t(end);
zlags = D.Delay.Internal;
ulags = D.Delay.Input;
u_turned_on = min(ulags);  
if isempty(zlags)
   DiscSet = [u_turned_on Tf];
else
   lags = sort(zlags);
   lags(diff(lags)==0,:) = [];
   if norm(d21,inf)==0 || norm(d22,inf)==0 || norm(u(1,:),1)==0
      maxlevel = 1;
   else
      maxlevel = 4;
   end
   DiscSet = propagate(u_turned_on,lags,Tf,maxlevel);
end

Data = struct(...
   'nx',[],...
   'ulags',ulags,...
   'zlags',zlags,...
   'D',DiscSet,...
   'ABCD',[],'H',[],'U',[],'s',[]);

% Scale A matrix of zero-order Pade appx (good approximation of DC dynamics)
hw = ctrlMsgUtils.SuspendWarnings; %#ok<NASGU>
sm = a+b2*((eye(size(d22))-d22)\c2);
if hasInfNaN(sm)
   sm = a;
end
s = mscale(sm,'noperm','safebal');
a = lrscale(a,1./s,s);
Data.ABCD = [a lrscale(D.b,1./s,[]) ; lrscale(D.c,[],s) D.d];   
Data.nx = length(s);
Data.s = s;

% Compute Hessenberg form of kron(x,a)
% Coefficients for two-point Radau IIA implicit Runge-Kutta method.
x11 = 5/12; x12 = -1/12; x21 = 0.75; x22 = 0.25;
[Data.U,Data.H] = hess([x11*a x12*a;x21*a x22*a]);

