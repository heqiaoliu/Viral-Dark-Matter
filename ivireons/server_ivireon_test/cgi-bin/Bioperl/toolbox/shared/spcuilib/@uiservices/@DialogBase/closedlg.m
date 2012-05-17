function closedlg(hDialogBase)  %#ok
% This method gets called when DDG dialog closes

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2006/10/18 03:22:17 $

% capture current position of dialog
hDialogBase.DialogPosition = hDialogBase.dialog.position;

% Clear handle since dialog is closing
hDialogBase.Dialog = [];

% [EOF]
