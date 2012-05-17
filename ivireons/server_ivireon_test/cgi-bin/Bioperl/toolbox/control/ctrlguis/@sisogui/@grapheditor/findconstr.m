function Constraints = findconstr(Editor)
%

%FINDCONSTR   Finds all active design constraints objects attached to an Editor.

%   Copyright 1986-2008 The MathWorks, Inc. 
%   $Revision: 1.2.4.2 $  $Date: 2008/05/31 23:16:09 $

Constraints = plotconstr.findConstrOnAxis(Editor.Axes.getaxes);

