function update(Editor,varargin)
%UPDATE  Updates Nichols Editor and Regenerates Plot.

%   Author(s): Bora Eryilmaz
%   Revised:
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.32.4.11.2.1 $ $Date: 2010/07/12 15:20:11 $



% Return if Editor if inactive.
if strcmp(Editor.EditMode, 'off') || strcmp(Editor.Visible, 'off')
  return
end

% Model data
LoopData = Editor.LoopData;
C = Editor.EditedBlock;
idxL = Editor.EditedLoop;
Ts = LoopData.Ts;  % sample time

% ----------------------------------------------------------------------------%
% Update Frequency Response Data
% ----------------------------------------------------------------------------%
% Get normalized open-loop (ZPK gain replaced by its sign)
L = LoopData.L(idxL);

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
    [FRDMagnitude,FRDPhase,FRDFrequency,FreqFocus] = nichols(Editor,TunedLFT);
    
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
            LocalUpdateData(Editor,FRDFrequency,FRDMagnitude,FRDPhase,wpz);
    end
    
    % Compute frequency response of TunedFactors
    [TFMagnitude,TFPhase,TFFrequency] = nichols(Editor,TFactors,FRDFrequency);
    
    % Use the intersection of frequency computed (0 frequency with infs or
    % NaNs removed)
    [~,ITF,IFRD] = intersect(TFFrequency,FRDFrequency);
    
    
    % Form product TunedFactors*TunedLFT
    Editor.Magnitude = TFMagnitude(ITF).*FRDMagnitude(IFRD);
    Editor.Phase = TFPhase(ITF)+FRDPhase(IFRD);
    Editor.Frequency = FRDFrequency(IFRD);
else
    NormOpenLoop = getOpenLoop(L,C);
    Editor.SingularLoop = (~isfinite(NormOpenLoop));
    if Editor.SingularLoop
        % Open loop is not defined, e.g. when minor loop cannot be closed in config 4
        Editor.clear;  return
    end
    % Compute Nichols plot data (units = rad/sec,abs,degrees)
    [Editor.Magnitude,Editor.Phase,Editor.Frequency,FreqFocus] = ...
        nichols(Editor,NormOpenLoop);
end


GainMag = getZPKGain(C,'mag');

% Conversion factors
MagData = mag2db(GainMag * Editor.Magnitude);
PhaseData = unitconv(Editor.Phase, 'deg', Editor.Axes.XUnits);
if Ts
  NyqFreq = pi / Ts;
end

% Resolve unidentified focus (quasi-integrator) by looking
if isempty(FreqFocus)
   % for 0dB gain crossings to anchor focus
   idxc = find(MagData(1:end-1).*MagData(2:end)<=0);
   if ~isempty(idxc)
      FreqFocus = [Editor.Frequency(idxc(1))/10 , 10*Editor.Frequency(idxc(1)+1)];
   elseif Ts
      FreqFocus = NyqFreq * [0.05,1];
   else
      FreqFocus = [0.1,1];
   end
end

% Set preferred frequency range
Editor.FreqFocus = FreqFocus;


%%%% Multimodel support
if Editor.isMultiModelVisible
    if hasFRD(L);
        uw=[];
    else
        uw = Editor.MultiModelFrequency;
        if Ts
            uw = uw(uw<=pi/Ts);
        end
    end
    
    for ct = 1:length(L.TunedLFT.IC)
        [UMagnitude(:,ct),UPhase(:,ct),uw] = nichols(Editor,getOpenLoop(L,C,ct),uw);
    end
    Editor.UncertainBounds.setData(GainMag*UMagnitude,UPhase,uw(:))
    Editor.UncertainData = struct(...
        'Magnitude',UMagnitude,...
        'Phase', UPhase, ...
        'Frequency',uw(:));
end


% ----------------------------------------------------------------------------%
% Render Data
% ----------------------------------------------------------------------------%
HG = Editor.HG;
PlotAxes = getaxes(Editor.Axes); 
Style = Editor.LineStyle;

% Clear HG objects managed by Nichols editor
Editor.clear;

% Need to get context menus after the hg objects are cleared to
% account for the case when update is called while in zoom mode
UIC = get(PlotAxes, 'uicontextmenu');  % axis context menu

% Check if the system poles/zeros are to be shown
if strcmp(Editor.ShowSystemPZ, 'on')
  PZVis = Editor.Visible;
else
  PZVis = 'off';
end

% Find the fixed poles and zeros
[FixedZeros, FixedPoles] = getFixedPZ(LoopData.L(idxL));

% System zeros (discard conjugates of imaginary zeros)
FixedZeros = [FixedZeros(~imag(FixedZeros), :) ; ...
	      FixedZeros(imag(FixedZeros) > 0, :)];
FreqZ = damp(FixedZeros, Ts); % in rad/sec
MagPhaZ = [];

% Discard roots whose CT frequency exceeds pi/Ts
if Ts,
  idx = find(FreqZ <= NyqFreq);
  FixedZeros = FixedZeros(idx);
  FreqZ = FreqZ(idx);
end

% Line structure for zeros
Zlevel = Editor.zlevel('system');
for ct = length(FixedZeros):-1:1
   MagPhaZ(ct,1) = line(NaN, NaN, Zlevel, ...
      'Parent', PlotAxes, ...
      'XlimInclude','off',...
      'YlimInclude','off',...      
      'UserData', FreqZ(ct), ...
      'Visible', PZVis,...
      'LineStyle', 'none', ...
      'Marker', 'o', ...
      'MarkerSize', 5, ...
      'Color', Style.Color.System, ...
      'UIContextMenu', UIC, ...
      'HelpTopicKey', 'nicholssystemzero', ...
      'HitTest','off');
