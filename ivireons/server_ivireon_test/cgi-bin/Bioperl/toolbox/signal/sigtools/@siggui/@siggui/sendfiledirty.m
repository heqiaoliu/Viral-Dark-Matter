function sendfiledirty(hObj)
%SENDFILEDIRTY Send the File Dirty notification

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/03/28 19:20:28 $

send(hObj, 'Notification', sigdatatypes.notificationeventdata(hObj, 'FileDirty'));

% [EOF]
