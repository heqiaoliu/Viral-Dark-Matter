function sendwarning(hObj, wid, wstr)
%SENDWARNING Send a warning from the object
%   SENDWARNING(H, WARNSTR) Send a WarningOccurred Notification using WARNSTR as
%   the warning.
%
%   SENDWARNING(H, WARNID, WARNSTR) Send a WarningOccurred Notification using
%   WARNID as the warning identifier.
%
%   SENDWARNING(H) Send a WarningOccurred Notificatio using LASTWARN for the
%   warning and the warning identifier.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2010/03/26 17:51:41 $

error(nargchk(1,3,nargin,'struct'));

switch nargin
case 1
    [wstr wid] = lastwarn;
    lastwarn('');
    
    % Ignore this dispatcher warning.
    if strcmp(wid, 'MATLAB:dispatcher:pathWarning')
        return;
    end
case 2
    wstr = wid;
    wid = [];
end

if isempty(wstr) && isempty(wid)
    return;
end

warninfo.WarningString = wstr;
warninfo.WarningID     = wid;

send(hObj, 'Notification', ...
    sigdatatypes.notificationeventdata(hObj, 'WarningOccurred', warninfo));

% [EOF]
