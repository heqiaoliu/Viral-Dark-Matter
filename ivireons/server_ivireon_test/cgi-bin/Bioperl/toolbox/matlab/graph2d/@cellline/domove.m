function aObj = domove(aObj, pointX, pointY, refresh)
%CELLLINE/DOMOVE Move cellline object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2005 The MathWorks, Inc. 
%   $Revision: 1.8.4.2 $  $Date: 2005/09/12 18:58:20 $

savedState = get(aObj, 'SavedState');

lowerChild = aObj.LowerChild;
upperChild = aObj.UpperChild;

switch get(aObj,'DragConstraint')
% case ''
case 'fixX'
   minY = get(lowerChild,'MinY') + get(lowerChild,'MinWidth');
   maxY = get(upperChild,'MaxY') - get(upperChild,'MinWidth');
   newY = pointY - savedState.OffsetY;
   newY = max(newY, minY);
   newY = min(newY, maxY);
   aObj = set(aObj,'YData', [newY newY]);
   set(lowerChild, 'MaxY', newY);
   set(upperChild, 'MinY', newY);
case 'fixY'
   minX = get(lowerChild,'MinX') + get(lowerChild,'MinWidth');
   maxX = get(upperChild,'MaxX') - get(upperChild,'MinWidth');
   newX = pointX - savedState.OffsetX;
   newX = max(newX, minX);
   newX = min(newX, maxX);
   aObj = set(aObj,'XData', [newX newX]);
   set(lowerChild, 'MaxX', newX);
   set(upperChild, 'MinX', newX);
end

