function h = uitoolbar(varargin)
%UITOOLBAR Constructor for uitoolbar object.
%   UITOOLBAR - A toolbar is a button region at the top of an HG figure 
%   window. Use "help uitoolbar" to see what the uitoolbar FUNCTION is;
%   that is the essence of what the uitoolbar class provides.
%   Above and beyond the standard uitoolbar, the e uimgr.uitoolbar class
%   can additionally contain uibutton and uibuttongroup objects
%   within it.
%
%   UITOOLBAR(NAME) creates a UITOOLBAR object and sets the object
%   name to NAME.
%
%   UITOOLBAR(NAME,PLACE,B1,B2,...) sets the name, the toolbar
%   rendering placement, and adds uibutton or uibuttongroup objects
%   B1, B2, etc.  Specifying child objects B1, B2, ..., is optional.
%
%   UITOOLBAR(NAME,B1,B2,...) and UITOOLBAR(NAME) sets the placement
%   to 0.
% 
%   % Example 1:
%  
%   hTB = uimgr.uitoolbar('Playback');
%   
%   % where the first argument is the name to use for the new UIMgr node

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2009/07/06 20:47:25 $

% Allow subclass to invoke this directly
h = uimgr.uitoolbar;

% This object does not support a user-specified widget function;
% the uitoolbar always instantiates an HG uitoolbar.
h.allowWidgetFcnArg = false;

% We always create a toolbar widget every time we render
h.WidgetFcn = @(hThis)createToolbar(hThis);

% Continue with standard group instantiation
h.uigroup(varargin{:});

% -----------------------------
function hWidget = createToolbar(hThis)
% Create the HG uitoolbar widget

% Setting the tag name of the toolbar is not essential.
% It is done for possible future use, and to support testing.
hWidget = uitoolbar(hThis.GraphicalParent,'tag',[class(hThis), '_', hThis.name]);

% [EOF]
