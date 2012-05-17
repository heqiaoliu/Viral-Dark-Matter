function A = doclick(A)
%FRAMERECT/DOCLICK Click method for framerect object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2009 The MathWorks, Inc. 
%   $Revision: 1.7.4.2 $  $Date: 2009/06/22 14:33:49 $

figH = get(A,'Figure');
figObjH = getobj(figH);
selType = figObjH.SelectionType;

selected = get(A,'IsSelected');

switch selType
case 'open' % do a double click: edit properties.
case 'normal'
   dragBinH = figObjH.DragObjects;
   for aObjH = dragBinH.Items;
      set(aObjH,'IsSelected',0);
   end
   A = set(A,'IsSelected',1);
end
