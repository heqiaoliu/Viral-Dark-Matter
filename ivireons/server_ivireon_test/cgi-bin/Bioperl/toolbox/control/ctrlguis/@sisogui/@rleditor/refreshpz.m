function refreshpz(this,event,PZGroup)
% Refreshes plot while dynamically modifying poles and zeros of edited
% compensator.

%   Author(s): P. Gahinet
%   Revised  : N. Hickey
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.6.2.1 $  $Date: 2010/07/01 20:42:24 $

% Process events
switch event 
case 'init'   
    % Switch editor's RefreshMode to quick
    this.RefreshMode = 'quick';
    
    % Find related PZVIEW objects
    C = PZGroup.Parent;
    pzglist = get(this.EditedPZ(:,1),{'GroupData'});
    PZView = this.EditedPZ(PZGroup == [pzglist{:}]);
    this.setEditedBlock(C);
    
    % Use NGAINS gain values for root locus refreshing
    nGains = 25;  % Number of gain values while dragging
    MinGain = log10(this.LocusGains(2));
    MaxGain = log10(this.LocusGains(end-2));
    LocusGains = [this.LocusGains(1) , ...
            logspace(MinGain,max(MinGain+1,MaxGain),nGains) , ...
            this.LocusGains(end-1:end)];
    
    % Install listener on PZGROUP (modified pole/zero group)
    L = handle.listener(PZGroup,'PZDataChanged',...
       @(x,y) LocalUpdatePlot(this,PZGroup,PZView,LocusGains));
    this.EditModeData = L;
    
case 'finish'
    % Clean up after dynamic gain update (drag)
    % Return editor's RefreshMode to normal
    this.RefreshMode = 'normal';
    
    % Delete listener
    delete(this.EditModeData);
    this.EditModeData = [];
end


%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalUpdatePlot %%%
%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdatePlot(this,PZGroup,PZView,LocusGains)
% Update plot by moving compensator pole/zero and redrawing locus
Ctb = this.GainTargetBlock;
OL = getOpenLoop(this.LoopData.L(this.EditedLoop),Ctb);  % normalized open-loop
if ~isfinite(OL)
   return
end
CurrentGain = getZPKGain(Ctb,'mag');

% Use pade to approximate delays compute delays
OL = this.utApproxDelay(OL);

% Update position of moved pole/zero
MovedHandles = [PZView.Zero;PZView.Pole];
NewValues = [PZGroup.Zero;PZGroup.Pole];
for ct=1:length(MovedHandles)
    set(MovedHandles(ct),...
        'Xdata',real(NewValues(ct)),'Ydata',imag(NewValues(ct)))
end

% Update locus data and closed-loop locations
% RE: Use 'refine' flag to include branch crossing gains 
%     for increased smoothness
[Roots,Gains] = rlocus(OL,[LocusGains,CurrentGain],'refine');
this.LocusRoots  = Roots;
this.ClosedPoles = Roots(:,Gains==CurrentGain);
this.LocusGains  = Gains;

% Update plot
HG = this.HG;
if ~isempty(Roots)
    Nroot = size(Roots,2);
    for ct=1:length(this.HG.Locus)
        set(HG.Locus(ct),...
            'Xdata',real(Roots(ct,:)),...
            'Ydata',imag(Roots(ct,:)),...
            'Zdata',this.zlevel('curve',[1 Nroot]))
    end
    for ct=1:length(this.ClosedPoles)
        set(HG.ClosedLoop(ct),...
            'Xdata',real(this.ClosedPoles(ct)),...
            'Ydata',imag(this.ClosedPoles(ct)))
    end
end

%%%%%%% Update MultiModel bounds
if this.isMultiModelVisible
    L = this.getL;
    CLPolesa = [];
    for ct = 1:length(this.UncertainData)
        CLPolesa = [CLPolesa;rlocus(this.utApproxDelay(getOpenLoop(L,Ctb,ct)),CurrentGain)];
    end
    this.UncertainBounds.setData(CLPolesa)
end


