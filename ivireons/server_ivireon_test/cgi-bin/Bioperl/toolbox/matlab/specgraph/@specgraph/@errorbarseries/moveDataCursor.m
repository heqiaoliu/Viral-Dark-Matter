function moveDataCursor(hError,hDataCursor,dir)
% Specifies datamarker position on an errorbar plot behavior when user selects 
% arrows keys (up,down,left,right).

% Copyright 2005 The MathWorks, Inc.

ch = get(hError,'children');
moveDataCursor(hDataCursor,handle(ch(1)),hDataCursor,dir);