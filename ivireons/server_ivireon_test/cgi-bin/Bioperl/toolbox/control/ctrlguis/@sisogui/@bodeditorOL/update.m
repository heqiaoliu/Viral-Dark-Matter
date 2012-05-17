function update(this,varargin)
%UPDATE  Updates Open-Loop Editor and regenerates plot.

%   Author(s): Karen D. Gondoly, P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.68.4.9.2.1 $  $Date: 2010/07/12 15:20:10 $
if strcmp(this.EditMode,'off') || strcmp(this.Visible,'off')
   % Editor is inactive
   return
end

% Model data
LoopData = this.LoopData;
C = this.EditedBlock;
idxL = this.EditedLoop;
Ts = LoopData.Ts;  % sample time

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Update Frequency Response Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get normalized open-loop (for compensator gain mag=1)
L = LoopData.L(idxL);

% Compute Bode response for adequate freq. grid (units = rad/sec,abs,degrees)
if hasFRD(L)
    % For FRD Data, the normalized open-loop is computed in multiple stages
    % for compensator poles and zeros to be displayed correctly. 
    % L = TunedFactors*TunedLFT
    % 1. Compute the TunedLFT (FRD)
    % 2. Compute the Normalized TunedFactors (ZPK)
    % 3. Interpolate TunedLFT using visual scale at pole/zero and resonance
    % 4. Compute FRD of ZPK and perform L = TunedFactors*TunedLFT
    
    % Note: The Open-Loop is defined as positive feedback because the loop is
    % defined by cutting a signal(i.e. all signs are lumped in the effective
    % plant). However because most users are used to designing with negative
    % feedback on such plots as root locus this function pulls out a negative
    % sign so that plots are presented as negative feedback.
    TunedLFT = -getTunedLFT(L);

    % Compute TunedLFT Response
    [FRDMagnitude,FRDPhase,FRDFrequency,FreqFocus,SoftFocus] = bode(this,TunedLFT);

    % Compute Contributions of TunedFactors Normalized by C(for compensator
    % gain mag=1)
    idx = find(C == L.TunedFactors);
    TFactors = getPrivateData(zpk(1));
    for ct = 1:length(L.TunedFactors)
        if ct == idx
            TFactors = TFactors * zpk(L.TunedFactors(ct),'normalized');
        else
            TFactors = TFactors * zpk(L.TunedFactors(ct));
        end
    end
    
    % Determine additional freq points to add to the response
    if ~(isempty(TFactors.z{1}) && isempty(TFactors.p{1}))
        [W0,Zeta] = damp([TFactors.z{1};TFactors.p{1}],TFactors.Ts);
        
        t = W0.^2 .* (1 - 2 * Zeta.^2);
        Wpeak = sqrt(t(t>0,:));
        wpz = [Wpeak;W0];
        wpz = wpz((wpz<=FRDFrequency(end)) & (wpz>=FRDFrequency(1)));
        
        [FRDFrequency,FRDMagnitude,FRDPhase] = ...
            LocalUpdateData(this,FRDFrequency,FRDMagnitude,FRDPhase,wpz);
    end
    % Compute frequency response of TunedFactors
    [TFMagnitude,TFPhase,TFFrequency] = bode(this,TFactors,FRDFrequency);
    
    % Use the intersection of frequency computed (0 frequency with infs or
    % NaNs removed)
    [~,ITF,IFRD] = intersect(TFFrequency,FRDFrequency);

    % Form product TunedFactors*TunedLFT
    this.Magnitude = TFMagnitude(ITF).*FRDMagnitude(IFRD);
    this.Phase = TFPhase(ITF)+FRDPhase(IFRD);
    this.Frequency = FRDFrequency(IFRD);
   
else
    NormOpenLoop = getOpenLoop(L,C);
    this.SingularLoop = (~isfinite(NormOpenLoop));
    if this.SingularLoop
        % Open loop is not defined, e.g., when minor loop cannot be closed in config 4
        clear(this);  return
    end
    [this.Magnitude,this.Phase,this.Frequency,FreqFocus,SoftFocus] = bode(this,NormOpenLoop);
end

GainMag = getZPKGain(C,'mag');

% Conversion factors
FreqConvert = unitconv(1,'rad/sec',this.Axes.XUnits);
MagData = unitconv(GainMag * this.Magnitude,'abs',this.Axes.YUnits{1});
PhaseData = unitconv(this.Phase,'deg',this.Axes.YUnits{2});
if Ts
   NyqFreq = FreqConvert * pi/Ts;
else 
   NyqFreq = NaN;
end

