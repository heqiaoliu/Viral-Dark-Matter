function commeye_eyeScopeView(hEyeScope, newView)
%This undocumented function may be removed in a future release.

% eyeScopeView Switch the EyeScope view
% eyeScopeView(H, VIEW) switches the EyeScope view to VIEW.  H is the figure
% handle of the EyeScope.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/06/13 15:11:59 $

% Get the handle of the GUI object
hGui = getappdata(hEyeScope, 'GuiObject');

% Set the new scope face
if strncmp(newView, 'Compare', 7)
    hGui.CurrentScopeFace = hGui.SingleEyeScopeFace;
else
    hGui.CurrentScopeFace = hGui.CompareResultsScopeFace;
end

% Reset dirty
hGui.Dirty = 0;

% [EOF]