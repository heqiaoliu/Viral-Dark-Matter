function eventObj = getEventObj(hDatatip)
% Return the event object associated with a datatip. This is a singleton of
% the datatip

% Copyright 2006 The MathWorks, Inc.

eventObj = hDatatip.EventObject;
if isempty(eventObj)
    eventObj = graphics.datatipevent(hDatatip);
    hDatatip.EventObject = eventObj;
end