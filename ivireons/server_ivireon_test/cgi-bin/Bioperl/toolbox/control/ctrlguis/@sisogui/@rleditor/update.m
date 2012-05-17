function update(this,varargin)
%UPDATE  Updates Root Locus this and regenerates plot.

%   Authors: P. Gahinet and K. Gondoly
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.45.4.9 $  $Date: 2010/05/10 16:59:26 $

if ~this.Enabled || strcmp(this.EditMode,'off') || strcmp(this.Visible,'off') 
    % this is inactive
    return
end
LoopData = this.LoopData;
C = this.EditedBlock;
idxL = this.EditedLoop;

%%%%%%%%%%%%%%%%%%%%
% Update Locus Data
%%%%%%%%%%%%%%%%%%%%

% Get normalized open-loop and loop gain
% RE: zpk gain of C replaced by its sign in normalized open-loop
NormOpenLoop = getOpenLoop(LoopData.L(idxL),C);
this.SingularLoop = (~isfinite(NormOpenLoop));
if this.SingularLoop
   % Open loop is not defined, e.g., when minor loop cannot be closed in config 4
   clear(this),  return
end
GainMag = getZPKGain(C,'mag');

% Use pade to approximate delays compute delays
NormOpenLoop = this.utApproxDelay(NormOpenLoop);

% Compute root locus for normalized open-loop model and current closed-loop poles 
sw = warning('off','Control:transformation:StateSpaceScaling'); [lw,lwid] = lastwarn;
[Roots,Gains,RLInfo] = rlocus(NormOpenLoop);
warning(sw); lastwarn(lw,lwid);
this.OpenLoopData = RLInfo;
CLpoles = fastrloc(RLInfo,GainMag);

% Make sure the locus extends beyond the current CL poles, and that 
% the locus goes through the red squares
[NewGain,RefRoot] = extendlocus(Gains,Roots,GainMag);
if ~isempty(NewGain)
   % Extend locus
   NewRoot = matchlsq(RefRoot,fastrloc(RLInfo,NewGain));
   Roots = [NewRoot,Roots];
   [Gains,is] = sort([NewGain,Gains]);
   Roots = Roots(:,is);
elseif ~isempty(Gains) && ~any(Gains==GainMag)
   % Insert current gain in locus data 
   idx = find(Gains>GainMag);
   Gains = [Gains(:,1:idx(1)-1) , GainMag , Gains(:,idx(1):end)];
   Roots = [Roots(:,1:idx(1)-1) , ...
         matchlsq(Roots(:,idx(1)-1),CLpoles) , Roots(:,idx(1):end)];
end

% Update locus data 
this.LocusRoots = Roots;
this.LocusGains = Gains;
this.ClosedPoles = CLpoles;  % triggers update of optimal X/Y lims

% Compute the plant dynamics (fixed poles and zeros)
% RE: Derive fixed dynamics from open-loop dynamics computed by RLOCUS
% to ensure that the o and x's lie at the end of branches (see g297998)
[zC,pC] = getTunedPZ(LoopData.L(idxL));
if RLInfo.InverseFlag
   FixedZeros = rootdiff(RLInfo.Pole,zC);
   FixedPoles = rootdiff(RLInfo.Zero,pC);
else
   FixedZeros = rootdiff(RLInfo.Zero,zC);
   FixedPoles = rootdiff(RLInfo.Pole,pC);
end

%%%%%%%%%%%%%%%%%
if this.isMultiModelVisible
    CLPolesa = [];
    L = LoopData.L(idxL);
    this.UncertainData=struct('OpenLoopData',[]);
    for ct = 1:length(L.TunedLFT.IC)
        [~,~,RLInfoa] = rlocus(this.utApproxDelay(getOpenLoop(L,C,ct)));
        this.UncertainData(ct).OpenLoopData=RLInfoa;
        CLPolesa = [CLPolesa;fastrloc(RLInfoa,GainMag)];
    end
    this.UncertainBounds.setData(CLPolesa)
end



%%%%%%%%%%%%%%%%%%%%
% Render Locus Data
%%%%%%%%%%%%%%%%%%%%
PlotAxes = getaxes(this.Axes);
HG = this.HG;
Style = this.LineStyle;

% Clear existing plot 
clear(this);

% Need to get context menus after the hg objects are cleared to
% account for the case when update is called while in zoom mode
UIC = get(PlotAxes,'uicontextmenu'); % axis ctx menu

% Plot the fixed poles and zeros (Z level = 2)
nz = length(FixedZeros);
np = length(FixedPoles);
HG.System = zeros(nz+np,1);
Zlevel = this.zlevel('system');
for ct=1:nz
   HG.System(ct) = line(real(FixedZeros(ct)),imag(FixedZeros(ct)),Zlevel,...
      'XlimInclude','off','YlimInclude','off',...
      'LineStyle','none','Marker','o','MarkerSize',5,'Color',Style.Color.System,...
      'Parent',PlotAxes,'UIContextMenu',UIC,...
      'HitTest','off',...
      'HelpTopicKey','sisosystempolezero');
