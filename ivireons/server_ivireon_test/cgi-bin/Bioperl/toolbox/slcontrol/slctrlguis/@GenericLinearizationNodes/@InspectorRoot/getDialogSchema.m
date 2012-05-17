function DialogPanel = getDialogSchema(this, manager)
%  GETDIALOGSCHEMA  Construct the dialog panel

%  Author(s): John Glass
%  Revised:
%  Copyright 2003-2005 The MathWorks, Inc.
% $Revision: 1.1.10.2 $ $Date: 2008/03/13 17:39:56 $

% Get the handle to the dialog panel
DialogPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel');