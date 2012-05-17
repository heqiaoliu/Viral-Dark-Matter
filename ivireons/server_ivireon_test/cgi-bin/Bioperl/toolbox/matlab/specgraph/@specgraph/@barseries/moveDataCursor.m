function moveDataCursor(hBar,hDataCursor,dir)
% Specifies datamarker position on a bar plot behavior when user selects
% arrows keys (up,down,left,right).

% Copyright 2005-2006 The MathWorks, Inc.

currind = hDataCursor.DataIndex;
currindOrig = currind;
hAxes = ancestor(hBar,'hg.axes');
xdata = get(hBar,'xdata');
ydata = get(hBar,'ydata');
len = length(xdata);
if strcmp(dir,'up') | strcmp(dir,'right')
    if currind < len
        currind = currind + 1;
    end
else
    if currind > 1
        currind = currind - 1;
    end
end

% Update vertex position
hDataCursor.DataIndex = currind;
currLine = [xdata(currind);ydata(currind)];

% Check for stacked mode:
hPeers = get(hBar,'BarPeers');
if strcmp(hBar.BarLayout,'stacked')
    currLine(~isfinite(currLine)) = 0;
    ind = find(hPeers == hBar);
    %The bar is going to be stacked on top of its peers.
    if ind ~= 2
        belYDat = cell2mat(get(hPeers(ind-1:-1:1),'YData'));
    else
        belYDat = get(hPeers(1),'YData');
    end
    if ~isempty(belYDat)
        colInt = belYDat(:,currind);
        currLine(2) = currLine(2) + sum(colInt(isfinite(colInt)));
    end
    % Check for horizontal mode
    if strcmp(hBar.Horizontal,'on')
        temp = currLine(1);
        currLine(1) = currLine(2);
        currLine(2) = temp;
    end
    hDataCursor.Position = currLine';
elseif numel(hPeers)~=1
    %Grouped mode:
    % Check for horizontal mode
    if strcmp(hBar.Horizontal,'on')
        temp = currLine(1);
        currLine(1) = currLine(2);
        currLine(2) = temp;
        offSet = xdata(currindOrig)-hDataCursor.Position(2);
        currLine(2) = currLine(2) - offSet;
        currLine(~isfinite(currLine)) = 0;
    else
        %Find offset from center:
        offSet = xdata(currindOrig)-hDataCursor.Position(1);
        currLine(1) = currLine(1) - offSet;
        currLine(~isfinite(currLine)) = 0;
    end
    hDataCursor.Position = currLine';
else
    currLine(~isfinite(currLine)) = 0;
    % Check for horizontal mode
    if strcmp(hBar.Horizontal,'on')
        temp = currLine(1);
        currLine(1) = currLine(2);
        currLine(2) = temp;
    end
    hDataCursor.Position = currLine';
end

% Update the target point
pos = hDataCursor.Position;
set(hDataCursor,'TargetPoint',[pos(1) pos(2)]);