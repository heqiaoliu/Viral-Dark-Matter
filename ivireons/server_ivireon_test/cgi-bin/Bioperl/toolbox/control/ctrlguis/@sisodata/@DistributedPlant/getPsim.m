function Psim = getPsim(this)
% Returns augmented plant model Psim used for closed-loop analysis 
% and simulation.

%   Author(s): P. Gahinet
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2008/05/19 22:43:29 $
if all(this.LoopStatus)
   % Use open-loop model
   Psim = getP(this);
else
   if isempty(this.Psim)
      % Recompute closed-loop model
      nG = length(this.G);
      
      % Compute interconnection matrix for closed-loop simulation (taking 
      % into account open/closed status of each loop)
      e = this.LoopSign .* this.LoopStatus;
      IC = this.loopIC(this.Configuration,e);
      [ny,nu] = size(IC);
      
      % Build @ssdata model for IC matrix
      Ts = this.G(1).SSData.Ts;
      D = ltipack.ssdata([],zeros(0,nu),zeros(ny,0),...
         IC([nG+1:ny,1:nG],[nG+1:nu,1:nG]),[],Ts);
      
      % Build vector of state-space models of G1,G2,...
      G = ltipack.ssdata.array([nG 1]);
      for ct=1:nG
         G(ct) = this.G(ct).SSData;
      end
      
      % Close each fixed model loop 
      this.Psim = utSISOLFT(D,G);
   end
   Psim = this.Psim;
end

