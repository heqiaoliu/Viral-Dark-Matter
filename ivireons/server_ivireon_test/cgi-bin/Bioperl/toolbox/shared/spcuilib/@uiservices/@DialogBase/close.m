function close(hDialogBase)
%CLOSE Manually close the dialog.
%   CLOSE(H) closes the dialog, if open.
%
%   Note that managed DialogBase dialogs will automatically close when the
%   event 'CloseDialogsEvent' is sent via the client application handle.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2007/03/13 19:48:33 $

% This action will execute closedlg to record dialog position, etc.
delete(hDialogBase.dialog);

% [EOF]
