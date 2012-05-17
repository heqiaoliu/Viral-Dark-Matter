function refresh(this,event,C,PZGroup)
% Refreshes plot during dynamic edit of some other compensator 
% than the locally edited compensator.

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $  $Date: 2010/04/30 00:37:02 $

% Process events
switch event 
case 'init'
   % Initialization for dynamic gain update (drag).
   this.RefreshMode = 'quick';
   
   % Externally edited compensator C
   LoopData = this.LoopData;
   
   % Use NGAINS gain values for root locus refreshing
   LocusGains = this.LocusGains;
   npts = length(LocusGains);
   if npts>0  % Watch for empty locus (zero plant)
      if npts>4
         nGains = 25;  % Number of gain values while dragging
         MinGain = log10(LocusGains(2));
         MaxGain = log10(LocusGains(npts-2));
         LocusGains = [LocusGains(1) , logspace(MinGain,MaxGain,nGains) , ...
            LocusGains([npts-1,npts])];
      end
      L = LoopData.L(this.EditedLoop);
      % Precompute parameterized (wrt C) open-loop model for fast update
      S = pOpenLoop(L,C,this.EditedBlock);
      
      % Add multimodel info
      if this.isMultiModelVisible
          for ct = numel(L.TunedLFT.IC):-1:1
              % Precompute parameterized (wrt C) open-loop model for fast
              % update
              S.MultiModelData(ct) = pOpenLoop(L,C,this.EditedBlock,ct);
          end
      else
          S.MultiModelData =[];
      end
      
      
      
      % Loop gain
      LoopGain = getZPKGain(this.EditedBlock,'mag');

      % Install listener to change in data
      if nargin==3
         % Gain editing
         this.EditModeData = ...
            handle.listener(C,findprop(C,'Gain'),'PropertyPostSet',@(x,y) LocalUpdate(this,LocusGains,C,S,LoopGain));
      else
         this.EditModeData = ...
            handle.listener(PZGroup,'PZDataChanged',@(x,y) LocalUpdate(this,LocusGains,C,S,LoopGain));
      end
   end
      
case 'finish'
   % Return editor's RefreshMode to normal
   this.RefreshMode = 'normal';
   
   % Delete listener
   delete(this.EditModeData);
   this.EditModeData = [];
   
end


%-------------------------Local Functions-------------------------

function LocalUpdate(this,LocusGains,C,S,LoopGain)
% Update root locus plot when editing external compensator

% Close the loop around the externally edited compensator C
% and build the open-loop model
G = utSISOLFT(S.G22,ss(C));     % @ssdata, not necessarily s-minimal
OL = mtimes(G,S.C,false(1,2));  % s.C = total TunedFactor for this Editor

% Use pade to approximate delays
OL = this.utApproxDelay(OL);

% Update locus data and closed-loop locations
[Roots,Gains,Info] = rlocus(OL,[LocusGains,LoopGain],'refine');
this.LocusRoots  = Roots;
this.ClosedPoles = Roots(:,Gains==LoopGain);
this.LocusGains  = Gains;

% Get plant dynamics (open-loop dynamics minus tuned factors' dynamics)
if Info.InverseFlag
   zG = rootdiff(Info.Pole,S.TunedZero);
   pG = rootdiff(Info.Zero,S.TunedPole);
else
   zG = rootdiff(Info.Zero,S.TunedZero);
   pG = rootdiff(Info.Pole,S.TunedPole);
end

% Update plot
% Note: Skip update if the number of roots if inconsistent with its 
% generic value (could happen if the gain of C becomes zero because 
% RLOCUS will then eliminate structurally nonminimal modes. Can also
% happen due to pole/zero cancellations, see g323031 for an example)
HG = this.HG;
if ~isempty(Roots) && size(Roots,1)==length(HG.ClosedLoop)
    nGains = length(Gains);
    for ct=1:length(this.HG.Locus)
        set(HG.Locus(ct),...
            'Xdata',real(Roots(ct,:)),...
            'Ydata',imag(Roots(ct,:)),...
            'Zdata',this.zlevel('curve',[1 nGains]))
    end
    for ct=1:length(this.ClosedPoles)
        set(HG.ClosedLoop(ct),...
            'Xdata',real(this.ClosedPoles(ct)),...
            'Ydata',imag(this.ClosedPoles(ct)))
    end
end

% Update multimodel data
if ~isempty(S.MultiModelData)
    CLPolesa = [];
    this.UncertainData=struct('OpenLoopData',[]);
    for ct = length(S.MultiModelData):-1:1
        R = S.MultiModelData(ct);
        G = utSISOLFT(R.G22,ss(C));     % @ssdata, not necessarily s-minimal
        OL = mtimes(G,R.C,false(1,2));  % s.C = total TunedFactor for this Editor
        
        % Use pade to approximate delays
        OL = this.utApproxDelay(OL);
        [~,~,RLInfoa] = rlocus(OL);
        this.UncertainData(ct).OpenLoopData=RLInfoa;
        CLPolesa = [CLPolesa;fastrloc(RLInfoa,LoopGain)];
    end
    this.UncertainBounds.setData(CLPolesa)
end


% Update position of plant poles
% Note: Beware that roots can appear or disappear due to rounding errors
%       and singularities such as algebraic loops
nobj = length(HG.System);
npG = length(pG);  
nzG = length(zG);
for ct=1:min(nobj,npG)
   set(HG.System(ct),'XData',real(pG(ct)),'YData',imag(pG(ct)),'Marker','x','MarkerSize',6)
end
for ct=1:min(nobj-npG,nzG)
   set(HG.System(npG+ct),'XData',real(zG(ct)),'YData',imag(zG(ct)),'Marker','o','MarkerSize',5)
end
set(HG.System(npG+nzG+1:end),'XData',nan,'YData',nan)

