function updatePositionFromPin(hThis,hPin)
% Update the position of the scribe object from the pin position

%   Copyright 2006 The MathWorks, Inc.

%Get the scribe axis and the side (start/end) of the 1-D object being
%updated
scribeax = hThis.Parent;
if ~isempty(hPin) && ishandle(hPin)
    n = hPin.Affordance;
    %Get the position of the scribeaxis (in pixels) & the pixelbounds of the
    %pin wrt the figure(or the scribe axis)
    fig = ancestor(scribeax, 'figure');
    ppos = hgconvertunits(fig, get(scribeax,'Position'),...
        get(scribeax,'Units'), 'pixels', fig);
    %Find the pixel position of the data point that the pin represents
    pixelbounds = hPin.topixels();

    %Get the normalized X & Y position of the pin's location relative to
    %the scribe axis
    newPos = pixelbounds ./ ppos(3:4);
    newPos(2) = 1-newPos(2);
    
    %Set the positin of the scribe object in its own units
    newPos = hgconvertunits(fig,[newPos 0 0],'normalized',hThis.Units,fig);
    newPos = newPos(1:2);
    hThis.X(n) = newPos(1);
    hThis.Y(n) = newPos(2);
end