% Resolve undetermined focus (quasi-integrator)
if isempty(FreqFocus)
   % Look for 0dB gain crossings to anchor focus
   UnitGain = unitconv(1,'abs',this.Axes.YUnits{1});
   idxc = find((MagData(1:end-1)-UnitGain).*(MagData(2:end)-UnitGain)<=0);
   if ~isempty(idxc)
      idxc = idxc(round(end/2));
      FreqFocus = [this.Frequency(idxc)/10 , 10*this.Frequency(idxc+1)];
   elseif Ts
      FreqFocus = NyqFreq * [0.05,1];
   else
      FreqFocus = [0.1,1];
   end
end

% Set preferred frequency range
this.FreqFocus = FreqFocus;

%%%% Multi-Model
if this.isMultiModelVisible
    if hasFRD(L);
        uw=[];
    else
        uw = this.MultiModelFrequency;
        if Ts
           uw = uw(uw<=pi/Ts); 
        end
    end
    for ct = 1:length(L.TunedLFT.IC)
        [UMagnitude(:,ct),UPhase(:,ct),uw] = bode(this,getOpenLoop(L,C,ct),uw);
    end
    this.UncertainBounds.setData(GainMag*UMagnitude,UPhase,uw(:))
    this.UncertainData = struct(...
        'Magnitude',UMagnitude,...
        'Phase', UPhase, ...
        'Frequency',uw(:));
end
    
%%%%%%%


%%%%%%%%%%%%%
% Render Data
%%%%%%%%%%%%%
HG = this.HG;
PlotAxes = getaxes(this.Axes);
Style = this.LineStyle;

% Clear HG objects managed by Bode editor
clear(this)

% Need to get context menus after the hg objects are cleared to
% account for the case when update is called while in zoom mode
UIC = get(PlotAxes(1),'uicontextmenu'); % axis ctx menu

% Plot the fixed poles and zeros
[FixedZeros, FixedPoles] = getFixedPZ(L);
if strcmp(this.ShowSystemPZ,'on')
   MagPZVis = this.MagVisible;
   PhasePZVis = this.PhaseVisible;
else
   MagPZVis = 'off';
   PhasePZVis = 'off';
end
Zlevel = this.zlevel('system');

% System zeros 
FixedZeros = [FixedZeros(~imag(FixedZeros),:) ; FixedZeros(imag(FixedZeros)>0,:)];
FreqZ = FreqConvert * damp(FixedZeros,Ts);
MagZ = [];  PhaseZ = [];
if Ts,
   % Discard roots whose CT frequency exceeds pi/Ts
   idx = find(FreqZ<=NyqFreq);
   FixedZeros = FixedZeros(idx);
   FreqZ = FreqZ(idx);
end
ZProps = {...
      'XlimInclude','off','YlimInclude','off',...
      'LineStyle','none','Marker','o','MarkerSize',5,...
      'Color',Style.Color.System,...
      'UIContextMenu',UIC,...
      'HitTest','off',...
      'HelpTopicKey','sisosystempolezero'}; 
for ct=length(FixedZeros):-1:1
   MagZ(ct,1) = line(FreqZ(ct),NaN,Zlevel,...
      'Parent',PlotAxes(1),'UserData',FixedZeros(ct),'Visible',MagPZVis,ZProps{:});
   PhaseZ(ct,1) = line(FreqZ(ct),NaN,Zlevel,...
      'Parent',PlotAxes(2),'UserData',FixedZeros(ct),'Visible',PhasePZVis,ZProps{:});
end
imfz = find(imag(FixedZeros)>0);
set([MagZ(imfz,:);PhaseZ(imfz,:)],'LineWidth',2)

% System poles
FixedPoles = [FixedPoles(~imag(FixedPoles),:) ; FixedPoles(imag(FixedPoles)>0,:)];
FreqP = FreqConvert * damp(FixedPoles,Ts);
MagP = [];  PhaseP = [];
if Ts,
   % Discard roots whose CT frequency exceeds pi/Ts
   idx = find(FreqP<=NyqFreq);
   FixedPoles = FixedPoles(idx);
   FreqP = FreqP(idx);
end
PProps = {...
      'XlimInclude','off','YlimInclude','off',...
      'LineStyle','none','Marker','x','MarkerSize',6,...
      'Color',Style.Color.System,...
      'UIContextMenu',UIC,...
      'HitTest','off',...
      'HelpTopicKey','sisosystempolezero'};
