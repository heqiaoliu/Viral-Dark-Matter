function plotcomp(Editor)
% Renders compensator poles and zeros.

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2008 The MathWorks, Inc. 
%  $Revision: 1.18.4.3 $ $Date: 2008/06/13 15:14:05 $

L = Editor.LoopData.L(Editor.EditedLoop);

% Get pole/zero group information
TunedFactors = L.TunedFactors;
PZGroups = [];
for ct = 1:length(TunedFactors)
    PZGroups = [PZGroups; TunedFactors(ct).PZGroup];
end
Nf = length(PZGroups);  % number of groups after update

% Initialize list of PZ group renderers (@PZVIEW objects)
Nc = length(Editor.EditedPZ);  % current number of PZVIEW objects
% Delete extra groups
if Nc > Nf,
  delete(Editor.EditedPZ(Nf+1:Nc));
  Editor.EditedPZ = Editor.EditedPZ(1:Nf,:);
end
% Add new groups
for ct = 1:Nf-Nc, 
  Editor.EditedPZ = [Editor.EditedPZ ; sisogui.pzview];
end

% Render each pole/zero group
Ts = Editor.LoopData.Ts;
PlotAxes = getaxes(Editor.Axes);
Focus = Editor.FreqFocus;
HG = Editor.HG;  
HG.Compensator = zeros(0,1);
for ct = 1:Nf
  h = Editor.EditedPZ(ct);  % PZVIEW object for Nichols plot
  h.GroupData = PZGroups(ct);
  hPZ = LocalRender(h, PlotAxes, Editor, Ts, Focus);
  HG.Compensator = [HG.Compensator ; hPZ];
end

% Update database
Editor.HG = HG;


% ----------------------------------------------------------------------------%
% Local Functions
% ----------------------------------------------------------------------------%

% ----------------------------------------------------------------------------%
% Function: LocalRender
% Renders pole/zero group
% ----------------------------------------------------------------------------%
function [hPZ] = LocalRender(hView, PlotAxes, Editor, Ts, Focus)
% HVIEW = @PZVIEW object rendering a given pole/zero group

% RE: Leave X and Y coordinate undefined (resolved by one-shot interpxy)
Style = Editor.LineStyle;
PZGroup = hView.GroupData;  % Rendered PZGROUP
Zlevel = Editor.zlevel('compensator');

% Render zeros
Zeros = PZGroup.Zero;   % zero values
if isempty(Zeros)
   hZ = zeros(0,1);
else   
   if Ts
      FreqZ = min(damp(Zeros(1), Ts), pi/Ts);
   else
      FreqZ = damp(Zeros(1)); % in rad/sec
   end
   hZ = line(NaN, NaN, Zlevel, ...
      'Parent', PlotAxes, ...
      'Visible', Editor.Visible, ...
      'UserData', FreqZ, ...
      'LineStyle', 'none', ...
      'Color', Style.Color.Compensator, ...
      'HelpTopicKey', 'nicholscompensatorzero', ...
      'Marker', 'o', 'MarkerSize', 6, ...
      'ButtonDownFcn', {@LocalMovePZ Editor 'init'});
   setappdata(hZ, 'PZVIEW', hView);
   % Exclude roots far out focus region from limit picking
   if ~isempty(Focus) && (FreqZ<1e-2*Focus(1) || FreqZ>1e2*Focus(2))
      set(hZ,'XlimInclude','off','YlimInclude','off')
   end
   if any(strcmp(PZGroup.Type, {'Complex', 'Notch'}))
      set(hZ,'LineWidth', 2)
   end
end
hView.Zero = hZ(ones(1, length(Zeros)), 1);


% Render poles
Poles = PZGroup.Pole;   % zero values
if isempty(Poles)
   hP = zeros(0,1);
else
   if Ts
      FreqP = min(damp(Poles(1), Ts), pi/Ts);
   else
      FreqP = damp(Poles(1)); % in rad/sec
   end
   hP = line(NaN, NaN, Zlevel, ...
      'Parent', PlotAxes, ...
      'Visible', Editor.Visible, ...
      'UserData', FreqP, ...
      'LineStyle', 'none', ...
      'Color', Style.Color.Compensator, ...
      'HelpTopicKey', 'nicholscompensatorpole', ...
      'Marker', 'x', 'MarkerSize', 8, ...
      'ButtonDownFcn', {@LocalMovePZ Editor 'init'}); 
   setappdata(hP, 'PZVIEW', hView);
   % Exclude roots far out focus region from limit picking
   % (e.g., p=2e-17 will yield huge X range)
   if ~isempty(Focus) && (FreqP<1e-2*Focus(1) || FreqP>1e2*Focus(2))
      set(hP,'XlimInclude','off','YlimInclude','off')
   end
   
   if any(strcmp(PZGroup.Type, {'Complex', 'Notch'}))
      set(hP, 'LineWidth', 2)
   end
