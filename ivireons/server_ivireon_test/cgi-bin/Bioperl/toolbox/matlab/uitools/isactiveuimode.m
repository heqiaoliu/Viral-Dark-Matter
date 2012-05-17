function res = isactiveuimode(hFig,name)
% This function is undocumented and will change in a future release

%ISACTIVEUIMODE Returns whether a mode is currently active.
%   ISACTIVEUIMODE(FIG,NAME) will return evaluate to true if the mode
%   with the given name is currently active in the figure FIG.
%
%   See also UIMODE, GETUIMODE, HASUIMODE, ACTIVATEUIMODE

%   Copyright 2006-2007 The MathWorks, Inc.

hManager = uigetmodemanager(hFig);
hMode = hManager.CurrentMode;
if isempty(hMode) || ~ishandle(hMode)
    res = false;
else
    res = strcmp(hMode.Name,name);
end