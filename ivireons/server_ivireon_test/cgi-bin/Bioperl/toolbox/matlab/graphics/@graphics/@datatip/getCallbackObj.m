function obj = getCallbackObj(hThis,hFig)
%Determine what the object controlling the callbacks is.
%   Copyright 2005-2006 The MathWorks, Inc.

hManager = uigetmodemanager(hFig);
if isactiveuimode(hFig,'Exploration.Datacursor')
    obj = hManager.CurrentMode;
else
    obj = hFig;
end