function importEyeDiagramObject(this, newEyeObjStr)
%IMPORTEYEDIAGRAMOBJECT Import an eye diagram object
%   IMPORTEYEDIAGRAMOBJECT(THIS, NEWEYEOBJSTR) imports the eye diagram object
%   pointed by the NEWEYEOBJSTR.HANDLE. It also sets the active eye diagram
%   object to this imported object.

%   @commscope/@eyediagramgui
%
%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/08/01 12:17:50 $

% Assign scope axes as the eyediagram object PrivScopeHandle
newEyeObjStr.Handle.PrivScopeHandle = this.FigureHandle;

% Import the eye diagram object
import(this.EyeDiagramObjMgr, newEyeObjStr);

% Update the data
eyeObjs = getEyeObjects(this.EyeDiagramObjMgr);
me = prepareCompareTableData(this.MeasurementsPanel, eyeObjs);
if ~isempty(me)
    setException(this.CurrentScopeFace, me);
end

% Indicate the change in the GUI by setting the dirty flag
set(this, 'Dirty', 1);

% Update the GUI to reflect the changes.
update(this.CurrentScopeFace);

%-------------------------------------------------------------------------------
% [EOF]