end

% Highlight imaginary zeros
imfz = find(imag(FixedZeros) > 0);
set(MagPhaZ(imfz, :), 'LineWidth', 2)

% System poles (discard conjugates of imaginary poles)
FixedPoles = [FixedPoles(~imag(FixedPoles), :) ; ...
	      FixedPoles(imag(FixedPoles) > 0, :)];
FreqP = damp(FixedPoles, Ts);  % in rad/sec
MagPhaP = [];

% Discard roots whose CT frequency exceeds pi/Ts
if Ts,
  idx = find(FreqP <= NyqFreq);
  FixedPoles = FixedPoles(idx);
  FreqP = FreqP(idx);
end

% Line structure for poles
for ct = length(FixedPoles):-1:1
   MagPhaP(ct,1) = line(NaN, NaN, Zlevel, ...
      'Parent', PlotAxes, ...
      'XlimInclude','off',...
      'YlimInclude','off',...      
      'UserData', FreqP(ct), ...
      'Visible', PZVis,...
      'LineStyle', 'none', ...
      'Marker', 'x', ...
      'MarkerSize', 6, ...
      'Color', Style.Color.System, ...
      'UIContextMenu', UIC, ...
      'HelpTopicKey', 'nicholssystempole', ...
      'HitTest','off');
end

% Highlight imaginary poles
imfp = find(imag(FixedPoles) > 0);
set(MagPhaP(imfp, :), 'LineWidth', 2);

% Handle summary
HG.System = [MagPhaZ ; MagPhaP];

% Plot the Nichols plot
Zdata = Editor.zlevel('curve', [length(PhaseData) 1]);
HG.NicholsPlot = line(PhaseData, MagData, Zdata, ...
   'Parent', PlotAxes, ...
   'XlimInclude','off',...
   'YlimInclude','off',...      
   'Color', Style.Color.Response, ...
   'UIContextMenu', UIC, ...
   'Tag', xlate('Open-loop Nichols plot.'), ...
   'HelpTopicKey', 'sisonicholsplot', ...
   'ButtonDownFcn', {@LocalMoveGain Editor 'init'});  

% Update portion of Nichols plot to be included in limit picking
% REVISIT: Simply set NicholsPlot's X/YlimIncludeData properties when available
InFocus = find(Editor.Frequency >= FreqFocus(1) & Editor.Frequency <= FreqFocus(2));
set(HG.NicholsShadow,...
   'XData',PhaseData(InFocus),'YData',MagData(InFocus),'ZData',zeros(size(InFocus)))

% Update HG database
Editor.HG = HG;

% Turn warning off and store last warning g219858
WarnStatus = warning('off');
[LastMsg, LastID] = lastwarn;

% Set X/Y coordinates of poles/zeros of compensator/system on the Nichols plot.
plotcomp(Editor)
Editor.interpxy(MagData, PhaseData);

% Stability margins
showmargin(Editor)

% Turn warning back on and reset last warning
warning(WarnStatus);
lastwarn(LastMsg, LastID);


% Update axis limits
% RE: Includes line handle restacking for proper layering, margin display,...
updateview(Editor)


% ----------------------------------------------------------------------------%
% Callback Functions
% ----------------------------------------------------------------------------%

% ----------------------------------------------------------------------------%
% Function: LocalMoveGain
% Callback for button down on closed-loop poles
% ----------------------------------------------------------------------------%
function LocalMoveGain(hSrc, event, Editor, action)
% REVISIT: merge with trackgain when directed callback are available
persistent SISOfig WBMU sw lw lwid

switch action
case 'init'
   % Initialize move
   SISOfig = gcbf;
   if ~strcmp(Editor.EditMode,'idle') || ~Editor.GainTunable
      % Redirect to editor axes
      Editor.mouseevent('bd',get(hSrc,'parent'));
   elseif strcmp(get(SISOfig,'SelectionType'),'normal')
      % Change pointer
      setptr(SISOfig, 'closedhand')
      % Take over window mouse events
      WBMU = get(SISOfig, {'WindowButtonMotionFcn', 'WindowButtonUpFcn'});
      set(SISOfig,'WindowButtonMotionFcn',{@LocalMoveGain Editor 'acquire'}, ...
         'WindowButtonUpFcn', {@LocalMoveGain Editor 'finish'});
     % Disable all warnings
     sw = warning('off'); [lw, lwid] = lastwarn;
      % Initialize tracking algorithm and notify peers
      Editor.trackgain('init');
   end
   
case 'acquire'
   % Track mouse location (move)
   Editor.trackgain('acquire');
   
case 'finish'
   % Restore initial conditions
   set(SISOfig, {'WindowButtonMotionFcn', 'WindowButtonUpFcn'}, WBMU, ...
      'Pointer', 'arrow')
   % Clean up and update
   Editor.trackgain('finish');
   % Reset warnings
   warning(sw); lastwarn(lw, lwid);
end



%%%%%%%%%%%%%%%%%%%
% LocalUpdateData %
%%%%%%%%%%%%%%%%%%%
function [w,mag,phase] = LocalUpdateData(Editor,w,mag,phase,wpz)
% Updates mag and phase data by adding points for wpz
mag = [mag ; ...
      Editor.interpmag(w, mag, wpz)];
phase = [phase ; ...
      utInterp1(w, phase, wpz)];
[w, iu] = LocalUniqueWithinTol([w;wpz], 1e3*eps);

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

