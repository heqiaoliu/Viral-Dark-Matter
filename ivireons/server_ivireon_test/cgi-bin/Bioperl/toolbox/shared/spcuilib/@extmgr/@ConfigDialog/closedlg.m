function closedlg(this)
%CLOSE    Close the dialog and all contained dialogs.

%   Author(s): J. Schickler
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/04/21 21:49:09 $

% capture current position of dialog
this.DialogPosition = this.dialog.position;

% Clear handle since dialog is closing
this.Dialog = [];

cleanupSubdialogs(this);

% [EOF]