end
hView.Pole = hP(ones(1,length(Poles)), 1);

% Overall handles (no repetition)
hPZ = [hZ(:,1) ; hP(:,1)];

% Add notch width markers
if strcmp(PZGroup.Type, 'Notch')
  FreqM = notchwidth(PZGroup, Ts);  % Marker frequencies
  nwm(1,1) = line(NaN, NaN, Zlevel, 'Parent', PlotAxes, 'UserData', FreqM(1));
  nwm(2,1) = line(NaN, NaN, Zlevel, 'Parent', PlotAxes, 'UserData', FreqM(2));
  
  set(nwm, 'Visible', Editor.Visible, ...
	   'LineStyle', 'none', ...
	   'Marker', 'diamond', ...
	   'MarkerFaceColor', [0 0 0], ...
	   'MarkerSize', 6, 'Color', [0 0 0], ...
	   'Tag', 'NotchWidthMarker', ...
	   'HelpTopicKey', 'sisonotchwidthmarker', ...
	   'ButtonDownFcn', {@LocalShapeNotch Editor 'init'}); 
  setappdata(nwm(1), 'PZVIEW', hView);
  setappdata(nwm(2), 'PZVIEW', hView);
  
  hView.Extra = nwm;
  hPZ = [hPZ ; nwm];
else
  hView.Extra = zeros(0,1);
end

hView.Ruler = zeros(0,1);


% ----------------------------------------------------------------------------%
% LocalMovePZ
% Callback for button down on closed-loop poles
% REVISIT: merge with trackgain,trackpz when directed callback are available
% ----------------------------------------------------------------------------%
function LocalMovePZ(hSrc, junk, Editor, action)
persistent SISOfig WBMU sw lw lwid

switch action
   case 'init'
      % Initialize move
      SISOfig = gcbf;
      if ~strcmp(Editor.EditMode,'idle')
         % Redirect to editor axes
         Editor.mouseevent('bd',get(hSrc,'parent'));
      elseif strcmp(get(SISOfig,'SelectionType'),'normal')
         % Change pointer
         setptr(SISOfig, 'closedhand')
         
         % Take over window mouse events
         WBMU = get(SISOfig,{'WindowButtonMotionFcn','WindowButtonUpFcn'});
         set(SISOfig, 'WindowButtonMotionFcn', {@LocalMovePZ Editor 'acquire'}, ...
            'WindowButtonUpFcn', {@LocalMovePZ Editor 'finish'});
        % Disable all warnings
         sw = warning('off'); [lw, lwid] = lastwarn;
         % Initialize tracking algorithm and notify peers
         Editor.trackpz('init');
     end
      
   case 'acquire'
      % Track mouse location (move)
      Editor.trackpz('acquire');
      
   case 'finish'
      % Restore initial conditions
      set(SISOfig, {'WindowButtonMotionFcn','WindowButtonUpFcn'}, WBMU, ...
         'Pointer', 'arrow')
      % Clean up and update
      Editor.trackpz('finish');
      % Reset warnings
      warning(sw); lastwarn(lw, lwid)
end


% ----------------------------------------------------------------------------%
% LocalShapeNotch
% Callback for button down on closed-loop poles
% REVISIT: merge with trackgain when directed callback are available
% ----------------------------------------------------------------------------%
function LocalShapeNotch(hSrc, junk, Editor, action)
persistent SISOfig WBMU sw lw lwid

switch action
   case 'init'
      % Initialize move
      SISOfig = gcbf;
      if ~strcmp(Editor.EditMode,'idle')
         % Redirect to editor axes
         Editor.mouseevent('bd',get(hSrc,'parent'));
      elseif strcmp(get(SISOfig,'SelectionType'),'normal')
         % Change pointer
         setptr(SISOfig,'closedhand')
         % Take over window mouse events
         WBMU = get(SISOfig, {'WindowButtonMotionFcn', 'WindowButtonUpFcn'});
         set(SISOfig,'WindowButtonMotionFcn',{@LocalShapeNotch Editor 'acquire'},...
            'WindowButtonUpFcn', {@LocalShapeNotch Editor 'finish'});
         % Initialize tracking algorithm and notify peers
         Editor.shapenotch('init');
         % Disable all warnings
         sw = warning('off'); [lw,lwid] = lastwarn;
      end
      
   case 'acquire'
      % Track mouse location (move)
      Editor.shapenotch('acquire');
      
   case 'finish'
      % Restore initial conditions
      set(SISOfig, {'WindowButtonMotionFcn', 'WindowButtonUpFcn'}, WBMU, ...
         'Pointer', 'arrow')
      % Clean up and update
      Editor.shapenotch('finish');
      % Reset warnings
      warning(sw); lastwarn(lw,lwid)
end
