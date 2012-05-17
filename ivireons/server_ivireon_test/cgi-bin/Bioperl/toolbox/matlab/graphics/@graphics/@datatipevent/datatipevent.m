function hThis = datatipevent(hDatatip)
% Constructor for the datatip event.

% Copyright 2006-2010 The MathWorks, Inc.

hThis = graphics.datatipevent;
if nargin > 1
    set(hThis,'DataTipHandle',hDatatip);
    hDataCursor = hDatatip.DataCursorHandle;
end