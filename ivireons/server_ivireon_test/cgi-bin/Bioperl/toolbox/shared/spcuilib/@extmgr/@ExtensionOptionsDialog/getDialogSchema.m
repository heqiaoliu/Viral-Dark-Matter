function dlg = getDialogSchema(this, dummy) %#ok
%GETDIALOGSCHEMA Get the dialog information.

%   Author(s): J. Schickler
%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2010/03/08 21:43:46 $

dlg = this.StdDlgProps;

% Get the dialog information from the extension.  We recommend that
% extension author's write their getPropsSchema with Mode=false for their
% widgets.  However, we are not going to force this spec, because there may
% be widget dependencies that require Mode=true and DialogRefresh=true.
dlg.Items = {feval(this.Register, 'getPropsSchema', this.Config, this.Dialog)};

% Remove the help menu item.
dlg.StandaloneButtonSet = {'OK', 'Cancel', 'Apply'};
dlg.PostApplyMethod     = 'postApply';
dlg.DialogTag           = [this.Register.getFullName 'Options'];

% [EOF]
