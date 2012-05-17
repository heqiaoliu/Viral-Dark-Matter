function s = getCopyStructureFromObject(hObj)
% This function is undocumented and will be changed in a future relase.

%   Copyright 2009 The MathWorks, Inc.

% Returns a structure containing data to be used by scribe cut/copy/paste.

% For each object, serialize it appropriately:
for i=numel(hObj):-1:1
    s(i).ObjData = getByteStreamFromArray(hObj(i));
    % Make sure to include the context menu:
    s(i).UIContextMenuData = getByteStreamFromArray(get(hObj(i),'UIContextMenu'));
end