function handles = updateOptionsMenu(this)
%UPDATEOPTIONSMENU Update the options menu of the GUI

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 

handles = getappdata(this.FigureHandle, 'MenuHandles');
handles = handles.OptionsMenu;

if this.CurrentScopeFace == this.SingleEyeScopeFace
    set(handles.OptionsPlotCtrl, 'Enable', 'on');
else
    if ~isempty(this.PlotCtrlWin) && isRendered(this.PlotCtrlWin)
        close(this.PlotCtrlWin)
    end
    set(handles.OptionsPlotCtrl, 'Enable', 'off');
end

%-------------------------------------------------------------------------------
% [EOF]
