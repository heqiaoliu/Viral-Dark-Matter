function plotcomp(Editor)
% Renders compensator poles and zeros.

%   Author(s): P. Gahinet
%   Copyright 1986-2008 The MathWorks, Inc. 
%   $Revision: 1.30.4.5 $ $Date: 2008/06/13 15:14:04 $


L = Editor.LoopData.L(Editor.EditedLoop);

% Get pole/zero group information
TunedFactors = L.TunedFactors;
PZGroups = [];
for ct = 1:length(TunedFactors)
    PZGroups = [PZGroups; TunedFactors(ct).PZGroup];
end
Nf = length(PZGroups);  % number of groups

% Feedback or feedforward?
FeedbackFlag = (L.Feedback);

% Initialize list of PZ group renderers (@PZVIEW objects)
Nc = size(Editor.EditedPZ,1);  % current number of PZVIEW objects
% Delete extra groups
if Nc>Nf,
   delete(Editor.EditedPZ(Nf+1:Nc,:));
   Editor.EditedPZ = Editor.EditedPZ(1:Nf,:);
end
% Add new groups
for ct=Nc+1:Nf,
   Editor.EditedPZ = [Editor.EditedPZ ; [sisogui.pzview,sisogui.pzview]];
end

% Render each pole/zero group
PlotAxes = getaxes(Editor.Axes);
HG = Editor.HG;  
HG.Compensator.Magnitude = zeros(0,1);
HG.Compensator.Phase = zeros(0,1);
Focus = Editor.FreqFocus;
for ct=1:Nf
   h = Editor.EditedPZ(ct,:);  % PZVIEW object for mag plot
   set(h,'GroupData',PZGroups(ct));
   [hPZ1,hPZ2] = LocalRender(h,PlotAxes,Editor,FeedbackFlag,Focus);
   HG.Compensator.Magnitude = [HG.Compensator.Magnitude ; hPZ1];
   HG.Compensator.Phase = [HG.Compensator.Phase ; hPZ2];
end
Editor.HG = HG;


%----------------- Local functions -----------------


%%%%%%%%%%%%%%%
% LocalRender %
%%%%%%%%%%%%%%%
function [hPZ1,hPZ2] = LocalRender(hView,PlotAxes,Editor,FeedbackFlag,Focus)
% Renders pole/zero group
% HVIEW = @PZVIEW object rendering a given pole/zero group

% RE: Editable poles and zeros are always visible to the limit picker 
%     to avoid losing track of them

% Unit conversion factor
FreqFactor = unitconv(1,'rad/sec',Editor.Axes.XUnits);
Zlevel = Editor.zlevel('compensator');
Ts = Editor.LoopData.Ts;

% RE: Leave Y coordinate undefined (resolved by one-shot interp)
Style = Editor.LineStyle;
hMagView = hView(1);           % PZVIEW object for mag plot
hPhaseView = hView(2);         % PZVIEW object for phase plot
PZGroup = hMagView.GroupData;  % Rendered PZGROUP

% Determine pole/zero color
if FeedbackFlag
   % Feedback component
   PZColor = Style.Color.Compensator;
   HelpTopicKey = 'sisocompensatorpolezero';
else
   % Feedforward component
   PZColor = Style.Color.PreFilter;
   HelpTopicKey = 'sisofilterpolezero';
end

% Render zeros
Zeros = PZGroup.Zero;   % zero values
if ~isempty(Zeros)
   if Ts
      FreqZ = FreqFactor * min(damp(Zeros(1),Ts),pi/Ts);
   else
      FreqZ = FreqFactor * damp(Zeros(1));
   end
   ZProps = {...
      'LineStyle','none','Color',PZColor,...
      'HelpTopicKey',HelpTopicKey,...
      'Marker','o','MarkerSize',6};
   hZ(1,1) = line(FreqZ,NaN,Zlevel,...
      'Parent',PlotAxes(1),'Visible',Editor.MagVisible,...
      'ButtonDownFcn',{@LocalMovePZ Editor 'init'},ZProps{:}); 
   setappdata(hZ(1),'PZVIEW',hMagView);
   hZ(1,2) = line(FreqZ,NaN,Zlevel,...
      'Parent',PlotAxes(2),'Visible',Editor.PhaseVisible,...
      'ButtonDownFcn',{@LocalMovePZ Editor 'init'},ZProps{:}); 
   setappdata(hZ(2),'PZVIEW',hPhaseView);
   if any(strcmp(PZGroup.Type,{'Complex','Notch'}))
      set(hZ,'LineWidth',2)
   end
   % Exclude roots far out focus region from limit picking
   if ~isempty(Focus) && (FreqZ<1e-2*Focus(1) || FreqZ>1e2*Focus(2))
      set(hZ,'XlimInclude','off','YlimInclude','off')
   end
else
   hZ = zeros(0,2);
end
hMagView.Zero = hZ(ones(1,length(Zeros)),1);
hPhaseView.Zero = hZ(ones(1,length(Zeros)),2);

