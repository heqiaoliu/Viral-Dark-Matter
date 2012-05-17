function undo(t)
% Undoes transaction.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:16:42 $
feval(t.UndoFcn{:});