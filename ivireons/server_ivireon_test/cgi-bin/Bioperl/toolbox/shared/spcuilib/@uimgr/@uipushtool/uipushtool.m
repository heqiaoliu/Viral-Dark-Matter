function h = uipushtool(varargin)
%UIPUSHTOOL Constructor for a uipushtool object.
%   UIPUSHTOOL(NAME,PLACE) creates a UIPUSHTOOL UIMgr object, sets the
%   name, and the button rendering placement.
%   UIPUSHTOOL(NAME) sets the placement to 0.
%
%   % Example:
%
%     tNew = uimgr.uipushtool('New',0);
%
%     % where the first argument is the name to use for the new UIMgr node,
%     % and the second argument is the placement order to render the item.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2009/07/06 20:47:19 $

% Allow subclass to invoke this directly
h = uimgr.uipushtool;

% This object does not support a user-specified widget function;
% the uipushtool always instantiates an HG uipushtool.
h.allowWidgetFcnArg = false;

% We always create a uipushtool widget every time we render
h.WidgetFcn = @(hThis)createUIPushTool(hThis);

% Continue with standard item instantiation
h.uibutton(varargin{:});

% -----------------------------
function hWidget = createUIPushTool(hThis)
% Create the HG uipushtool widget

% Setting the tag name of the uipushtool button is not essential.
% It is done for possible future use, and to support testing.
hWidget = uipushtool(hThis.GraphicalParent,'tag',[class(hThis), '_',hThis.name]);

% Find and set icon from appdata name, if specified
if ~isempty(hThis.iconAppData)
    set(hWidget,'cdata',uimgr.getappdata(hThis,hThis.iconAppData));
end

% [EOF]
