function moveDataCursor(hStair,hDataCursor,dir)
% Specifies datamarker position on a stair plot behavior when user selects 
% arrows keys (up,down,left,right).

% Copyright 2005 The MathWorks, Inc.

currind = hDataCursor.DataIndex;
currindOrig = currind;
hAxes = ancestor(hStair,'hg.axes');

xdata = get(hStair,'xdata');
ydata = get(hStair,'ydata');
len = length(xdata);
if strcmp(dir,'up') | strcmp(dir,'right')
    if currind < len
        currind = currind + 1;
    end
    currLine = [xdata(currind);ydata(currind)];
    % Deal with NaN and Inf points
    while currind < len && any(~isfinite(currLine))
        currind = currind + 1;
        currLine = [xdata(currind);ydata(currind)];
    end
    % Edge case: NaNs and Infs to the end
    if currind == len && any(~isfinite(currLine))
        currind = currindOrig;
    end    
else
    % On a stair plot, only odd data vertices represent actual data.
    if currind > 1
        currind = currind - 1;
    end
    currLine = [xdata(currind);ydata(currind)];
    % Deal with NaN and Info points
    while currind > 1 && any(~isfinite(currLine))
        currind = currind - 1;
        currLine = [xdata(currind);ydata(currind)];
    end
    % Edge case: NaNs and Infs to the end
    if currind == 1 && any(~isfinite(currLine))
        currind = currindOrig;
    end    
end
  
% Update vertex position
hDataCursor.DataIndex = currind;
hDataCursor.Position = [xdata(currind),ydata(currind)];
hDataCursor.TargetPoint = [xdata(currind),ydata(currind)];