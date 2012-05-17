function cbs = helpdialog_cbs(hDlg)
%DIALOG_CBS Callbacks for the dialog buttons

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/14 23:29:11 $

% This can be a private method

% In R13 this function can be renamed dialog_cbs and replaced with:
% cbs      = super::dialog_cbs(hDlg);
% cbs.help = @help_cb;

cbs      = dialog_cbs(hDlg);
cbs.help = {cbs.method, hDlg, @help};

% [EOF]
