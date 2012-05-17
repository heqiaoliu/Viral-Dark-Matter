function commeye_addEyeDiagramObjects(hEyeScope, eyeObjStr)
%This undocumented function may be removed in a future release.

% addEyeDiagramObjects Add eye diagram objects to the EyeScope
% addEyeDiagramObjects(H, EYE) adds eye diagram objects stored in the structure
% EYE to the EyeScope, whose figure handle is H.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/06/13 15:11:58 $

% Get the handle of the GUI object
hGui = getappdata(hEyeScope, 'GuiObject');

fNames = fieldnames(eyeObjStr);

% Skip the first one since it has already been imported in the demo
for p=2:length(fNames)
    eyeStr.Name = fNames{p};
    eyeStr.Source = 'ws';
    eyeStr.Handle = eyeObjStr.(fNames{p});
    importEyeDiagramObject(hGui, eyeStr)
end

% Reset dirty
hGui.Dirty = 0;

% [EOF]