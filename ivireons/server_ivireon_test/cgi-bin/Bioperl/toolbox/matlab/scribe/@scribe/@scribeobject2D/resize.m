function resize(hThis,currPoint)
% Resize an annotation object based on the current point in pixels

% Copyright 2006 The MathWorks Inc.

% Since the "MoveMode" property changes while resizing, we must monitor the
% position of the four corners at all times. All work will be done in pixel
% coordinate space.
hFig = ancestor(hThis,'Figure');
pos = hgconvertunits(hFig,hThis.Position,hThis.Units,'pixels',hFig);
XL = pos(1);
XR = pos(1)+pos(3);
YU = pos(2)+pos(4);
YL = pos(2);

% First, find out if we need to change the mode mode. This is determined
% when we pass other affordances while dragging
switch hThis.MoveMode
    case 'topleft'
        if currPoint(1)>XR
            if currPoint(2)<YL
                hThis.MoveMode = 'bottomright';
                XL = XR;
                YU = YL;
            else
                hThis.MoveMode = 'topright';
                XL = XR;
            end
        elseif currPoint(2)<YL
            hThis.MoveMode = 'bottomleft';
            YU = YL;
        end
    case 'topright'
        if currPoint(1)<XL
            if currPoint(2)<YL
                hThis.MoveMode = 'bottomleft';
                XR = XL;
                YU = YL;
            else
                hThis.MoveMode = 'topleft';
                XR = XL;
            end
        elseif currPoint(2)<YL
            hThis.MoveMode = 'bottomright';
            YU = YL;
        end
    case 'bottomright'
        if currPoint(1)<XL
            if currPoint(2)>YU
                hThis.MoveMode = 'topleft';
                XR = XL;
                YL = YU;
            else
                hThis.MoveMode = 'bottomleft';
                XR = XL;
            end
        elseif currPoint(2)>YU
            hThis.MoveMode = 'topright';
            YL = YU;
        end
    case 'bottomleft';
        if currPoint(1)>XR
            if currPoint(2)>YU
                hThis.MoveMode = 'topright';
                XL = XR;
                YL = YU;
            else
                hThis.MoveMode = 'bottomright';
                XL = XR;
            end
        elseif currPoint(2)>YU
            hThis.MoveMode = 'topleft';
            YL = YU;
        end
    case 'left'
        if currPoint(1)>XR
            hThis.MoveMode = 'right';
            XL = XR;
        end
    case 'top'
        if currPoint(2)<YL
            hThis.MoveMode = 'bottom';
            YU = YL;
        end
    case 'right'
        if currPoint(1)<XL
            hThis.MoveMode = 'left';
            XR = XL;
        end
    case 'bottom'
        if currPoint(2)>YU
            hThis.MoveMode = 'top';
            YL = YU;
        end
    otherwise
end

% Given the updated move mode, now update the position rectangle:
switch hThis.MoveMode
 case 'topleft'
  % e.g. moving the upper left affordance
  % changes the left x and upper y
  XL = currPoint(1);
  YU = currPoint(2);
 case 'topright'
  XR = currPoint(1);
  YU = currPoint(2);
 case 'bottomright'
  XR = currPoint(1);
  YL = currPoint(2);
 case 'bottomleft';
  XL = currPoint(1);
  YL = currPoint(2);
 case 'left'
  XL = currPoint(1);
 case 'top'
  YU = currPoint(2);
 case 'right'
  XR = currPoint(1);
 case 'bottom'
  YL = currPoint(2);
 otherwise
  return;
end

% Given the updated coordinates, create the new position rectangle:
newPos = [XL YL XR-XL YU-YL];
% Convert into the units of the annotation:
hThis.Position = hgconvertunits(hFig,newPos,'pixels',hThis.Units,hFig);