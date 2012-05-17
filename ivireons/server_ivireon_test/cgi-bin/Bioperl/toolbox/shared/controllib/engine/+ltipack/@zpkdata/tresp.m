function [y,Nfocus] = tresp(Dsim,RespType,Ns,SimInfo)
% Time responses (step or impulse) of MIMO ZPK models.
% 
% Inputs:
%   * Dsim: Discrete MIMO @zpkdata model
%   * RespType: 'step' or 'impulse'
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
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:34:00 $
[ny,nu] = iosize(Dsim);

if isempty(Ns)
   % Infinite-horizon simulation (terminates when response settles
   % or exhibits instability)
   [y,Nfocus] = zpkresp(Dsim,RespType,SimInfo);
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
   % Note: Limit delays to simulation horizon to avoid "out of memory"
   % errors in ZPKSIM
   iod = min(getIODelay(Dsim,'total'),Ns);
   for j=1:nu
      zj = Dsim.z(:,j);
      pj = Dsim.p(:,j);
      kj = Dsim.k(:,j);
      iodj = iod(:,j);
      % Sort roots (to reduce risk of overflow and need for special handling)
      for ct=1:ny
         zj{ct} = LocalSortRoots(zj{ct});
         pj{ct} = LocalSortRoots(pj{ct});
      end
      InitState = linsimstate('zpk',zj,pj,iodj);
      y(:,:,j) = zpksim(zj,pj,kj,iodj,u,InitState);
   end
end


%--------------------- Local Functions -----------------------------

function rs = LocalSortRoots(r)
% Puts complex roots upfront
iscplx = (imag(r)~=0);
rs = [r(iscplx) ; r(~iscplx)];
