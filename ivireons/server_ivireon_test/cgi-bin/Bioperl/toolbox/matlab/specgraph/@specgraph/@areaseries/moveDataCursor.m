function moveDataCursor(hArea,hDataCursor,dir)
% Specifies datamarker position on an area plot behavior when user selects 
% arrows keys (up,down,left,right).

% Copyright 2005-2006 The MathWorks, Inc.

ind = hDataCursor.DataIndex;
hPatch = handle(get(hArea,'Children'));
if strcmpi(dir,'up') || strcmpi(dir,'right')
    ind = ind+1;
    if ind <= length(hArea.XData)
        hDataCursor.DataIndex = ind;
        pos = [hPatch.XData(ind+1);hPatch.YData(ind+1)];
        hDataCursor.Position = pos;
        hDataCursor.TargetPoint = pos.';
    end
else
    ind = ind-1;
    if ind >= 1
        hDataCursor.DataIndex = ind;
        pos = [hPatch.XData(ind+1);hPatch.YData(ind+1)];
        hDataCursor.Position = pos;
        hDataCursor.TargetPoint = pos.';
    end
end