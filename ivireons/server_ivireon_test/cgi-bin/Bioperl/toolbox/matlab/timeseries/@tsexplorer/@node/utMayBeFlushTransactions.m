function utMayBeFlushTransactions(h,List,varargin)
% update the recorder stack to delete transactions that no longer apply

%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2005/06/27 22:55:59 $

r = tsguis.recorder;

%__________________________________________________________________________
%NOTE: Updating the transactions
%__________________________________________________________________________
% Rules:
%   (1) If no transaction contains a reference to timeseries in the
%       node being deleted, then do not touch the stack.
%   (2) If a transaction contains only those Timeseries that are all
%       members of the node being deleted, then delete that transaction.
%   (3) If a transaction contains a list of Timeseries objects that are
%       "not all" associated with the node being deleted, then deactivate
%       the timeseries datachange event ande delete its reference from
%       ObjectsCell.
%__________________________________________________________________________

%disable datachange event on timeseries being deleted
for m = 1:length(List)
    List{m}.DataChangeEventsEnabled = false;
end

% fix undo stack
k = 1;
while k<=length(r.Undo)
    if isa(r.Undo,'tsguis.nodetransaction')
        % nodetransactions record undoable deletions and additons of
        % timeseries (currently, only to tscollections). These transactions
        % should not be flushed.
        k = k+1;
        continue;
    end
    Tmembers = r.Undo(k).ObjectsCell;
    I = localismember(Tmembers,List);
    if all(I)
        %delete this transaction
        r.Undo = [r.Undo(1:k-1); r.Undo(k+1:end)];
    elseif any(I)
        %Option 1:
        %flush the stack from this transaction onwards
        %r.Undo = r.Undo(1:k-1);
        %break;
        
        %Option 2:
        %remove references to the deleted timeseries
        r.Undo(k).ObjectsCell = r.Undo(k).ObjectsCell(~I);
    else
        %no action: evaluate the next transaction
        k = k+1;
    end
end
    
% fix redo stack
k = 1;
while k<=length(r.Redo)
    if isa(r.Redo,'tsguis.nodetransaction')
        k = k+1;
        continue;
    end
    Tmembers = r.Redo(k).ObjectsCell;
    I = localismember(Tmembers,List);
    if all(I)
        %delete only this transaction
        r.Redo = [r.Redo(1:k-1); r.Redo(k+1:end)];
    elseif any(I)
        %Option 1:
        %flush the stack from this transaction onwards
        %r.Redo = r.Redo(1:k-1);
        %break;
        
        %Option 2:
        %remove references to the deleted timeseries
        r.Redo(k).ObjectsCell = r.Redo(k).ObjectsCell(~I);
    else
        %no action: evaluate the next transaction
        k = k+1;
    end
end

%-------------------------------------------------------------------------
function I = localismember(a,b)
%compare the contents of a and b to determine of members of a are also the
%members of b. I is a logical array showing membership (or lack thereof).
%
% a and b are cell array of timeseries objects

I = false(size(a));

for k = 1:numel(a)
    for ii = 1:numel(b)
        if isequal(a{k},b{ii})
            I(k) = true;
            break;
        end
    end
end