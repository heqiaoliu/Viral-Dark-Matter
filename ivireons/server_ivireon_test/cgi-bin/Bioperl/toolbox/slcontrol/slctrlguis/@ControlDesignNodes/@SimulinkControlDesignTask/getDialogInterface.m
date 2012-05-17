function panel = getDialogInterface(this, manager)
% GETDIALOGINTERFACE

% Author(s): John Glass
% Revised: 
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2007/05/18 05:59:49 $

% Determine if the model is open
ensureOpenModel(slcontrol.Utilities,this.Model)

if isempty(this.Dialog)
    this.Dialog = getDialogSchema(this);
end

% Update the model with the settings
setlinio(this.Model,this.IOData);

panel = this.Dialog;
