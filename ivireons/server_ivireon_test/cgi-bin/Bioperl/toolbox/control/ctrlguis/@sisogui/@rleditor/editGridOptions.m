function TextBox = editGridOptions(this,BoxLabel,BoxPool)
% EDITGRIDOPTIONS  Builds group box for editing Grid Options in the Options 
%                  Tab. 
%                  1) Show Grid Option
%                  2) Display damping Ratio as Percent Overshoot.

% Author (s): Kamesh Subbarao
% Copyright 1986-2010 The MathWorks, Inc. 
%   $Revision: 1.3.4.2 $  $Date: 2010/04/30 00:37:00 $
TextBox = find(handle(BoxPool),'Tag','GridOptions');
if isempty(TextBox)
   % Create groupbox if not found
   TextBox = LocalCreateUI;
end
TextBox.GroupBox.setLabel(sprintf(BoxLabel))
TextBox.Tag = 'GridOptions';

% Targeting
TextBox.Target = this;
props = [findprop(this.Axes,'Grid');findprop(this,'GridOptions')];
TextBox.TargetListeners = ...
   [handle.listener(this.Axes,props(1),'PropertyPostSet',{@localReadProp TextBox});...
      handle.listener(this,props(2)   ,'PropertyPostSet',{@localReadProp TextBox})];

% Initialization
s = get(TextBox.GroupBox,'UserData');
GridLabel  = s.GridLabelType;
%
GridLabelOpt = get(this,'GridOptions'); 
GridState = strcmpi(this.Axes.Grid,'on');
s.Grid.setState(GridState);
GridLabelTypeState = strcmpi(GridLabelOpt.GridLabelType,'overshoot');
s.GridLabelType.setState(GridLabelTypeState);


%------------------ Local Functions ------------------------

function OptionsBox = LocalCreateUI()

% Toolbox Preferences
Prefs = cstprefs.tbxprefs;

%---Top-level panel (MWGroupbox)
s.Main = com.mathworks.mwt.MWGroupbox(sprintf('Grid'));
s.Main.setLayout(java.awt.GridLayout(2,1,0,3));
s.Main.setFont(Prefs.JavaFontB);

%---Checkbox to toggle grid visibility
s.Grid = com.mathworks.mwt.MWCheckbox(sprintf('Show grid'));
s.Grid.setFont(Prefs.JavaFontP);
s.Main.add(s.Grid);
s.GridLabelType = com.mathworks.mwt.MWCheckbox(sprintf('Display damping values as %% peak overshoot'));
s.GridLabelType.setFont(Prefs.JavaFontP);
s.Main.add(s.GridLabelType);

%---Create @editbox instance
OptionsBox = cstprefs.editbox;

%---Install GUI callbacks
GUICallback = {@localWriteProp,OptionsBox};
s.Grid.setName('Grid');
hc = handle(s.Grid, 'callbackproperties');
set(hc,'ItemStateChangedCallback',GUICallback);
s.GridLabelType.setName('GridLabelType');
hc = handle(s.GridLabelType, 'callbackproperties');
set(hc,'ItemStateChangedCallback',GUICallback);


%---Store java handles
set(s.Main,'UserData',s);

%---Return handle of top-level GUI
OptionsBox.GroupBox = s.Main;

%%%%%%%%%%%%%%%%%
% localReadProp %
%%%%%%%%%%%%%%%%%

function localReadProp(eventSrc,eventData,OptionsBox)

% Target -> GUI
s = get(OptionsBox.GroupBox,'UserData');
GridLabel    = s.GridLabelType;
GridLabelOpt = get(OptionsBox.Target,'GridOptions');
switch eventSrc.Name
case 'Grid'
   GridState = strcmpi(eventData.NewValue,'on');
   s.Grid.setState(GridState);
   GridLabel.setEnabled(GridState)
case 'GridOptions'
   GridLabelTypeState = ...
      strcmpi(eventData.NewValue.GridLabelType,'overshoot');
      s.GridLabelType.setState(GridLabelTypeState);
end


%%%%%%%%%%%%%%%%%%
% localWriteProp %
%%%%%%%%%%%%%%%%%%

function localWriteProp(eventSrc,eventData,OptionsBox)

% GUI -> Target
this = OptionsBox.Target;
switch char(eventSrc.getName)
case 'Grid'
    if eventSrc.getState
        set(this.Axes,'Grid','on');
    else      
        set(this.Axes,'Grid','off');
    end
case 'GridLabelType'
   GridOPt = get(this,'GridOptions');
   if eventSrc.getState
      GridOpt.GridLabelType = 'overshoot';
   else
      GridOpt.GridLabelType = 'damping';
   end
   set(this,'GridOptions',GridOpt);
end
