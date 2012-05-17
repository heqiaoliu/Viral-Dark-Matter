function cleanup(this)
% CLEANUP
%
 
% Author(s): John W. Glass 12-Dec-2006
% Copyright 2006 The MathWorks, Inc.
% $Revision: 1.1.10.2 $ $Date: 2008/03/13 17:39:50 $

% Delete the ltiviewer in the linearization task if needed
if isa(this.LTIViewer,'viewgui.ltiviewer')
    close(this.LTIViewer.Figure);
end

% Delete listeners
if ~isempty(this.Dialog)
    delete(this.Handles.MATLABAnalysisResultsTableModel)
    delete(this.Handles.OpCondSelectionPanel.Handles.MATLABOpCondTableModel)
    delete(this.Handles.OpCondSelectionPanel.OperatingConditionsListeners)
    delete(this.LinearizationResultsListeners)
    delete(this.OperatingConditionsListeners)
end

if ~isempty(this.MenuBar)
    javaMethodEDT('dispose',this.MenuBar);
    this.MenuBar = [];
end

if ~isempty(this.ToolBar)
    javaMethodEDT('dispose',this.ToolBar);
    this.ToolBar = [];
end