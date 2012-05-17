function attachlisteners(hMgr)
%ATTACHLISTENERS Attach the listeners

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/03/28 19:21:38 

listen = handle.listener([hMgr.RedoStack hMgr.UndoStack], 'TopChanged', @stack_listener);

set(listen, 'CallbackTarget', hMgr);

set(hMgr, 'WhenRenderedListeners', listen);

% [EOF]
