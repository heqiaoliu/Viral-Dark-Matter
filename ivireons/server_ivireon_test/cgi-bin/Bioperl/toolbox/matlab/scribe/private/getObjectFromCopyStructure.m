function hObj = getObjectFromCopyStructure(s)
% This function is undocumented and will be changed in a future relase.

%   Copyright 2009 The MathWorks, Inc.

% Returns a structure containing data to be used by scribe cut/copy/paste.

% For each structure, deserialize it appropriately:
for i=numel(s):-1:1
    hObj(i) = getArrayFromByteStream(s(i).ObjData);
    % Make sure to include the context menu:
    set(hObj(i),'UIContextMenu', getArrayFromByteStream(s(i).UIContextMenuData));
end