for ct=length(FixedPoles):-1:1
   MagP(ct,1) = line(FreqP(ct),NaN,Zlevel,...
      'Parent',PlotAxes(1),'UserData',FixedPoles(ct),'Visible',MagPZVis,PProps{:});
   PhaseP(ct,1) = line(FreqP(ct),NaN,Zlevel,...
      'Parent',PlotAxes(2),'UserData',FixedPoles(ct),'Visible',PhasePZVis,PProps{:});
end
imfp = find(imag(FixedPoles)>0);
set([MagP(imfp,:);PhaseP(imfp,:)],'LineWidth',2)

% Handle summary
HG.System.Magnitude = [MagZ;MagP];
HG.System.Phase = [PhaseZ;PhaseP];

% Plot the Bode diagrams
FreqData = FreqConvert * this.Frequency;
Zdata = this.zlevel('curve',[length(FreqData) 1]);
HG.BodePlot(1,1) = line(FreqData,MagData,Zdata,...
   'Parent',PlotAxes(1), ...
   'XlimInclude','off',...
   'YlimInclude','off',...
   'Visible',this.MagVisible, ...
   'Color',Style.Color.Response,...
   'UIContextMenu',UIC,...
   'HelpTopicKey','sisobode',...
   'Tag',xlate('Open-loop magnitude plot.'),...
   'ButtonDownFcn',{@LocalMoveGain this 'init'});  
HG.BodePlot(2,1) = line(FreqData,PhaseData,Zdata,...
   'Parent',PlotAxes(2), ...
   'XlimInclude','off',...
   'YlimInclude','off',...
   'Visible',this.PhaseVisible, ...
   'Color',Style.Color.Response,...
   'HelpTopicKey','sisobode',...
   'Tag',xlate('Open-loop phase plot.'),...
   'UIContextMenu',UIC); 

% Update portion of Bode plot to be included in limit picking
% REVISIT: Simply set BodePlot's XlimIncludeData property when available
XFocus = getfocus(this);
InFocus = find(this.Frequency >= XFocus(1) & this.Frequency <= XFocus(2));
set(HG.BodeShadow(1),...
   'XData',FreqData(InFocus),'YData',MagData(InFocus),'ZData',zeros(size(InFocus)))
set(HG.BodeShadow(2),...
   'XData',FreqData(InFocus),'YData',PhaseData(InFocus),'ZData',zeros(size(InFocus)))

% Update HG database
this.HG = HG;

% Adjust X position of Nyquist lines
this.setnyqline(NyqFreq)

% Plot the compensator poles and zeros, and set Y coordinates of 
% poles/zeros to attach them to Bode curves
plotcomp(this)
this.interpy(MagData,PhaseData);

% Stability margins
showmargin(this)

% Update axis limits
% RE: Includes line handle restacking for proper layering
updateview(this)


%-------------------------Callback Functions-------------------------

%%%%%%%%%%%%%%%%%%%%%
%%% LocalMoveGain %%%
%%%%%%%%%%%%%%%%%%%%%
function LocalMoveGain(hSrc,event,this,action)
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
      set(SISOfig,'WindowButtonMotionFcn',{@LocalMoveGain this 'acquire'},...
         'WindowButtonUpFcn',{@LocalMoveGain this 'finish'});
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


%%%%%%%%%%%%%%%%%%%
% LocalUpdateData %
%%%%%%%%%%%%%%%%%%%
function [w,mag,phase] = LocalUpdateData(Editor,w,mag,phase,wpz)
% Updates mag and phase data by adding points for wpz
mag = [mag ; interpmag(Editor,w,mag,wpz)];
phase = [phase ; interpphase(Editor,w,phase,wpz)];
[w,iu] = LocalUniqueWithinTol([w;wpz],1e3*eps);  % sort + unique
mag = mag(iu);
phase = phase(iu);


%%%%%%%%%%%%%%%%%%%%%%%%
% LocalUniqueWithinTol %
%%%%%%%%%%%%%%%%%%%%%%%%
function [w,iu] = LocalUniqueWithinTol(w,rtol)
% Eliminates duplicates within RTOL (relative tolerance)
% Helps prevent reintroducing duplicates during unit conversions

% Sort W
[w,iu] = sort(w);

% Eliminate duplicates
lw = length(w);
dupes = find(w(2:lw)-w(1:lw-1)<=rtol*w(2:lw));
w(dupes,:) = [];
iu(dupes,:) = [];

function Phasei = interpphase(Editor,W,Phase,Wi)
%INTERPPhase  Interpolates phase data in the visual units.
if strcmp(Editor.Axes.XScale,'log')
   W = log2(W);
   nz = (Wi>0);
   Wi(nz) = log2(Wi(nz));
   Wi(~nz) = -Inf;
end

Phasei = utInterp1(W,Phase,Wi);

