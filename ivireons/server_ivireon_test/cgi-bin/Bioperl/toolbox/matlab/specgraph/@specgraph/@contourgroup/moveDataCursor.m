function moveDataCursor(hContour,hDataCursor,dir)
% Specifies datamarker position on a bar plot behavior when user selects
% arrows keys (up,down,left,right).

% Copyright 2005 The MathWorks, Inc.

% x,y could be a vector or an mxn array
x = get(hContour,'XData');
y = get(hContour,'YData');
isvector_x = isvector(x);
isvector_y = isvector(y);
currind = hDataCursor.DataIndex;
xind = currind(1);
yind = currind(2);

% x,y is a vector, a rectangular grid
if isvector_x && isvector_y
    yLimit = length(y);
    xLimit = length(x);
    switch dir
        case 'up'
            if yind < yLimit
                hDataCursor.Position = [x(xind),y(yind+1)];
                hDataCursor.DataIndex = [xind,yind+1];
            end
        case 'down'
            if yind > 1
                hDataCursor.Position = [x(xind),y(yind-1)];
                hDataCursor.DataIndex = [xind,yind-1];
            end
        case 'left'
            if xind > 1
                hDataCursor.Position = [x(xind-1),y(yind)];
                hDataCursor.DataIndex = [xind-1,yind];
            end
        case 'right'
            if xind < xLimit
                hDataCursor.Position = [x(xind+1),y(yind)];
                hDataCursor.DataIndex = [xind+1,yind];
            end
    end
    % x or y is an array, may not be rectangular
else 
    % Handle unlikely scenario when x is a vector 
    % and y is an array or vice versa. Blow up
    % vector to an array.
    if isvector_x, x = repmat(x,size(y,1),1); end
    if isvector_y, y = repmat(y',1,size(x,1)); end
    xLimit = size(x,1);
    yLimit = size(y,2);
    switch dir
        case 'up'
            if xind < xLimit
                hDataCursor.Position = [x(xind+1,yind),y(xind+1,yind)];
                hDataCursor.DataIndex = [xind+1,yind];
            end
        case 'down'
            if xind > 1
                hDataCursor.Position = [x(xind-1,yind),y(xind-1,yind)];
                hDataCursor.DataIndex = [xind-1,yind];
            end
        case 'left'
            if yind > 1
                hDataCursor.Position = [x(xind,yind-1),y(xind,yind-1)];
                hDataCursor.DataIndex = [xind,yind-1];
            end
        case 'right'
            if yind < yLimit
                hDataCursor.Position = [x(xind,yind+1),y(xind,yind+1)];
                hDataCursor.DataIndex = [xind,yind+1];
            end
    end    
end

% Update the target point
hDataCursor.TargetPoint = hDataCursor.Position;