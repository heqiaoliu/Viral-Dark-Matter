function redo(h)
%REDO  Redoes transaction.

%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2005/05/27 14:15:54 $

objectlist = h.ObjectsCell;
parentNode = h.ParentNodeHandle;

switch h.Action
    case 'added'
        myAction = 'removed';
    case 'removed'
        myAction = 'added';
    case 'renamed'
        myAction = 'renamed';
end
        
if isempty(parentNode)
    disp('The parent node supplied for Redo is invalid.');
    return;
end

if iscell(objectlist)
    if ~isempty(objectlist)
        if strcmpi(h.Action,'renamed')
            parentNode.restoreDataNode(objectlist,myAction,h.NamePair{2});
        else
            parentNode.restoreDataNode(objectlist,myAction);
        end
    else
        disp('Object list cell array is empty. Cannot Redo.')
    end
else
    disp('A cell array of data objects expected. Redo aborted.')
end

