function closeDialog(dp,dlg)
% Close a dialog in the DPVerticalPanel

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:39:34 $

% Close the dialog by resetting its visibility
setDialogVisibility(dp,dlg,false);
disableRollerShadeIfAvailable(dlg);
