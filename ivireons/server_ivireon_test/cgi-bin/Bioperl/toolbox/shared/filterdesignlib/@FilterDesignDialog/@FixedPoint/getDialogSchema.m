function dlg = getDialogSchema(this, dummy)
%GETDIALOGSCHEMA   Get the dialog information.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/06/11 17:22:49 $

items = getDialogSchemaStruct(this);

dlg.DialogTitle = 'Data types';
dlg.Items = {items};

% [EOF]
