function [iPoints, aObj] = selectpoints(aObj, X,Y, pointX, pointY)
%EDITLINE/SELECTPOINTS Select points for editline object
%   This file is an internal helper function for plot annotation.

%   pick points to move for dragging.

%   Copyright 1984-2005 The MathWorks, Inc. 
%   $Revision: 1.8.4.2 $  $Date: 2005/09/12 18:58:25 $


% get nearest points
dx = X-pointX;
dy = Y-pointY;

dm = abs(dx)+abs(dy);

[sortedList, indices] = sort(dm);

if sortedList(1) < 0.02
   iPoints = indices(1);
else
   iPoints = indices;
end
