function DialogPanel = getDialogInterface(this, manager)
%  GETDIALOGINTERFACE  Construct the dialog panel

%  Author(s): John Glass
%  Revised:
%  Copyright 2003-2005 The MathWorks, Inc.
% $Revision: 1.1.10.1 $ $Date: 2007/02/06 20:02:33 $

DialogPanel = this.getDialogSchema;
this.Dialog = DialogPanel;