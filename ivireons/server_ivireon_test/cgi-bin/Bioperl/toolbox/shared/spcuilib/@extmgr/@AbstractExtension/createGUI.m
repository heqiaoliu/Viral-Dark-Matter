function hinstall = createGUI(this)  %#ok
%CREATEGUI Virtual method in base class.
%   CREATEGUI(H) returns a uimgr.uiinstaller object used by INSTALLGUI.
%   This method returns an [] by default, which indicates to INSTALLGUI
%   that there are no GUI components for the extension.

% Copyright 2006-2007 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2007/03/13 19:45:17 $

% This is an interface method; overload in subclass when needed.

hinstall = [];  % uimgr.uiinstaller;  % zero entries

% [EOF]
