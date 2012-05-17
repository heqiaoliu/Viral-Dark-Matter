function placetitlebar(fig)
%PLACETITLEBAR ensures that a figure's titlebar is on screen.
%
%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:29:56 $

oldRootUnits = get(0, 'Units');
oldFigUnits = get(fig, 'Units');

set(0, 'Units', 'pixels');
set(fig, 'Units', 'pixels');
   
screenpos = get(0, 'Screensize');
outerpos = get(fig, 'Outerposition');
if outerpos(2) + outerpos(4) > screenpos(4)
    outerpos(2) = screenpos(4) - outerpos(4);
    set(fig, 'Outerposition', outerpos);
end
%restore units
set(0, 'Units', oldRootUnits);
set(fig, 'Units', oldFigUnits);