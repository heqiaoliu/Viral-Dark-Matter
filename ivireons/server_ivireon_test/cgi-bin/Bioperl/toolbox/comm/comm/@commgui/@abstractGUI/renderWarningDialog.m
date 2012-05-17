function renderWarningDialog(this, msg, windowTitle) %#ok
%RENDERWARNINGDIALOG Render a warning dialog window.

%   @commgui/@abstractGUI
%
%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/05/12 21:23:09 $

uiwait(warndlg(msg, windowTitle, 'modal'));

%-------------------------------------------------------------------------------
% [EOF]
