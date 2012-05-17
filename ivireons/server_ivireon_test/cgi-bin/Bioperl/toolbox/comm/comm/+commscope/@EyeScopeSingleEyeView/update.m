function update(this)
%UPDATE Update the single eye scope face
%   Updated the data displayed in the single eye scope face.  Instead of
%   rendering the widgets, it changes the data field contents.

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/11/13 04:14:12 $

% Get active eye diagram object
activeEyeObj = getSelected(this.EyeDiagramObjMgr);

if isempty(activeEyeObj)
    % If there are no objects in the memory, then render single eye
    unrender(this);
    render(this);
else

    % Get the eye diagram object handle
    hEye = activeEyeObj.Handle;

    % Update the colormap
    updateColorMap(this, hEye);
    
    % Get the operation mode
    opMode = get(hEye, 'OperationMode');
    currentMode = this.Mode;

    % If there is a mismatch, then we need to remove the current
    % scope face and render again
    if ~strcmp(opMode, currentMode)
        % Force rendering with new settings
        unrender(this);
        render(this);
    else
        % The mode is the same.  Just update data.
        
        % Get the handles
        handles = this.WidgetHandles;

        %-------------------------------------------------------
        % Update axes
        plotEyeDiagram(this)

        %-------------------------------------------------------
        % Update list
        [eyeObjList selectedIdx] = getSortedNameList(this.EyeDiagramObjMgr);
        set(handles.EyeObjName, 'String', eyeObjList, 'Value', selectedIdx);

        %-------------------------------------------------------
        % Update eye diagram object settings view panel
        updateInfoTable(this, ...
            handles.SettingsPanelContents, ...
            this.SettingsPanel);

        %-------------------------------------------------------
        % Update measurements view panel
        updateInfoTable(this, handles.MeasurementsPanelContents, ...
            this.MeasurementsPanel);

        %-------------------------------------------------------
        % Update list buttons
        updateListButtons(this)
        
        %-------------------------------------------------------
        % Update the plot control window
        if ~isempty(this.PlotCtrlWin)
            update(this.PlotCtrlWin, hEye)
        end
    end

% Update the plot control window
if ~isempty(this.PlotCtrlWin)
    eyeObjStr = getSelected(this.EyeDiagramObjMgr);
    update(this.PlotCtrlWin, eyeObjStr.Handle)
end

% Check if there was an exception during rendering
checkException(this);

end
%-------------------------------------------------------------------------------
% [EOF]
