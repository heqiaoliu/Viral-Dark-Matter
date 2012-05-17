function h = uitoggletool(varargin)
%UITOGGLETOOL Constructor for uitoggletool object.
%   UITOGGLETOOL is an item that can change its behavior based on the state
%   of the item. For example, clicked or pressed.
%
%   UITOGGLETOOL(NAME,PLACE) creates a UITOGGLETOOL UIMgr object, sets the
%   name, and the button rendering placement.
%
%   UITOGGLETOOL(NAME) sets the placement to 0.
% 
%   % Example 1: 
%
%   b1 = uimgr.uitoggletool('ZoomIn');
%   
%   % where the first argument is the NAME to use for the new UIMgr node
%   % and the PLACE is defaulted to 0

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2009/07/06 20:47:24 $

% Allow subclass to invoke this directly
h = uimgr.uitoggletool;

% This object does not support a user-specified widget function;
% the uipushtool always instantiates an HG uitoggletool.
h.allowWidgetFcnArg = false;

% We always create a uipushtool widget every time we render
h.WidgetFcn = @(hThis)createUIToggleTool(hThis);

% Continue with standard item instantiation
h.uibutton(varargin{:});

% -----------------------------
function hWidget = createUIToggleTool(hThis)
% Create the HG uitoggletool widget

% Setting the tag name of the uitoggletool button is not essential.
% It is done for possible future use, and to support testing.
hWidget = uitoggletool(hThis.GraphicalParent,'tag',[class(hThis), '_', hThis.name]);

% Find and set icon from appdata name, if specified
if ~isempty(hThis.iconAppData)
    set(hWidget,'cdata',uimgr.getappdata(hThis,hThis.iconAppData));
end

% [EOF]
