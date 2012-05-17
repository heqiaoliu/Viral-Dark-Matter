function redo(h)

%   Author(s): Rajiv Singh
%   Copyright 2004-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2006/06/27 23:10:58 $

%% Pop the latest redo transaction from the @recorder stack and undo it.
%% Then fire a datachange event for each of the affected time series
if ~isempty(h.Redo)
    if isa(h.Redo(end),'tsguis.transaction')
        localTransactionRedo(h);
    elseif isa(h.Redo(end),'tsguis.nodetransaction')
        localNodeTransactionRedo(h);
    end
end

%--------------------------------------------------------------------------
function localTransactionRedo(h)

% Pop the latest transaction and redo it
trans = h.popredo;
trans.redo;

% [treeTs,treeTsColl] = h.getDataMembers;
% allElements = {treeTs{:},treeTsColl{:}}; 

% get handles to the affected timeseries/tscollection objects
affectedObjs = trans.ObjectsCell;

if isempty(affectedObjs)
    %disp('This redo operation has an empty ''ObjectsCell'' attached to it.')
end


% now send datachange events 
for k = 1:length(affectedObjs)
    thisobj = affectedObjs{k};
    thisobj.fireDataChangeEvent(tsdata.dataChangeEvent(thisobj,'redo',[]));
end

%--------------------------------------------------------------------------
function localNodeTransactionRedo(h)
%redo a tscollection transaction

% Pop the latest transaction from redo stack and redo the operation
trans = h.popredo;
trans.redo;
