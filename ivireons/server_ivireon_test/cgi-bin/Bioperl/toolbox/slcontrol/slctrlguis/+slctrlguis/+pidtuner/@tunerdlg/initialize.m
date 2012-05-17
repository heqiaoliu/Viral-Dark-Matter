function initialize(this)
%INITIALIZE initialize the dialog

% Author(s): R. Chen
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2010/04/30 00:43:55 $

%%
% (re)initialize plot panel
s = this.DataSrc.generateTunedStructure;
this.Handles.PlotPanel.setTunedController(s);
s = this.DataSrc.generateBlockStructure;
this.Handles.PlotPanel.setBaseController(s);
% (re)initialize design panel
if strcmpi(this.DataSrc.TimeDomain,'continuous-time')
    this.Handles.DesignPanelBasic.initialize(0, this.CurrentWC);
    this.Handles.DesignPanelAdvanced.initialize(0, this.CurrentWC, this.CurrentPM);
else
    this.Handles.DesignPanelBasic.initialize(this.DataSrc.SampleTime, this.CurrentWC);
    this.Handles.DesignPanelAdvanced.initialize(this.DataSrc.SampleTime, this.CurrentWC, this.CurrentPM);
end
% if block controller results in unstable or improper closed loop (an empty @ss), hide block response
if isempty(this.DataSrc.r2y_Blk)
    this.Handles.PlotPanel.Handles.ShowBaseCheckBoxCOMPONENT.setSelected(false);
    this.setStatusText(pidtool.utPIDgetStrings('scd','tunerdlg_improperblock_warning'),'warning');
elseif this.DataSrc.getBlockStability
    this.Handles.PlotPanel.Handles.ShowBaseCheckBoxCOMPONENT.setSelected(true);    
else
    this.Handles.PlotPanel.Handles.ShowBaseCheckBoxCOMPONENT.setSelected(false);
    this.setStatusText(pidtool.utPIDgetStrings('scd','tunerdlg_unstableblock_warning'),'warning');
end
this.Handles.PlotPanel.showBaseResponse;
% (re)initialize plot type
if isa(this.DataSrc.G1,'frd')
    this.Handles.PlotPanel.Handles.PlotTypeComboBoxCOMPONENT.setSelectedIndex(1);
else
    this.Handles.PlotPanel.Handles.PlotTypeComboBoxCOMPONENT.setSelectedIndex(0);
end
