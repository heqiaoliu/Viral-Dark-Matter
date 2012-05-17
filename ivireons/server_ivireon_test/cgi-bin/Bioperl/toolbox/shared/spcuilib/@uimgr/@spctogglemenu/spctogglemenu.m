function h = spctogglemenu(varargin)
%SPCTOGGLEMENU Constructor for uitogglemenu object.
%   SPCTOGGLEMENU(NAME,PLACE) creates an SPCWIDGETS.UIMENUTOGGLE
%   UIMgr object, sets the name, and the button rendering placement.
%
%   SPCTOGGLEMENU(NAME) sets the placement to 0.
%
%   % Example:
%
%       hOpen = uimgr.spctogglemenu('OpenAtMdlStart', 0, ...
%       'Open at Start of Simulation');
%
%   % where the first argument is the name to use for the new UIMgr node, 
%   % the second argument is the placement in the group it will be placed 
%   % in and the third argument is the string to display on the rendered 
%   % item.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2009/08/14 04:07:24 $

% Allow subclass to invoke this directly
h = uimgr.spctogglemenu;

% This object does not support a user-specified widget function;
% the uitogglemenu always instantiates an spcwidgets.UIToggleMenu.
h.allowWidgetFcnArg = false;

% We always create a uipushtool widget every time we render
h.WidgetFcn = @(hThis)createSPCMenuToggle(hThis);

% Continue with standard item instantiation
h.uimenu(varargin{:});

% -----------------------------
function hWidget = createSPCMenuToggle(hThis)
% Create the spcwidgets.uimenutoggle widget

% Setting the tag name of the menu is not essential.
% It is done for possible future use, and to support testing.
hWidget = spcwidgets.ToggleMenu(hThis.GraphicalParent,'Tag', [class(hThis), '_', hThis.name]);

% [EOF]
