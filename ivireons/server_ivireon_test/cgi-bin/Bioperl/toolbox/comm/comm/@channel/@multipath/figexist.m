function exists = figexist(h)
%FIGEXIST  Determine whether multipath channel figure exists.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/10 19:20:50 $

exists = ~isempty(h.MultipathFigure.FigureHandle);


