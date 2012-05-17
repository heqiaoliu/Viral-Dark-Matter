function h = uibuttongroup(varargin)
%UIBUTTONGROUP Constructor for uibuttongroup object.
%   UIBUTTONGROUP(NAME,PLACE,B1,B2,...) sets the group name, the
%   button group rendering placement, and adds uibutton objects
%   B1, B2, etc.  Specifying uibutton objects is optional.
%
%   UIBUTTONGROUP(NAME,B1,B2,...) and UIBUTTONGROUP(NAME) sets
%   placement to 0.
%
%   A uibuttongroup is a named button region, within a toolbar,
%   at the top of an HG figure window.
%
%   Unlike the standard uitoolbar, the uibuttongroup allows definition of
%   named groups of buttons, and an order to those named groups.
%
%   % Example 1:
%     hBG =  uimgr.uibuttongroup('Sources');
%
%   % where the argument is the name to use for the new UIMgr node
%
%   % Example 2:
%
%     hButton = uimgr.uipushtool('Button1');
%     hButtonGroup = uimgr.uibuttongroup('ButtonGroup1', hButton);
%
%   % where the first argument is the name to use for the new UIMgr node
%   % and the second argument is the handle to the previously created button
%   % hButton

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2009/07/06 20:47:14 $

% Allow subclass to invoke this directly
h = uimgr.uibuttongroup;

% This object does not support a user-specified widget function;
% the uibuttongroup simply confirms that a toolbar is present,
% and contains other uibutton/uibuttongroup objects.
h.allowWidgetFcnArg = false;

% Continue with standard group instantiation
h.uigroup(varargin{:});

% [EOF]
