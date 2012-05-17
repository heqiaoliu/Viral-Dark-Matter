function this = EventData(hSrc, eventName, eventData)
%EVENTDATA Construct an EVENTDATA object
%   OUT = EVENTDATA(ARGS) <long description>

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/11/19 21:43:46 $

this = spcuddutils.EventData(hSrc, eventName);

set(this, 'Data', eventData);

% [EOF]
