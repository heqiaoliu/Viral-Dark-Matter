function throwBeginDragEvent(hThis)

% Copyright 2005 The MathWorks, Inc.

hEvent = handle.EventData(hThis,'BeginDrag');
send(hThis,'BeginDrag',hEvent);