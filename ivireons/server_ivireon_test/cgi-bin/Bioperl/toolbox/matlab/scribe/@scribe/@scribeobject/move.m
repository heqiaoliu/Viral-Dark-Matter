function move(hThis,delta)
% Moves a scribe object by the specified delta.

% Copyright 2006 The MathWorks Inc.

% First, convert the units of the delta:
hFig = ancestor(hThis,'figure');
pixPos = hgconvertunits(hFig,hThis.Position,hThis.Units,'pixels',hFig);
pixPos(1:2) = pixPos(1:2) + delta;

% Update the position rectangle of the object:
hThis.Position = hgconvertunits(hFig,pixPos,'pixels',hThis.Units,hFig);