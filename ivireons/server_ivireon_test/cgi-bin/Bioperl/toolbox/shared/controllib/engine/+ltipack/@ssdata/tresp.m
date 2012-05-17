function [y,Nfocus,xch] = tresp(Dsim,RespType,Ns,SimInfo)
% Time responses (step, impulse, or initial) of MIMO state-space systems.
% 
% Inputs:
%   * Dsim: Nu-by-1 vector of discrete single-input @ssdata models
%   * Resptype: 'step', 'impulse', or 'initial'
%   * Ns: number of time steps (set to [] for automatic selection)
%   * SimInfo: structure containing
%     -> DC info for settling time detection (used only for Ns=[])
%     -> initial state (used only for 'initial')
%
% Outputs:
%   * y: output history (ns-by-ny-by-nu)
%   * nFocus: Number of time steps to be shown by default in plots
%     (-1 if divergent, 0 if the response has neither settled nor 
%      diverged)
%   * xch: state history for each input channel (1-by-nu cell array 
%          of ns-by-nx arrays)

%	 Author: P. Gahinet
%   Copyright 1986-2007 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:31:49 $
ComputeX = (nargout>2);
nu = length(Dsim);
[ny,junk] = iosize(Dsim(1)); %#ok<NASGU>
xch = cell(nu,1);

% Initial state 
% RE: NU=1 when x0 is specified (INITIAL) 
x0 = SimInfo.IC;

if isempty(Ns)
   % Infinite-horizon simulation
   % RE: Terminates when response settles or exceeds divergence threshold
   InitRespFlag = strcmp(RespType,'initial');
   XResp = (InitRespFlag && ny==0);
   
   % Special handling of case ny=0 with INITIAL (g277595)
   if XResp
      % Track states as outputs for settling detection
      Dsim = augstate(Dsim);
      ny = size(Dsim.a,1);
      SimInfo.FinalValue = zeros(ny,1);
   end
   
   % Simulate
   if ComputeX
      [y,Nfocus,xch] = ssresp(Dsim,RespType,SimInfo,x0);
      for j=1:nu
         xch{j} = xch{j}.';
      end
   else
     [y,Nfocus] = ssresp(Dsim,RespType,SimInfo,x0);
   end
   
   % Output history
   if XResp
      y = zeros(size(y,3),0);
   else
      y = permute(y,[3 1 2]);
   end
   
else
   % Finite-horizon simulation
   Nfocus = Ns;
   switch RespType
      case 'step'
         u = ones(1,Ns);
      case 'impulse'
         u = [1 zeros(1,Ns-1)];
      case 'initial'
         u = zeros(0,Ns);
   end
   
   % Compute response for each input channel
   y = zeros(Ns,ny,nu);
   NoIC = isempty(x0);
   for j=1:nu
      Dj = Dsim(j);
      % Initial state
      if NoIC
         x0 = zeros(size(Dj.a,1),1);
      end
      % Limit discrete delays to the number of samples (g172142)
      InitState = linsimstate('ss',x0,...
         min(Dj.Delay.Input,Ns),min(Dj.Delay.Output,Ns),...
         min(Dj.Delay.Internal,Ns));
      % Simulate response
      if ComputeX
         [yj,junk,xj] = sssim(Dj.a,Dj.b,Dj.c,Dj.d,[],u,InitState);
         xch{j} = xj.';
      else
         yj = sssim(Dj.a,Dj.b,Dj.c,Dj.d,[],u,InitState);
      end
      y(:,:,j) = yj.';
   end

end
