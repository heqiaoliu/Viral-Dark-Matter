function panel = getDialogInterface(this, manager)
%  GETDIALOGINTERFACE  Construct the dialog panel

%  Author(s): John Glass
%  Revised:
%  Copyright 2004-2005 The MathWorks, Inc.

%% Get the dialog, create it if needed.
if isempty(this.Dialog)
    this.Dialog = getDialogSchema(this);
end
panel = this.Dialog;