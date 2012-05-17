function [Dsim,dt,tf,SimInfo] = trespSetUp(D,RespType,dt,tf,x0)
% Builds single-input models for independent simulation of each  
% input channel.  Used by STEP, IMPULSE, and INITIAL. 
%
% Inputs:
%   * D is either a single MIMO ssdata model (ss model), or a vector 
%     of Nu single-input ssdata models (derived from continuous tf  
%     and zpk models). D should have no E matrix and no state delays. 
%   * dt: user-defined sampling time ([] if none)
%   * tf: final time ([] if unspecified)
%   * x0: the initial condition (can be [])
%
% Outputs:
%   * Dsim: vector of single-input models for simulating each 
%     input channel (continuous if there are state delays, 
%     discrete otherwise)
%   * dt: sampling time of Dsim
%   * tf: adjusted final time
%   * SimInfo: structure containing various info for simulation

%	 Author: P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:31:50 $
SingleModel = isscalar(D);
if SingleModel
   [ny,nu] = iosize(D);
   nu = max(nu,1);
   isCT = (D.Ts==0);
else
   % D comes from conversion of continuous-time multi-input TF or ZPK model
   nu = length(D);
   ny = size(D(1).d,1);
   isCT = true;
end   
NoTs = (isCT && isempty(dt));
NoTf = isempty(tf);

% Allocate SimInfo struct
SimInfo = struct(...
   'FinalValue',[],...       % anticipated final value (assuming convergence)
   'IC',[],...               % initial condition x[0]
   'MaxSample',[],...        % max number of time steps in simulation
   'DivThreshold',[],...     % divergence threshold (|y|>DivThreshold -> diverged)
   'XMap',{cell(nu,1)});     % to recover state of original model from
                             % discrete state used for simulation
                             % (one map per each input channel)
                             
% Build MIMO model for computing simulation range, fixed step, and other info
if NoTs || NoTf
   if SingleModel
      Dmi = D;
   else
      % Fast horzcat (ignores delays)
      [a,b,c,d] = getABCD(D(1));
      for j=2:nu
         [aj,bj,cj,dj] = getABCD(D(j));
         [a,b,c,d] = ssops('hcat',a,b,c,d,[],aj,bj,cj,dj,[]);
      end
      Dmi = ltipack.ssdata(a,b,c,d,[],D(1).Ts);
   end
end


% If D is continuous, determine adequate step size for simulation
% Note: no attempt to assess stability, response may still converge when
%       unstable, e.g., impulse(tf(1,[1 2 0])) or g339096
if NoTs
   % Compute largest delay
   MaxDelay = getMaxDelay(D);
   % Estimate dt and tf
   [a,b,c,d] = getABCD(Dmi);
   switch RespType
      case 'step'
         hw = ctrlMsgUtils.SuspendWarnings; 
         beq = -a\b;
         delete(hw);
      case 'impulse'
         beq = b;
      case 'initial'
         d = zeros(ny,1);
         beq = x0;
   end
   dt = timegrid(a,beq,c,d,MaxDelay,tf);
end  

% When sim. horizon Tf is undefined, cache stability and DC value
if NoTf
   % Steady-state value 
   % Note: Response may converge to difference final value if there are pole/zero
   %       cancellations at s=0 or z=1
   SimInfo.FinalValue = getFinalValue(Dmi,RespType,x0);
end


% Build models for independent input channel simulation
if SingleModel
   % Single (possibly multi-input) model
   nx = size(D.a,1);
   XMap = (1:nx)';
   if isCT
      % Discretize MIMO continuous-time model at rate DT
      switch RespType
         case {'step','initial'}
            [D,XMap] = utDiscretizeZOH(D,dt,XMap);
         case 'impulse'
            [D,XMap] = utDiscretizeIMP(D,dt,XMap);
      end
      % Update initial condition to account for augmented state
      if ~isempty(x0)
         ic = zeros(length(XMap),1);
         idx = find(XMap);
         ic(idx) = x0(XMap(idx));
         x0 = ic;
      end
   end
   % Build submodels for each input channel
   if nu==1
      Dsim = D;
      SimInfo.IC = x0;  % initial calls go through here
      SimInfo.XMap = {XMap};
   else
      for j=nu:-1:1
         % Discard non s-minimal discrete states
         [Dsim(j,1),xkeep] = getsubsys(D,':',j,'min');
         % XMap keeps track of where the remaining states are in
         % the original state vector
         SimInfo.XMap{j,1} = XMap(xkeep);
      end
   end

else
   % Discretize each single-input model
   % Note: initial not supported in this case (original model is tf or zpk)
   Dsim = D;
   switch RespType
      case 'step'
         for j=1:nu
            nx = size(Dsim(j).a,1);
            Dsim(j) = utDiscretizeZOH(Dsim(j),dt,(1:nx)');
         end
      case 'impulse'
         for j=1:nu
            nx = size(Dsim(j).a,1);
            Dsim(j) = utDiscretizeIMP(Dsim(j),dt,(1:nx)');
         end
   end
end

