function [y,Nfocus] = tresp(Dsim,RespType,Ns,SimInfo)
% Time responses (step or impulse) of MIMO transfer functions.
% 
% Inputs:
%   * Dsim: Discrete MIMO @tfdata model
%   * Resptype: 'step' or 'impulse'
%   * Ns: number of time steps (set to [] for automatic selection)
%   * SimInfo: structure containing stability and DC info for 
%              settling time detection (used only for Ns=[])
%
% Outputs:
%   * y: output history (ns-by-ny-by-nu)
%   * nFocus: Number of time steps to be shown by default in plots
%     (-1 if divergent, 0 if the response has neither settled nor 
%      diverged)

%	 Author: P. Gahinet
%   Copyright 1986-2007 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:33:06 $
[ny,nu] = iosize(Dsim);

if isempty(Ns)
   % Infinite-horizon simulation (terminates when response settles
   % or diverges)
   [y,Nfocus] = tfresp(Dsim,RespType,SimInfo);
   y = permute(y,[3 1 2]);
   
else
   % Finite-horizon simulation
   Nfocus = Ns;
   switch RespType
      case 'step'
         u = ones(Ns,1);
      case 'impulse'
         u = [1 ; zeros(Ns-1,1)];
   end
   
   % Allocate space for output
   y = zeros(Ns,ny,nu);
   % Limit delays to simulation horizon to avoid "out of memory" errors in TFSIM
   iod = min(getIODelay(Dsim,'total'),Ns);
   for j=1:nu
      nj = Dsim.num(:,j);
      dj = Dsim.den(:,j);
      iodj = iod(:,j);  
      % Simulate
      InitState = linsimstate('tf',nj,dj,iodj);
      y(:,:,j) = tfsim(nj,dj,iodj,u,InitState);
   end
end
