function h = spctoggletool(varargin)
%SPCTOGGLETOOL Constructor for spctoggletool object.
%   SPCTOGGLETOOL(NAME,PLACE) creates an SPCTOGGLETOOL UIMgr object, sets
%   the name, and the button rendering placement.
%   
%   An spctoggeltool is an item that can change its state based on being
%   clicked on.  For a menu item this might mean showing a check mark
%   before the string.  For a button this could mean changing the icon on
%   the button after clicking or keeping the button pressed.
%
%   SPCTOGGLETOOL(NAME) sets the placement to 0.
%
%   % Example:
%
%      bPlay = uimgr.spctoggletool('Play');
%
%      % where the argument is the name to use for the new UIMgr node

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.8.7 $ $Date: 2009/08/14 04:07:25 $

% Allow subclass to invoke this directly
h = uimgr.spctoggletool;

% This object does not support a user-specified widget function;
% the spctoggletool always instantiates an spcwidgets.uitoggletool.
h.allowWidgetFcnArg = false;

% We always create a uitoggletool widget every time we render
h.WidgetFcn = @(hThis)createSPCToggleTool(hThis);

% Continue with standard item instantiation
h.uibutton(varargin{:});

% -----------------------------
function hWidget = createSPCToggleTool(hThis)
% Create the spcwidgets.uitoggletool widget

% Setting the tag name of the uitoggletool button is not essential.
% It is done for possible future use, and to support testing.
hWidget = spcwidgets.ToggleTool(hThis.GraphicalParent,'Tag',[class(hThis), '_', hThis.name]);

% Find and set icon from appdata name, if specified
if ~isempty(hThis.iconAppData)
    set(hWidget,'Icons',uimgr.getappdata(hThis,hThis.iconAppData));
end

% [EOF]
