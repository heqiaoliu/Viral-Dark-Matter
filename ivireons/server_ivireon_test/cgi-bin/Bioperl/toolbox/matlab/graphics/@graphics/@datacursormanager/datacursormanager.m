function [hThis] = datacursormanager(hFig)

% Copyright 2003-2004 The MathWorks, Inc.

hFig = handle(hFig);

hThis = graphics.datacursormanager;
set(hThis,'Figure',hFig);



