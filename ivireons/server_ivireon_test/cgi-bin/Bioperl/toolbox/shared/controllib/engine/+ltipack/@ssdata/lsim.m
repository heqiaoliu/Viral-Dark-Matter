function [y,x] = lsim(D,u,t,x0,InterpRule)
% Linear response simulation of state-space model.
% RE: Assume U is Ns x Nu and T has Ns samples.

%	 Author: P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%	 $Revision: 1.1.8.2 $  $Date: 2010/02/17 18:58:19 $
ComputeX = (nargout>1);
[Ns,nu] = size(u);
dt = t(2)-t(1);
Ts = D.Ts;

% Computability and consistency checks
% 1) Remove zero internal delays (can create artificial DDAEs). Do it in 
% discrete time as well (g353999) and before ISPROPER to deal with singular loops
% 2) Eliminate E matrix especially in discrete time (g560840, g346680)
[isProper,D] = isproper(elimZeroDelay(D),'explicit');
if ~isProper
   ctrlMsgUtils.error('Control:general:NotSupportedImproperSys','lsim')
elseif ~isreal(D)
   ctrlMsgUtils.error('Control:general:NotSupportedComplexData','lsim')
end

% Select interpolation rule if unspecified
if Ts==0 && strcmp(InterpRule,'auto')
   InterpRule = utSelectInterp(u);
end

% Branch based on the integration technique
if Ts~=0 || isExplicitODE(D)
   % Explicit integration: D is discrete or can be discretized
   nx = size(D.a,1);
   if isempty(x0)
      x0 = zeros(nx,1);
   elseif length(x0)~=nx
      ctrlMsgUtils.error('Control:analysis:lsim2')
   end
   u = u.'; % now nu-by-Ns

   % Discretize continuous models
   ZOHSim = false;
   if Ts==0
      % Check for undersampling
      LocalCheckSampling(D,dt)
      % Discretize
      switch InterpRule
         case 'zoh'
            [D,~,ICMap] = utDiscretizeZOH(D,dt,(1:nx)');
         case 'foh'
            % FOH discretization produces the model
            %     z[k+1] = exp(A*dt) * z[k] + Bd * u[k]
            %       y[k] =     Cd    * z[k] + Dd * u[k]
            % where z[k] = x[k] + G * u[k].  For simulation, the initial condition
            % must be set to z[0]=x0+G*u[0], and the state trajectory is obtained
            % as z[k] - G * u[k].
            % RE: Direct FOH simulation runs into trouble for delayed input
            %     channels with nonzero u(1) (FOH implicitly interpolates the
            %     input between u=0 at t=-dt and the first value u=u(1) at t=0).
            %     Similarly, for outputs delayed by tau, the FOH simulation yields
            %     y[0] = Cx[-tau] where x[-tau] is computed assuming a linear
            %     input u(t) with value 0 at t=-dt and u(1) at t=0, whereas the
            %     true input is 0 for t<0.  When there are delays, set u[0]=0
            %     for all channels and separately simulate the response to
            %     the step offset w(t)=u[0] with ZOH method.
            if hasdelay(D) && any(u(:,1)~=0)
               ZOHSim = true;
               u0 = u(:,1);
               u = u - u0(:,ones(1,Ns));
               Dzoh = utDiscretizeZOH(D,dt,(1:nx)');
            end
            [D,~,ICMap] = utDiscretizeFOH(D,dt,(1:nx)');
      end
      % Update initial condition
      x0 = ICMap * [x0 ; u(:,1)];
   end

   % Simulate with SSSIM
   % RE: * D is discrete at this point
   %     * Limit discrete delays to the number of samples (g172142)
   x0 = linsimstate('ss',x0,min(D.Delay.Input,Ns),...
      min(D.Delay.Output,Ns),min(D.Delay.Internal,Ns));
   if ComputeX
      [y,~,z] = sssim(D.a,D.b,D.c,D.d,[],u,x0);
      % x[k] = z[k] - G * u[k]
      x = z(1:nx,:);
      if Ts==0
         for j=1:nu
            Din = min(D.Delay.Input(j),Ns);
            u(j,:) = [zeros(1,Din) , u(j,1:Ns-Din)];
         end
         x = x - ICMap(1:nx,nx+1:nx+nu) * u;
      end
   else
      y = sssim(D.a,D.b,D.c,D.d,[],u,x0);
   end

   % Correct u[0] offsets in continuous-time FOH simulation with delay
   if ZOHSim
      x0 = linsimstate('ss',zeros(size(Dzoh.a,1),1),...
         min(Dzoh.Delay.Input,Ns),min(Dzoh.Delay.Output,Ns),...
         min(Dzoh.Delay.Internal,Ns));
      u = u0(:,ones(1,Ns));
      if ComputeX
         [yc,~,xc] = sssim(Dzoh.a,Dzoh.b,Dzoh.c,Dzoh.d,[],u,x0);
         x = x + xc(1:nx,:);
      else
         yc = sssim(Dzoh.a,Dzoh.b,Dzoh.c,Dzoh.d,[],u,x0);
      end
      y = y + yc;
   end

   % Format output arrays
   y = y.';
   if ComputeX
      x = x.';
   end

else
   % Simulate with DDAE solver
   if any(x0)
      ctrlMsgUtils.error('Control:analysis:lsim4');
   end
   if ComputeX
      [y,x] = ddaesim(D,u,t,InterpRule);
   else
      y = ddaesim(D,u,t,InterpRule);
   end

end

%------------ Local Functions ------------------------------

function LocalCheckSampling(D,dt)
% Check for undersampling of u(t) for continuous-time simulation
% (issues warning with recommended sampling)
nx = size(D.a,1);
if ~isnan(dt) && nx>0 && nx<100,
   r = eig(D.a);
   r = r(imag(r)>0 & abs(real(r))<0.2*abs(r));   % resonant modes
   mf = max(abs(r));        % frequency of fastest resonant mode
   if mf>pi/dt/2,
       [~,ee] = log2(pi/2/mf);
       ctrlMsgUtils.warning('Control:analysis:LsimUndersampled',...
           sprintf('%g',pow2(ee-1)))
   end   
end
