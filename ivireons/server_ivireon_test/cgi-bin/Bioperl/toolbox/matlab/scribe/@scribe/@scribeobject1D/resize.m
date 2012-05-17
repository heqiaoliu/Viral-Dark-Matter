function resize(hThis,currPoint)
% Resize an annotation object based on the current point in pixels

% Copyright 2006 The MathWorks Inc.

% Convert the current point to the appropriate units:
hFig = ancestor(hThis,'Figure');
currPoint = hgconvertunits(hFig,[currPoint 0 0],'pixels',hThis.Units,hFig);
currPoint = currPoint(1:2);

% move the appropriate x/y values
switch hThis.MoveMode
    case 'bottomleft'
        hThis.X(1) = currPoint(1);
        hThis.Y(1) = currPoint(2);
    case 'topright'
        hThis.X(2) = currPoint(1);
        hThis.Y(2) = currPoint(2);
    otherwise
        return;
end
