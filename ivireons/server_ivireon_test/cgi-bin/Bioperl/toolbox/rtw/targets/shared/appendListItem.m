function [addedItem, newItemList] = appendListItem(itemList, ...
                                      item, ...
                                      searchString, ...
                                      delimChar, ...
                                      placement)
%APPENDITEM Append an ITEM to the end of a list represented as a string
%   APPENDITEM Append an ITEM to the end of a list represented as a string if
%   SEARCHSTRING is not already in the list. Each item is separated by
%   DELIMCHAR
%
%   ITEMLIST is a string representing a list of ITEM's 
%   ITEM is an ITEM you want to add to the list ITEMLIST
%   SEARCHSTRING the item we want to look for in ITEMLIST
%   DELIMCHAR the separator character which separates each ITEM in ITEMLIST

%   Copyright 1990-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/08/23 19:11:56 $

% See if the original itemList contains the searchString
matches = strfind(itemList, searchString);
if isempty(matches)

  % Don't overwrite the original itemList
  % Append to the end
  if isempty(itemList)
    newItemList = [item delimChar];
  else
    switch placement
      case 'end'
        if itemList(length(itemList)) == delimChar
          % No need for preceding delimiter
          newItemList = [itemList item delimChar];
        else
          % Add preceding delimiter
          newItemList = [itemList delimChar item delimChar];
        end
      case 'beginning'
        if itemList(1) == delimChar
          % itemList = (delimChar item)*
          % There is already a delimChar between item and the first item in itemList
          newItemList = [item itemList];
        else
          % itemList = (item delimChar)*
          % There is no delimChar between item and the first item in itemList
          newItemList = [item delimChar itemList];
        end
    end
  end
  addedItem = true;
else
  newItemList = itemList;
  addedItem = false;
end
