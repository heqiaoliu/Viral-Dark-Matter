function sendnewspecs(hObj)
%SENDNEWSPECS Send the NewSpecs Event

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/03/28 19:10:39 $

if strcmpi(hObj.AnnounceNewSpecs, 'on'),
    send(hObj, 'NewSpecs', handle.EventData(hObj, 'NewSpecs'));
end

% [EOF]
