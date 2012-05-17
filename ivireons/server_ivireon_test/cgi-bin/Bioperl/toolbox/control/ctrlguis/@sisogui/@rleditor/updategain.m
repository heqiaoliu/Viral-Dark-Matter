function updategain(this)
%UPDATEGAINC  Lightweight plot update when modifying the loop gain.

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2010/05/10 16:59:27 $

% RE: Assumes gain does not change sign
if ~this.Enabled || strcmp(this.EditMode,'off') || strcmp(this.Visible,'off') || this.SingularLoop
   % this is inactive/disabled
   return
end
C = this.EditedBlock;

% Get normalized open-loop and absolute value of compensator gain
CurrentGain = getZPKGain(C,'mag');
CLPoles = fastrloc(this.OpenLoopData,CurrentGain);

% If new closed-loop poles lie beyond data extent, extend asymptotes
% to include new gain value. Otherwise, include current gain value 
% to make sure red squares lie on the locus
% RE: Do not update this.LocusGains/Roots to avoid
%     * introducing persistent large gains in first case
%     * uncontrolled growth in second case
Gains = this.LocusGains;
Roots = this.LocusRoots;
[NewGain,RefRoot] = extendlocus(Gains,Roots,CurrentGain);
if ~isempty(NewGain)
   % Extend locus
   NewRoot = matchlsq(RefRoot,fastrloc(this.OpenLoopData,NewGain));
   Roots = [NewRoot,Roots];
   [Gains,is] = sort([NewGain,Gains]);
   Roots = Roots(:,is);
elseif ~isempty(Gains) && ~any(Gains==CurrentGain)
   % Insert current gain in locus data 
   idx = find(Gains>CurrentGain);
   Roots = [Roots(:,1:idx(1)-1) , ...
           matchlsq(Roots(:,idx(1)-1),CLPoles) , Roots(:,idx(1):end)];
end

% Update locus plot
HG = this.HG;
for ct=1:size(Roots,1)
    set(HG.Locus(ct),'Xdata',real(Roots(ct,:)),...
        'Ydata',imag(Roots(ct,:)),'Zdata',this.zlevel('curve',[1 size(Roots,2)]))
end

% Update closed-loop pole location
this.ClosedPoles = CLPoles;   
for ct=1:length(CLPoles)
    set(HG.ClosedLoop(ct),'Xdata',real(CLPoles(ct)),'Ydata',imag(CLPoles(ct)));
end

% Multimodel update
if this.isMultiModelVisible
    CLPolesa = [];
    for ct = 1:length(this.UncertainData)
        CLPolesa = [CLPolesa;fastrloc(this.UncertainData(ct).OpenLoopData,CurrentGain)];
    end
    this.UncertainBounds.setData(CLPolesa)
end

%---Update axis limits
updateview(this)

   
