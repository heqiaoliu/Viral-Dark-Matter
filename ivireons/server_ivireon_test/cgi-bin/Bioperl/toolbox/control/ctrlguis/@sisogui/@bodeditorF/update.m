function update(this,varargin)
%UPDATE  Updates Editor and regenerates plot.

%   Author(s): P. Gahinet 
%   Revised:   N.Hickey
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.37.4.8 $  $Date: 2010/05/10 16:59:12 $

if strcmp(this.EditMode,'off') || strcmp(this.Visible,'off')
   % Editor is inactive
   return
end
ClosedLoopOn = strcmp(this.ClosedLoopVisible,'on');

% Model data
LoopData = this.LoopData;
C = this.EditedBlock;
Ts = LoopData.Ts;  % sample time

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Update Frequency Response Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get normalized model for edited feedforward compensator (for gain mag=1)
NormC = zpk(C,'norm');
GainC = getZPKGain(C,'mag');

% Check that loop can be closed (watch for singular loops)
hw = ctrlMsgUtils.SuspendWarnings; 
if ClosedLoopOn
   % Get closed-loop transfer function of interest
   clview = this.ClosedLoopView;
   [Tcl,TclAll] = getclosedloop(LoopData,clview.Output,clview.Input);
   ClosedLoopDef = (isfinite(Tcl));
end

% Compute Bode plot data for F (units = rad/sec,abs,degrees)
[this.Magnitude,this.Phase,this.Frequency,FocusC,SoftFocusC] = bode(this,NormC);

% Get frequency grid(s)
if ClosedLoopOn && ClosedLoopDef
   % Compute closed-loop Bode response for adequate freq. grid
   ResponseID = clview.Description;
   [this.ClosedLoopMagnitude,this.ClosedLoopPhase,this.ClosedLoopFrequency,...
         FocusCL,SoftFocusCL] = bode(this,Tcl);
   FreqFocus = mrgfocus({FocusC;FocusCL},[SoftFocusC;SoftFocusCL]);
   MagDataCL = unitconv(this.ClosedLoopMagnitude,'abs',this.Axes.YUnits{1});
else
   ResponseID = '';
   this.ClosedLoopFrequency = NaN;
   this.ClosedLoopMagnitude = NaN;
   this.ClosedLoopPhase = NaN;
   FreqFocus = FocusC;
   MagDataCL = NaN;
end
delete(hw)

% Conversion factors
FreqConvert = unitconv(1,'rad/sec',this.Axes.XUnits);
PhConvert = unitconv(1,'deg',this.Axes.YUnits{2});
MagDataC = unitconv(GainC * this.Magnitude,'abs',this.Axes.YUnits{1});
if Ts
   NyqFreq = FreqConvert * pi/Ts;
else 
   NyqFreq = NaN;
end

% Resolve undetermined focus (quasi-integrator)
if isempty(FreqFocus)
   if Ts
      FreqFocus = NyqFreq * [0.05,1];
   else
      FreqFocus = [0.1,1];
   end
end

% Set preferred frequency range
this.FreqFocus = FreqFocus;

%%%% Multi-Model
if this.isMultiModelVisible
    if isa(TclAll,'ltidata.frddata');
        uw=[];
    else
        uw = this.MultiModelFrequency;
        if Ts
            uw = uw(uw<=pi/Ts);
        end
    end
    
    for ct = 1:length(TclAll)
        [UMagnitude(:,ct),UPhase(:,ct),uw] = bode(this,TclAll(ct),uw);
    end
    this.UncertainBounds.setData(UMagnitude,UPhase,uw(:))
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
XFocus = getfocus(this);  % rounded focus

% Clear HG objects managed by Bode editor
clear(this)

% Need to get context menus after the hg objects are cleared to
% account for the case when update is called while in zoom mode
UIC = get(PlotAxes(1),'uicontextmenu'); % axis ctx menu

