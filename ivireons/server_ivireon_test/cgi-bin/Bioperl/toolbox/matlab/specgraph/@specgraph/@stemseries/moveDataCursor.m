function moveDataCursor(hStem,hDataCursor,dir)
% Specifies datamarker position on a stem plot behavior when user selects 
% arrows keys (up,down,left,right).

% Copyright 2005 The MathWorks, Inc.

hMarker = get(hStem,'MarkerHandle');
moveDataCursor(hDataCursor,hMarker,hDataCursor,dir);