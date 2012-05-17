function handles = updateViewMenu(this)
%UPDATEVIEWMENU Update the view menu of the GUI

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 

handles = getappdata(this.FigureHandle, 'MenuHandles');
handles = handles.ViewMenu;

if this.CurrentScopeFace == this.SingleEyeScopeFace
    set(handles.ViewSingleEye, 'Checked', 'on');
    set(handles.ViewCompare, 'Checked', 'off');
    set(handles.ViewLegend, 'Enable', 'off')
    set(handles.ViewLegend, 'Checked', 'off')
else
    set(handles.ViewSingleEye, 'Checked', 'off');
    set(handles.ViewCompare, 'Checked', 'on');
    if ~isempty(this.PlotCtrlWin) && isRendered(this.PlotCtrlWin)
        close(this.PlotCtrlWin)
    end
    value = getLegend(this.CurrentScopeFace);
    set(handles.ViewLegend, 'Checked', value)
    set(handles.ViewLegend, 'Enable', 'on')
end

%-------------------------------------------------------------------------------
% [EOF]