end % for ct
for ct=1:np,
   HG.System(nz+ct) = line(real(FixedPoles(ct)),imag(FixedPoles(ct)),Zlevel,...
      'XlimInclude','off','YlimInclude','off',...
      'LineStyle','none','Marker','x','MarkerSize',6,'Color',Style.Color.System,...
      'Parent',PlotAxes,'UIContextMenu',UIC,...
      'HitTest','off',...
      'HelpTopicKey','sisosystempolezero');
end % for ct

%---Plot the root locus
HG.Locus = zeros(0,1);
HG.ClosedLoop = zeros(0,1); % needed because vector shrinks -> stale handles
if ~isempty(Gains)
   [Nline,Nroot] = size(Roots);
   for ct=Nline:-1:1
      HG.Locus(ct,1) = line(real(Roots(ct,:)),imag(Roots(ct,:)),...
         this.zlevel('curve',[1 Nroot]),...
         'XlimInclude','off',...
         'YlimInclude','off',...
         'Parent',PlotAxes, ...
         'UIContextMenu',UIC,...
         'ButtonDownFcn',@(x,y) LocalSelectGain(this,x),...
         'HelpTopicKey','sisorootlocusplot',...
         'Color',Style.Color.Response); 
   end
   
   %---Plot the movable closed-loop poles
   Zlevel = this.zlevel('clpole');
   for ct=length(CLpoles):-1:1,
      HG.ClosedLoop(ct,1) = ...
         line(real(CLpoles(ct)),imag(CLpoles(ct)),Zlevel,...
         'Parent',PlotAxes, ...
         'LineStyle','none',...
         'Marker',Style.Marker.ClosedLoop,...
         'MarkerSize',5,...
         'MarkerFaceColor',Style.Color.ClosedLoop, ...
         'MarkerEdgeColor',Style.Color.ClosedLoop,...
         'HelpTopicKey','closedlooppoles',...
         'ButtonDownFcn',@(x,y) LocalMoveGain(this,'init',x));  
   end 
   % Always include origin to prevent o(eps) x-range
   set(HG.Origin,'XData',[0 0 0 0],'YData',[0 0 0 0])
else
   % Draw rectangle around origin to avoid [0 1],[0 1] limits
   set(HG.Origin,'XData',[-1 -1 1 1],'YData',[-1 1 -1 1])
end

% Update HG database
this.HG = HG;

% Update root locus extent as seen by limit picker
% REVISIT: Simply update XlimIncludeData
[XFocus,YFocus] = rloclims(this.LocusRoots);
re = real(Roots(:));
im = imag(Roots(:));
InFocus = find(re>=XFocus(1) & re<=XFocus(2) & im>=YFocus(1) & im<=YFocus(2));
set(HG.LocusShadow,...
   'XData',re(InFocus),'YData',im(InFocus),'ZData',zeros(size(InFocus)))

% Plot the compensator poles and zeros
plotcomp(this);

% Update axis limits
updateview(this)


%-------------------------Callback Functions-------------------------

%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalSelectGain %%%
%%%%%%%%%%%%%%%%%%%%%%%
function LocalSelectGain(this,hLine)
% Update gain by clicking on the locus
if ~strcmp(this.EditMode,'idle') || ~this.GainTunable
    % Redirect to editor axes
    this.mouseevent('bd',get(hLine,'parent'));
elseif strcmp(get(gcbf,'SelectionType'),'normal')
    selectgain(this);
end


%%%%%%%%%%%%%%%%%%%%%
%%% LocalMoveGain %%%
%%%%%%%%%%%%%%%%%%%%%
function LocalMoveGain(this,action,hSrc)
% Callback for button down on closed-loop poles
% REVISIT: merge with trackgain when directed callback are available
persistent SISOfig WBMU sw lw lwid

switch action
case 'init'
    % Initialize move
    SISOfig = gcbf;
    if ~strcmp(this.EditMode,'idle') || ~this.GainTunable
        % Redirect to editor axes
        this.mouseevent('bd',get(hSrc,'parent'));
    elseif strcmp(get(SISOfig,'SelectionType'),'normal')
        % Change pointer
        setptr(SISOfig,'closedhand')
        % Take over window mouse events
        WBMU = get(SISOfig,{'WindowButtonMotionFcn','WindowButtonUpFcn'});
        set(SISOfig,'WindowButtonMotionFcn',@(x,y) LocalMoveGain(this,'acquire',x),...
            'WindowButtonUpFcn',@(x,y) LocalMoveGain(this,'finish',x));
        % Disable all warnings
        sw = warning('off'); [lw, lwid] = lastwarn;
        % Initialize tracking algorithm and notify peers
        this.trackgain('init');
    end
case 'acquire'
    % Track mouse location (move)
    this.trackgain('acquire');
case 'finish'
    % Restore initial conditions
    set(SISOfig,{'WindowButtonMotionFcn','WindowButtonUpFcn'},WBMU,'Pointer','arrow')
    % Clean up and update
    this.trackgain('finish');
    % Reset warnings
    warning(sw); lastwarn(lw, lwid);
end
