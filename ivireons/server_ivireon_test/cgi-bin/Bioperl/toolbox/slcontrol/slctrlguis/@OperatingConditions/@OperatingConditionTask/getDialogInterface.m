function panel = getDialogInterface(this, manager)
% GETDIALOGINTERFACE  Enter a description here!
%
 
% Author(s): John W. Glass 26-Oct-2007
% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2007/12/14 15:28:20 $

% Make sure the model and its references are open
ensureOpenModel(slcontrol.Utilities,this.Model)

if isempty(this.Dialog)
    this.Dialog = getDialogSchema(this);
end
panel = this.Dialog;

% Make sure that the annotations for output specification are updated in
% the model.
pushOutputSpecToModel(this) 