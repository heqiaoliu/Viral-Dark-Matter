function undo(h)
%UNDO  Undo transaction.
% Tsc is a handle to the tscollection object on which the undo operation
% needs to apply.

%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2005/05/27 14:15:56 $

objectlist = h.ObjectsCell;
parentNode = h.ParentNodeHandle;

if isempty(parentNode)
    disp('The parent node supplied for Undo is invalid.');
    return;
end

if iscell(objectlist)
    if ~isempty(objectlist)
        if strcmpi(h.Action,'renamed')
            parentNode.restoreDataNode(objectlist,h.Action,h.NamePair{1});
        else
            parentNode.restoreDataNode(objectlist,h.Action);
        end
    else
        disp('Object list cell array is empty. Cannot Undo.')
    end
else
    disp('A cell array of data objects expected. Undo aborted.')
end
