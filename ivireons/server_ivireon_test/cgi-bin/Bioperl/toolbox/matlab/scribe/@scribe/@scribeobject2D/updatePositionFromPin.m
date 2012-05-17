function updatePositionFromPin(hThis,hPin)
% Update the position of the scribe object from the pin position

%   Copyright 2006 The MathWorks, Inc.

scribeax = hThis.Parent;
if ~isempty(hPin) && ishandle(hPin)
    n = hPin.Affordance;
    fig = ancestor(scribeax,'figure');
    pixPos = hPin.topixels;
    hAff = hThis.Srect(n);
    %Offset the pin's position relative to the scribe object
    posRect = hgconvertunits(fig, get(hThis, 'Position'), get(hThis,'Units'), 'pixels', fig);
    figRect = hgconvertunits(fig, get(fig,'Position'), get(fig,'Units'),'pixels',0);
    pixPos(2) = figRect(4) - pixPos(2);
    % Since the pin is attached to an affordance, its position has a direct
    % mapping to the updated position rectangle of the shape.
    switch get(hAff,'Tag')
        case 'topleft'
            posRect(1) = pixPos(1);
            posRect(2) = pixPos(2) - posRect(4);
        case 'topright'
            posRect(1) = pixPos(1) - posRect(3);
            posRect(2) = pixPos(2) - posRect(4);
        case 'bottomright'
            posRect(1) = pixPos(1) - posRect(3);
            posRect(2) = pixPos(2);
        case 'bottomleft'
            posRect(1) = pixPos(1);
            posRect(2) = pixPos(2);
        case 'left'
            posRect(1) = pixPos(1);
            posRect(2) = pixPos(2) - posRect(4)/2;
        case 'top'
            posRect(1) = pixPos(1) - posRect(3)/2;
            posRect(2) = pixPos(2) - posRect(4);
        case 'right'
            posRect(1) = pixPos(1) - posRect(3);
            posRect(2) = pixPos(2) - posRect(4)/2;
        case 'bottom'
            posRect(1) = pixPos(1) - posRect(3)/2;
            posRect(2) = pixPos(2);
        case 'center'
            posRect(1) = pixPos(1) - posRect(3)/2;
            posRect(2) = pixPos(2) - posRect(4)/2;
    end
    %Set the positin of the scribe object in its own units
    pos = hgconvertunits(fig, posRect, 'pixels', get(hThis,'Units'), fig);
    set(hThis,'Position',pos);
end