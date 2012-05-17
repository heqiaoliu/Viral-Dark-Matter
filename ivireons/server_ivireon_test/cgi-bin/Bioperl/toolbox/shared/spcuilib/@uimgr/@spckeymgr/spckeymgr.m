function h = spckeymgr(varargin)
%SPCKEYMGR Constructor for spsckeymgr object.
%   SPCKEYMGR is the object that manages the keybinding groups and
%   individual items.  It takes care of displaying the items in the
%   appropriate order when the Keybinding Help is called from the UI.
%
%   SPCKEYMGR(NAME) creates an SPCKEYMGR UIMgr object, and sets the name.
%
%   % Example:
%
%     hKeyMgr = uimgr.spckeymgr('SpcKeyMgr');
%
%   % where the argument is the name to use for the new UIMgr node

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/07/06 20:47:08 $

% Allow subclass to invoke this directly
h = uimgr.spckeymgr;

% This object does not support a user-specified widget function;
% the uitoolbar always instantiates an HG uitoolbar.
h.allowWidgetFcnArg = false;

% We always create a toolbar widget every time we render
h.WidgetFcn = @(hThis)createKeyMgr(hThis);

% Continue with standard group instantiation
h.uigroup(varargin{:});

% -----------------------------
function hWidget = createKeyMgr(hThis)
% Create

% It is done for possible future use, and to support testing.
hWidget = spcwidgets.KeyMgr(hThis.GraphicalParent);
theChild = hThis.down;
while ~isempty(theChild)
    hWidget.addGroup(theChild.hKeyGroup);
    theChild = theChild.right;
end
hWidget.install;

% [EOF]
