function build(this, s)
%BUILD  Builds PID tuner dialog.

% Author(s): R. Chen
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2010/04/21 21:10:27 $

%% Create figure
this.buildFigure;
set(this.Handles.Figure,'Tag','PIDTunerLTI');
this.updateName;
% set default dialog size
set(this.Handles.Figure,'Units','character');
set(this.Handles.Figure,'Position',[0 0 140 50]);
centerfig(this.Handles.Figure);

%% Create toolbar
this.buildToolbar(s.DefaultLegendMode, s.DefaultDesignMode);

%% Inofrmation Panel
this.buildStatusBar;

%% Response Plot Panel
Data = this.DataSrc.initialParameterTableData;
Structure = struct(...
    'Platform','cst',...
    'DOF',1,...
    'ParentFigure',this.Handles.Figure,...
    'BackgroundColor', this.BackgroundColor, ...
    'TunedAxesIndex', 2, ...
    'TunedTableIndex', 1, ...
    'TunedAxesColor', s.TunedColor, ...
    'BaseAxesIndex', 1, ...
    'BaseTableIndex', 2, ...
    'BaseAxesColor', s.BlockColor, ...
    'ShownLegend', strcmpi(s.DefaultLegendMode,'on'), ...
    'ShownTable', strcmpi(s.DefaultTableMode,'on'), ...
    'PlotType', s.DefaultPlotType);
this.Handles.PlotPanel = pidtool.ResponsePlotPanel(Structure,Data);
%% Design Panel
this.buildDesignPanel;

%% Button Panel
this.Handles.ButtonPanel = uipanel('parent',this.Handles.Figure,'bordertype','none','units','character','BackgroundColor',this.BackgroundColor);
% CSH
CSHButton = javaObjectEDT('com.mathworks.mwswing.MJButton',...
    javaObjectEDT('javax.swing.ImageIcon',fullfile(matlabroot,'toolbox\matlab\icons\csh_icon.png')));
CSHButton.setName('PIDTUNER_CSHBUTTON');
CSHButton.setFlyOverAppearance(true);
CSHButton.setFocusTraversable(false);
[~, CSHButtonCONTAINER] = javacomponent(CSHButton,[.1,.1,.9,.9],this.Handles.ButtonPanel);
set(CSHButtonCONTAINER,'units','character')
% OK
OKButton = javaObjectEDT('com.mathworks.mwswing.MJButton',pidtool.utPIDgetStrings('cst','button_close'));
OKButton.setName('PIDTUNER_OKBUTTON');
[~, OKButtonCONTAINER] = javacomponent(OKButton,[.1,.1,.9,.9],this.Handles.ButtonPanel);
set(OKButtonCONTAINER,'units','character')
% Help
HelpButton = javaObjectEDT('com.mathworks.mwswing.MJButton',pidtool.utPIDgetStrings('cst','button_help'));
HelpButton.setName('PIDTUNER_HELPBUTTON');
[~, HelpButtonCONTAINER] = javacomponent(HelpButton,[.1,.1,.9,.9],this.Handles.ButtonPanel);
set(HelpButtonCONTAINER,'units','character')

%% Handles
this.Handles.CSHButtonCONTAINER = CSHButtonCONTAINER;
this.Handles.OKButtonCONTAINER = OKButtonCONTAINER;
this.Handles.HelpButtonCONTAINER = HelpButtonCONTAINER;

%% Button Callbacks
h = handle(CSHButton,'callbackproperties');
hListener = handle.listener(h, 'ActionPerformed',{@CSHButtonCallback this});
this.Handles.CSHButtonListener = hListener;
h = handle(HelpButton,'callbackproperties');
hListener = handle.listener(h, 'ActionPerformed',{@HelpButtonCallback this});
this.Handles.HelpButtonListener = hListener;
h = handle(OKButton,'callbackproperties');
hListener = handle.listener(h, 'ActionPerformed',{@OKButtonCallback this});
this.Handles.OKButtonListener = hListener;

function CSHButtonCallback(hObject,eventdata,this) %#ok<*INUSD>
helpview(fullfile(docroot,'csh_icon_message.html'),'CSHelpWindow');

function OKButtonCallback(hObject,eventdata,this) %#ok<*INUSL>
this.close;

function HelpButtonCallback(hObject,eventdata,this)
helpview(fullfile(docroot,'toolbox','control','control.map'),'pidtool_dochelp')

