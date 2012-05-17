function throwEndDragEvent(hThis)

% Copyright 2005 The MathWorks, Inc.

hEvent = handle.EventData(hThis,'EndDrag');
send(hThis,'EndDrag',hEvent);