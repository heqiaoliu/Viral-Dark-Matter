function h = spcpushtool(varargin)
%SPCPUSHTOOL Constructor for spcpushtool object.
%   SPCPUSHTOOL(NAME,PLACE) creates an SPCPUSHTOOL UIMgr object, sets
%   the name, and the button rendering placement.
%
%   SPCPUSHTOOL(NAME) sets the placement to 0.
%
%   % Example:
%
%     hButton = uimgr.spcpushtool('Stop');
%
%   % where the argument is the name to use for the new UIMgr node

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.8.7 $ $Date: 2009/08/14 04:07:22 $

% Allow subclass to invoke this directly
h = uimgr.spcpushtool;

% This object does not support a user-specified widget function;
% the spcpushtool always instantiates an spcwidgets.uipushtool.
h.allowWidgetFcnArg = false;

% We always create a uipushtool widget every time we render
h.WidgetFcn = @(hThis)createSPCPushTool(hThis);

h.StateName = 'Selection';

% Continue with standard item instantiation (uiitem, NOT uibutton)
% (uibutton sets StateName to something else...)
h.uiitem(varargin{:});


% -----------------------------
function hWidget = createSPCPushTool(hThis)
% Create the spcwidgets.PushTool widget

% Setting the tag name of the uipushtool button is not essential.
% It is done for possible future use, and to support testing.
hWidget = spcwidgets.PushTool(hThis.GraphicalParent,'Tag', [class(hThis), '_', hThis.name]);

% Find and set icon from appdata name, if specified
if ~isempty(hThis.iconAppData)
    set(hWidget,'Icons',uimgr.getappdata(hThis,hThis.iconAppData));
end

% [EOF]
