function sendstatus(hObj, str)
%SENDSTATUS Send a status from the object
%   SENDSTATUS(H, STR) Send the StatusChanged Notification using STR as the 
%   new status.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2007/12/14 15:19:46 $

error(nargchk(2,2,nargin,'struct'));

statusinfo.StatusString = str;

send(hObj, 'Notification', ...
    sigdatatypes.notificationeventdata(hObj, 'StatusChanged', statusinfo));

% [EOF]
