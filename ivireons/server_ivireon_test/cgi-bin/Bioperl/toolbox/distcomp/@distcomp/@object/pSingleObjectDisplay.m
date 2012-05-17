function pSingleObjectDisplay(obj)
; %#ok Undocumented
%  This function is called for displaying all single
% distcomp objects. Its counterpart is pDefaultVectorObjDisplay which must be
% overwritten for vectorized tasks. It relies on each individual object
% (because of lack of super in UDD)to return the data which is formated 
% here and displays. The format strings define the spacing and delimiter
% field for property displays of each object spanning the tree. This
% function is user visible BUT should not be used by customers.

% Copyright 2006 The MathWorks, Inc.

% $Revision: 1.1.6.2 $  $Date: 2008/02/02 13:00:39 $

mainHeaderFormat = '%s\n%s\n\n'; % notice this takes 2 arguments 
subHeaderFormat = '\n- %s\n\n';
% NOTE - we assume that the property name has a max length of 26 chars - if
% this is exceeded then unexpected wrap around will occur
itemsFormat = '%26s : %s\n';
displayStruct = struct('Header', '', 'Type', '', 'Names', '', 'Values', '');

displayItemsCellArray = obj.pGetDisplayItems(displayStruct);
% myDisplayItems: A top level structure holding the header and the
% properties to be displayed. Two cell arrays of strings are included plus
% a header. myDisplayItems.Names (cell array of string names) and like wise
% myDisplayItems.Values stores a cell array string values. The Names and
% Values feilds must be of the same length as they should hold two name and
% property value pair. 

postfixMainHeader = ' Information';
% gets all the display item structs from the vardisplayargoutput cell array
for i = 1:numel(displayItemsCellArray)  
    myDisplayItem = displayItemsCellArray{i};
    % i = 1 is the main header  
    if i == 1  
        mainHeader = [myDisplayItem.Header postfixMainHeader];
        numchar = numel(mainHeader);
        % display main header with underline
        fprintf(mainHeaderFormat, mainHeader, repmat( '=', 1, numchar )); 
    elseif ~isempty(myDisplayItem.Header)
        fprintf(subHeaderFormat, myDisplayItem.Header);
    end

    obj.pDispArgs(itemsFormat, myDisplayItem);

end
