function Status = redo(h)
%REDO  Undoes transaction.

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:16:33 $

% Get last transaction
LastT = h.EventRecorder.popredo;

% Update status
Status = sprintf('Redoing %s.',LastT.Name);
h.newstatus(Status);

% Redo it (will perform required updating)
LastT.redo;

% Update history
h.recordtxt('history',Status);