% Render poles
Poles = PZGroup.Pole;   % pole values
if ~isempty(Poles)
   if Ts
      FreqP = FreqFactor * min(damp(Poles(1),Ts),pi/Ts);
   else
      FreqP = FreqFactor * damp(Poles(1));
   end
   PProps = {...
         'LineStyle','none','Color',PZColor,...
         'HelpTopicKey',HelpTopicKey,...
         'Marker','x','MarkerSize',8};
   hP(1,1) = line(FreqP,NaN,Zlevel,...
      'Parent',PlotAxes(1),'Visible',Editor.MagVisible,...
      'ButtonDownFcn',{@LocalMovePZ Editor 'init'},PProps{:});  
   setappdata(hP(1),'PZVIEW',hMagView);
   hP(1,2) = line(FreqP,NaN,Zlevel,...
      'Parent',PlotAxes(2),'Visible',Editor.PhaseVisible,...
      'ButtonDownFcn',{@LocalMovePZ Editor 'init'},PProps{:}); 
   setappdata(hP(2),'PZVIEW',hPhaseView);
   if any(strcmp(PZGroup.Type,{'Complex','Notch'}))
      set(hP,'LineWidth',2)
   end
   % Exclude roots far out focus region from limit picking
   % (e.g., p=2e-17 will yield huge X range)
   if ~isempty(Focus) && (FreqP<1e-2*Focus(1) || FreqP>1e2*Focus(2))
      set(hP,'XlimInclude','off','YlimInclude','off')
   end
else
   hP = zeros(0,2);
end
hMagView.Pole = hP(ones(1,length(Poles)),1);
hPhaseView.Pole = hP(ones(1,length(Poles)),2);

% Overall handles (no repetition)
hPZ1 = [hZ(:,1) ; hP(:,1)];
hPZ2 = [hZ(:,2) ; hP(:,2)];

% Add notch width markers (mag plot only)
if strcmp(PZGroup.Type,'Notch')
   Xm = FreqFactor * notchwidth(PZGroup,Ts);  % Marker frequencies
   NWProps = {...
         'XlimInclude','off','YlimInclude','off',...
         'Visible',Editor.MagVisible,...
         'LineStyle','none','Marker','diamond',...
         'MarkerFaceColor',[0 0 0],'MarkerSize',6,'Color',[0 0 0],...
         'Tag','NotchWidthMarker',...
         'HelpTopicKey','sisonotchwidthmarker',...
         'ButtonDownFcn',{@LocalShapeNotch Editor 'init'}}; 
   nwm(1,1) = line(Xm(1),NaN,Zlevel,'Parent',PlotAxes(1),NWProps{:});
   nwm(2,1) = line(Xm(2),NaN,Zlevel,'Parent',PlotAxes(1),NWProps{:});
   setappdata(nwm(1),'PZVIEW',hMagView);
   setappdata(nwm(2),'PZVIEW',hMagView);
   hMagView.Extra = nwm;
   hPZ1 = [hPZ1 ; nwm];
else
   hMagView.Extra = zeros(0,1);
end
hMagView.Ruler = zeros(0,1);



%%%%%%%%%%%%%%%%%%%
%%% LocalMovePZ %%%
%%%%%%%%%%%%%%%%%%%
function LocalMovePZ(hSrc,junk,Editor,action)
% Callback for button down on closed-loop poles
% REVISIT: merge with trackgain,trackpz when directed callback are available
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
         WBMU = get(SISOfig,{'WindowButtonMotionFcn','WindowButtonUpFcn'});
         set(SISOfig,'WindowButtonMotionFcn',{@LocalMovePZ Editor 'acquire'},...
            'WindowButtonUpFcn',{@LocalMovePZ Editor 'finish'});
        % Disable all warnings
         sw = warning('off'); [lw, lwid] = lastwarn;
         % Initialize tracking algorithm and notify peers
         trackpz(Editor,'init');
      end
   case 'acquire'
      % Track mouse location (move)
      trackpz(Editor,'acquire');
   case 'finish'
      % Restore initial conditions
      set(SISOfig,{'WindowButtonMotionFcn','WindowButtonUpFcn'},WBMU,'Pointer','arrow')
      % Clean up and update
      trackpz(Editor,'finish');
      % Reset warnings
      warning(sw); lastwarn(lw, lwid)
end


%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalShapeNotch %%%
%%%%%%%%%%%%%%%%%%%%%%%
function LocalShapeNotch(hSrc,junk,Editor,action)
% Callback for button down on closed-loop poles
% REVISIT: merge with trackgain when directed callback are available
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
         WBMU = get(SISOfig,{'WindowButtonMotionFcn','WindowButtonUpFcn'});
         set(SISOfig,'WindowButtonMotionFcn',{@LocalShapeNotch Editor 'acquire'},...
            'WindowButtonUpFcn',{@LocalShapeNotch Editor 'finish'});
         % Initialize tracking algorithm and notify peers
         shapenotch(Editor,'init');
         % Disable all warnings
         sw = warning('off'); [lw,lwid] = lastwarn;
      end
   case 'acquire'
      % Track mouse location (move)
      shapenotch(Editor,'acquire');
   case 'finish'
      % Restore initial conditions
      set(SISOfig,{'WindowButtonMotionFcn','WindowButtonUpFcn'},WBMU,'Pointer','arrow')
      % Clean up and update
      shapenotch(Editor,'finish');
      % Reset warnings
      warning(sw); lastwarn(lw,lwid);
end