% Plot the closed-loop Bode response
HG.BodePlot = [];
if ClosedLoopOn
   FreqData = FreqConvert * this.ClosedLoopFrequency;
   PhaseDataCL = PhConvert * this.ClosedLoopPhase;
   Zdata = this.zlevel('curve',[length(FreqData) 1]);
   HG.BodePlot(1,2) = line(FreqData,MagDataCL,Zdata,...
      'Parent',PlotAxes(1),'Visible',this.MagVisible, ...
      'XlimInclude','off',...
      'YlimInclude','off',...
      'Color',Style.Color.ClosedLoop,...
      'UIContextMenu',UIC,...
      'Tag',ResponseID,...
      'ButtonDownFcn',{@LocalRedirectBD this},...
      'HelpTopicKey','cloopmagnitudeplot');  
   HG.BodePlot(2,2) = line(FreqData,PhaseDataCL,Zdata,...
      'Parent',PlotAxes(2),'Visible',this.PhaseVisible, ...
      'XlimInclude','off',...
      'YlimInclude','off',...
      'Color',Style.Color.ClosedLoop,...
      'HelpTopicKey','cloopphaseplot',...
      'Tag',ResponseID,...
      'ButtonDownFcn',{@LocalRedirectBD this},...
      'UIContextMenu',UIC); 
   
   % Update portion of Bode plot to be included in limit picking
   % REVISIT: Simply set BodePlot's XlimIncludeData property when available
   InFocusCL = find(this.ClosedLoopFrequency >= XFocus(1) & ...
      this.ClosedLoopFrequency <= XFocus(2));
   set(HG.BodeShadow(1,2),'XData',FreqData(InFocusCL),...
      'YData',MagDataCL(InFocusCL),'ZData',zeros(size(InFocusCL)))
   set(HG.BodeShadow(2,2),'XData',FreqData(InFocusCL),...
      'YData',PhaseDataCL(InFocusCL),'ZData',zeros(size(InFocusCL)))
end

% Plot the Bode response of F
FreqData = FreqConvert * this.Frequency;
PhaseDataC = PhConvert * this.Phase;
Zdata = this.zlevel('curve',[length(FreqData) 1]);
HG.BodePlot(1,1) = line(FreqData,MagDataC,Zdata,...
   'Parent',PlotAxes(1),'Visible',this.MagVisible, ...
   'XlimInclude','off',...
   'YlimInclude','off',...
   'Color',Style.Color.PreFilter,...
   'UIContextMenu',UIC,...
   'HelpTopicKey','filtermagnitudeplot',...
   'Tag',sprintf('%s magnitude plot',C.Name),...
   'ButtonDownFcn',{@LocalMoveGain this 'init'});  
HG.BodePlot(2,1) = line(FreqData,PhaseDataC,Zdata,...
   'Parent',PlotAxes(2),'Visible',this.PhaseVisible, ...
   'XlimInclude','off',...
   'YlimInclude','off',...
   'Color',Style.Color.PreFilter,...
   'HelpTopicKey','filterphaseplot',...
   'Tag',sprintf('%s phase plot',C.Name),...
   'ButtonDownFcn',{@LocalRedirectBD this},...
   'UIContextMenu',UIC); 

% Update portion of Bode plot to be included in limit picking
% REVISIT: Simply set BodePlot's XlimIncludeData property when available
InFocusC = find(this.Frequency >= XFocus(1) & this.Frequency <= XFocus(2));
set(HG.BodeShadow(1,1),...
   'XData',FreqData(InFocusC),'YData',MagDataC(InFocusC),'ZData',zeros(size(InFocusC)))
set(HG.BodeShadow(2,1),...
   'XData',FreqData(InFocusC),'YData',PhaseDataC(InFocusC),'ZData',zeros(size(InFocusC)))

% Update HG database
this.HG = HG;

% Adjust X position of Nyquist lines
this.setnyqline(NyqFreq)

% Plot the compensator poles and zeros
plotcomp(this)

% Set Y coordinates of poles/zeros to attach them to Bode curves
this.interpy(MagDataC,PhaseDataC);

% Update axis limits
% RE: Includes line handle restacking for proper layering
updateview(this)


%-------------------------Callback Functions-------------------------

%%%%%%%%%%%%%%%%%%%%%
%%% LocalMoveGain %%%
%%%%%%%%%%%%%%%%%%%%%
function LocalMoveGain(hSrc,event,Editor,action)
% Callback for button down on closed-loop poles
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
      setptr(SISOfig,'closedhand')
      % Take over window mouse events
      WBMU = get(SISOfig,{'WindowButtonMotionFcn','WindowButtonUpFcn'});
      set(SISOfig,'WindowButtonMotionFcn',{@LocalMoveGain Editor 'acquire'},...
         'WindowButtonUpFcn',{@LocalMoveGain Editor 'finish'});
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
   set(SISOfig,{'WindowButtonMotionFcn','WindowButtonUpFcn'},WBMU,'Pointer','arrow')
   % Clean up and update
   Editor.trackgain('finish');
   % Reset warnings
   warning(sw); lastwarn(lw, lwid);
end


%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalRedirectBD %%%
%%%%%%%%%%%%%%%%%%%%%%%
function LocalRedirectBD(hSrc,event,Editor)
% REVISIT: Delete when events can be blocked at axes level
if ~strcmp(Editor.EditMode,'idle')
   % Redirect to editor axes
   Editor.mouseevent('bd',get(hSrc,'parent'));
end

