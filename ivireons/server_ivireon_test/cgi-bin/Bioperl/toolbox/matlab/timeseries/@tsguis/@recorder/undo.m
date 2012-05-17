function undo(h)
%UNDO timeseries or tscollection modification transaction.

%   Author(s): Rajiv Singh
%   Copyright 2004-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2006/06/27 23:11:00 $

%% Pop the latest undo transaction from the @recorder stack and undo it.
%% Then fire a datachange event for each of the affected time series
if ~isempty(h.Undo)
    if isa(h.Undo(end),'tsguis.transaction')
        localTransactionUndo(h);
    elseif isa(h.Undo(end),'tsguis.nodetransaction')
        localNodeTransactionUndo(h);
    end
end

%--------------------------------------------------------------------------
function localTransactionUndo(h) 
% To undo a data logging record we must stop recording
% without a write because transaction stack

% Pop the latest transaction and undo it
trans = h.popundo;
trans.undo;

% Get handles to the affected timeseries/tscollection objects
affectedObjs = trans.ObjectsCell;

% Now send datachange events 
% REVISIT: Should this be done for only those objects that are actually there
% in the tree: as a safeguard? 
for k = 1:length(affectedObjs)
     thisobj = affectedObjs{k};
     thisobj.fireDataChangeEvent(tsdata.dataChangeEvent(thisobj,'undo',[]));
end
    
%--------------------------------------------------------------------------
function localNodeTransactionUndo(h)
% undo a Tscolleciton transaction

% Pop the latest transaction and undo it
trans = h.popundo;
trans.undo;
