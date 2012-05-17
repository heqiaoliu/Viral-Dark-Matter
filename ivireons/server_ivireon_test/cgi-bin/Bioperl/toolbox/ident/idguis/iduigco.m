function object = iduigco(figure)
%IDUIGCO    Handle of current object.
%   OBJECT = GCO returns the current object in
%   the current figure.
%
%   OBJECT = GCO(FIGURE) returns the current object
%   in figure FIGURE.
%
%   The current object for a given figure is the last
%   object clicked on with the mouse.


%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $  $Date: 2006/06/20 20:08:43 $

if isempty (allchild(0)),
    object = [];
    return;
end;

if(nargin == 0)
    figure = get(0,'CurrentFigure');
end

object = get( figure, 'CurrentObject');