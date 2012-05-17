function initialize(this)
%INITIALIZE initialize the dialog

% Author(s): R. Chen
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2010/03/31 18:13:09 $

% (re)initialize plot panel
s = this.DataSrc.generateTunedStructure;
this.Handles.PlotPanel.setTunedController(s);
% (re)initialize design panel
this.Handles.DesignPanelBasic.initialize(0, this.CurrentWC);
this.Handles.DesignPanelAdvanced.initialize(0, this.CurrentWC, this.CurrentPM);
% deal with baseline
if isempty(this.DataSrc.C_Base)
    % disable 
    this.Handles.PlotPanel.Handles.ShowBaseCheckBoxCOMPONENT.setSelected(false);
    this.Handles.PlotPanel.Handles.ShowBaseCheckBoxCOMPONENT.setEnabled(false);
else
    this.Handles.PlotPanel.Handles.ShowBaseCheckBoxCOMPONENT.setSelected(true);
    this.Handles.PlotPanel.Handles.ShowBaseCheckBoxCOMPONENT.setEnabled(true);
    s = this.DataSrc.generateBaseStructure;
    this.Handles.PlotPanel.setBaseController(s);
    % if base controller results in unstable or improper closed loop (an empty
    % @ss), hide base response
    if isempty(this.DataSrc.r2y_Base)
        this.Handles.PlotPanel.Handles.ShowBaseCheckBoxCOMPONENT.setSelected(false);
        this.setStatusText(pidtool.utPIDgetStrings('cst','tunerdlg_improperbase_warning'),'warning');
    elseif ~this.DataSrc.IsStable_Base
        this.Handles.PlotPanel.Handles.ShowBaseCheckBoxCOMPONENT.setSelected(false);
        this.setStatusText(pidtool.utPIDgetStrings('cst','tunerdlg_unstablebase_warning'),'warning');
    end
end
this.Handles.PlotPanel.showBaseResponse;
% (re)initialize plot type
if isa(this.DataSrc.G,'frd')
    this.Handles.PlotPanel.Handles.PlotTypeComboBoxCOMPONENT.setSelectedIndex(1);
else
    this.Handles.PlotPanel.Handles.PlotTypeComboBoxCOMPONENT.setSelectedIndex(0);
end
