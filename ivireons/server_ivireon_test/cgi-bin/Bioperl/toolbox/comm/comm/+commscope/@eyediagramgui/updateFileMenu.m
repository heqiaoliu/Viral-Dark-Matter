function handles = updateFileMenu(this)
%UPDATEFILEMENU Update the file menu of the GUI

%   @commscope/@eyediagramgui
%
%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/06/13 15:11:45 $

handles = getappdata(this.FigureHandle, 'MenuHandles');
handles = handles.FileMenu;

% Update Save Session
if this.Dirty
    % Enable menu item
    set(handles.FileSaveSession, 'Enable', 'on');
else
    % Disable menu item
    if ~isempty(handles)
        % If this is the first rendering, then we will not have the application
        % data.  So disbale only if this is not the first rendering.
        set(handles.FileSaveSession, 'Enable', 'off');
    end
end

% Update Remove Eye Diagram Object
hEye = getSelectedEyeObj(this.CurrentScopeFace);
if isempty(hEye)
    % Enable menu item
    set(handles.FileRemoveEyeDiagram, 'Enable', 'off');
else
    % Disable menu item
    set(handles.FileRemoveEyeDiagram, 'Enable', 'on');
end

%-------------------------------------------------------------------------------
% [EOF]
