function Status = undo(h)
%UNDO  Undoes transaction.

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:16:36 $

% RE: Coded for transactions of class ctrluis/transaction 

% Get last transaction
LastT = h.EventRecorder.popundo;

% Update status
Status = sprintf('Undoing %s.',LastT.Name);
h.newstatus(Status);

% Undo it (will perform required updating)
LastT.undo;

% Update history
h.recordtxt('history',Status);

