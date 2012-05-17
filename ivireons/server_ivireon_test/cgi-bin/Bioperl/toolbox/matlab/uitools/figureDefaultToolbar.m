function result = figureDefaultToolbar(fig)
%FIGUREDEFAULTTOOLBAR Create default toolbar.
%
%  FIGUREDEFAULTTOOLBAR(F) creates the default figure toolbar on figure F.
%
%  If the figure handle F is not specified, 
%  FIGUREDEFAULTTOOLBAR operates on the current figure(GCF).
%
%  H = FIGUREDEFAULTTOOLBAR(...) returns the handle to the new figure child.

%  Copyright 2009 The MathWorks, Inc.

result = createFigureDefaultToolbar(fig, isdeployed);
