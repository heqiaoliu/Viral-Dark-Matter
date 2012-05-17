function build(this, s)
%BUILD  Builds PID tuner dialog.

% Author(s): R. Chen
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2010/04/21 22:04:59 $

%% Create figure
this.buildFigure;
set(this.Handles.Figure,'Tag','PIDTunerBLK');
this.updateName;
 % get dialog handle
[~, hDialog] = slctrlguis.pidtuner.utPIDhasUnappliedChanges(this.DataSrc.GCBH);
dlgsz = hDialog.position;
% DDG dialog position start from top left corner
tmp = figure('position',dlgsz,'visible','off');
set(this.Handles.Figure,'Units','character');
set(this.Handles.Figure,'Position',[0 0 144 50]);
centerfig(this.Handles.Figure,tmp);
delete(tmp);

%% Create toolbar
this.buildToolbar(s.DefaultLegendMode, s.DefaultDesignMode);

%% Information Panel
this.buildStatusBar;

%% Response Plot Panel
Data = this.DataSrc.initialParameterTableData;
Structure = struct(...
    'Platform','scd',...
    'DOF',this.DataSrc.DOF,...
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
% Help
CSHButton = javaObjectEDT('com.mathworks.mwswing.MJButton',...
    javaObjectEDT('javax.swing.ImageIcon',fullfile(matlabroot,'toolbox\matlab\icons\csh_icon.png')));
CSHButton.setName('PIDTUNER_CSHBUTTON');
CSHButton.setFlyOverAppearance(true);
CSHButton.setFocusTraversable(false);
[~, CSHButtonCONTAINER] = javacomponent(CSHButton,[.1,.1,.9,.9],this.Handles.ButtonPanel);
set(CSHButtonCONTAINER,'units','character')
% OK
OKButton = javaObjectEDT('com.mathworks.mwswing.MJButton',pidtool.utPIDgetStrings('cst','button_ok'));
OKButton.setName('PIDTUNER_OKBUTTON');
[~, OKButtonCONTAINER] = javacomponent(OKButton,[.1,.1,.9,.9],this.Handles.ButtonPanel);
set(OKButtonCONTAINER,'units','character')
% Cancel
CancelButton = javaObjectEDT('com.mathworks.mwswing.MJButton',pidtool.utPIDgetStrings('cst','button_cancel'));
CancelButton.setName('PIDTUNER_CANCELBUTTON');
[~, CancelButtonCONTAINER] = javacomponent(CancelButton,[.1,.1,.9,.9],this.Handles.ButtonPanel);
set(CancelButtonCONTAINER,'units','character')
% Apply
ApplyButton = javaObjectEDT('com.mathworks.mwswing.MJButton',pidtool.utPIDgetStrings('cst','button_apply'));
ApplyButton.setName('PIDTUNER_APPLYBUTTON');
[~, ApplyButtonCONTAINER] = javacomponent(ApplyButton,[.1,.1,.9,.9],this.Handles.ButtonPanel);
set(ApplyButtonCONTAINER,'units','character')
% Help
HelpButton = javaObjectEDT('com.mathworks.mwswing.MJButton',pidtool.utPIDgetStrings('cst','button_help'));
HelpButton.setName('PIDTUNER_HELPBUTTON');
[~, HelpButtonCONTAINER] = javacomponent(HelpButton,[.1,.1,.9,.9],this.Handles.ButtonPanel);
set(HelpButtonCONTAINER,'units','character')

%% Handles
this.Handles.CSHButtonCONTAINER = CSHButtonCONTAINER;
this.Handles.OKButtonCONTAINER = OKButtonCONTAINER;
this.Handles.CancelButtonCONTAINER = CancelButtonCONTAINER;
this.Handles.ApplyButton = ApplyButton;
this.Handles.ApplyButtonCONTAINER = ApplyButtonCONTAINER;
this.Handles.HelpButtonCONTAINER = HelpButtonCONTAINER;

%% Button Callbacks
h = handle(CSHButton,'callbackproperties');
hListener = handle.listener(h, 'ActionPerformed',{@CSHButtonCallback this});
this.Handles.CSHButtonListener = hListener;
h = handle(ApplyButton,'callbackproperties');
hListener = handle.listener(h, 'ActionPerformed',{@ApplyButtonCallback this});
this.Handles.ApplyButtonListener = hListener;
h = handle(OKButton,'callbackproperties');
hListener = handle.listener(h, 'ActionPerformed',{@OKButtonCallback this});
this.Handles.OKButtonListener = hListener;
h = handle(CancelButton,'callbackproperties');
hListener = handle.listener(h, 'ActionPerformed',{@CancelButtonCallback this});
this.Handles.CancelButtonListener = hListener;
h = handle(HelpButton,'callbackproperties');
hListener = handle.listener(h, 'ActionPerformed',{@HelpButtonCallback this});
this.Handles.HelpButtonListener = hListener;

% Automatic update checkbox
AutoUpdateCheckBox = javaObjectEDT('com.mathworks.mwswing.MJCheckBox',pidtool.utPIDgetStrings('scd','tunerdlg_autoupdate'));
AutoUpdateCheckBox.setName('PIDTUNER_AUTOUPDATECHECKBOX');
pidtool.utPIDaddCSH('slcontrol',AutoUpdateCheckBox,'pidtuner_autoupdatecheckbox');
[AutoUpdateCheckBoxCOMPONENT, AutoUpdateCheckBoxCONTAINER] = javacomponent(AutoUpdateCheckBox,[.1,.1,.9,.9],this.Handles.ButtonPanel);
set(AutoUpdateCheckBoxCONTAINER,'units','character')
this.Handles.AutoUpdateCheckBoxCOMPONENT = AutoUpdateCheckBoxCOMPONENT;
this.Handles.AutoUpdateCheckBoxCONTAINER = AutoUpdateCheckBoxCONTAINER;
h = handle(AutoUpdateCheckBox,'callbackproperties');
hListener = handle.listener(h, 'ActionPerformed',{@AutoUpdateCheckBoxCallback this});
this.Handles.AutoUpdateCheckBoxListener = hListener;

function CSHButtonCallback(hObject,eventdata,this) %#ok<*INUSD>
helpview(fullfile(docroot,'csh_icon_message.html'),'CSHelpWindow');

function OKButtonCallback(hObject,eventdata,this) %#ok<*INUSL>
ApplyButtonCallback([],[],this);
this.close;

function CancelButtonCallback(hObject,eventdata,this)
this.close;

function ApplyButtonCallback(hObject,eventdata,this)
this.apply;

function HelpButtonCallback(hObject,eventdata,this)
scdguihelp('pidtuner_dochelp','HelpBrowser')

function AutoUpdateCheckBoxCallback(hObject,eventdata,this) %#ok<*INUSL>
if hObject.isSelected
    this.AutoUpdateMode = 'ON';
    this.Handles.ApplyButton.setEnabled(false);
    this.apply;
else
    this.AutoUpdateMode = 'OFF';
    this.Handles.ApplyButton.setEnabled(true);
end

