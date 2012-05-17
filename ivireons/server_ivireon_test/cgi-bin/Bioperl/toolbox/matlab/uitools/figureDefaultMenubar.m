function result = figureDefaultMenubar(fig)
%FIGUREDEFAULTMENUBAR Create default menus.
%
%  FIGUREDEFAULTMENUBAR(F) creates the default figure menus on figure F.
%
%  If the figure handle F is not specified, 
%  FIGUREDEFAULTMENUBAR operates on the current figure(GCF).
%
%  H = FIGUREDEFAULTMENUBAR(...) returns the handles to the new figure children.

%  Copyright 2009 The MathWorks, Inc.

result = createFigureDefaultMenubar(fig, isdeployed);