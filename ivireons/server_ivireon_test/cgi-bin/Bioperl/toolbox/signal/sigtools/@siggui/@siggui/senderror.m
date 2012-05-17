function senderror(hObj, lid, lstr)
%SENDERROR Send an error from the object
%   SENDERROR(H, ERRSTR) Send an ErrorOccurred Notification using ERRSTR as
%   the error.
%
%   SENDERROR(H, ERRID, ERRSTR) Send an ErrorOccurred Notification using
%   ERRID as the error identifier.
%
%   SENDERROR(H) Send an ErrorOccurred Notification using LASTERR as the error
%   and error identifier.

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2008/04/21 16:31:46 $

error(nargchk(1,3,nargin,'struct'));

switch nargin

case 2
    lstr = lid;
    lid = '';
end

if isempty(lstr) & isempty(lid), return; end

errinfo.ErrorString = lstr;
errinfo.ErrorID = lid;

send(hObj, 'Notification', ...
    sigdatatypes.notificationeventdata(hObj, 'ErrorOccurred', errinfo));

% [EOF]
