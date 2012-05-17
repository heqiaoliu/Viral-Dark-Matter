function hEventData = EventData(hSource, theEventName, theData)
%EventData Constructor for the custom event data object.
%   EventData(hSource,'eventName',customData) constructs an EventData
%   object that may be passed with an event that is thrown on a class.

%   Copyright 2004-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/10/18 03:22:26 $

% Call the built-in constructor which inherits its two
% arguments from the handle.EventData constructor,
% which takes a source handle and the name of an event
% that is defined by the class of the source handle.
%
hEventData = uiservices.EventData(hSource,theEventName);

if nargin>2
    hEventData.Data = theData;
end

% [EOF]
