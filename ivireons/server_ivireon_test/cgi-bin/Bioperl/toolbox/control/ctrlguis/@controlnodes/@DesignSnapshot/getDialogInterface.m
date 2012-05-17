function panel = getDialogInterface(this, manager)
%   GETDIALOGINTERFACE  Construct the dialog panel

%   Author(s): John Glass
%   Revised:
%   Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2005/11/15 00:45:36 $

%% Get the dialog, create it if needed.
if isempty(this.Dialog)
    this.Dialog = getDialogSchema(this);
end
panel = this.Dialog;