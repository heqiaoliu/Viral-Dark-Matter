function deleteEyeDiagramObject(this, idx)
%DELETEEYEDIAGRAMOBJECT Delete an eye diagram object
%   DELETEEYEDIAGRAMOBJECT(THIS, IDX) deletes the eye diagram object
%   at index IDX.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/08/01 12:17:49 $

% Get the eye diagram object manager
hEyeMgr = this.EyeDiagramObjMgr;

% Delete the eye diagram object
success = delete(hEyeMgr, idx);

if success
    % Update the data
    eyeObjs = getEyeObjects(hEyeMgr);
    me = prepareCompareTableData(this.MeasurementsPanel, eyeObjs);
    if ~isempty(me)
        setException(this.CurrentScopeFace, me);
    end

    % Indicate the change in the GUI by setting the dirty flag
    set(this, 'Dirty', 1);

    % Update the GUI to reflect the changes.
    update(this.CurrentScopeFace);
end
%-------------------------------------------------------------------------------
% [EOF]
