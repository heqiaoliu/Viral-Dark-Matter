function record(hMgr, hT)
%RECORD Add a transaction to the undo stack
%   RECORD(hMGR, hTRANS) Add the transaction (hTRANS) to the UndoManager
%   associated with hMGR.  hTRANS is a handle to a transaction object.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.4 $  $Date: 2008/05/31 23:28:24 $

error(nargchk(2,2,nargin,'struct'));

% Suppress the Stack overflow warnings
w = warning('off');

% If the parent property of the transaction is empty, then it has
% already been committed.
if ~isempty(hT.Parent)
    commit(hT);
end

% If it is numeric it hasn't been created yet
if isnumeric(hMgr.UndoStack),
    hMgr.UndoStack = sigutils.overflowstack(hMgr.Limit);
    attachlisteners(hMgr);
end

% Add the new transaction to the undo stack
push(hMgr.UndoStack,hT);

if ~isempty(hMgr.RedoStack),
    
    % Empty the redo stack
    empty(hMgr.RedoStack);
end

warning(w);
if strcmpi(lastwarn, 'stack is full, overflow has occurred.'),
    lastwarn('');
end

% [EOF]
