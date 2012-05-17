function cbs = callbacks(hMgr)
%CALLBACKS The Callbacks to the Undo Manager's menus

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/14 23:17:11 $

% In R13 we should have the ability to call methods directly.

cbs.undo = @undo_cb;
cbs.redo = @redo_cb;


%------------------------------------------------------------------------
function redo_cb(hcbo, eventStruct, hMgr)

hFig = get(hMgr, 'FigureHandle');
p    = getptr(hFig);
setptr(hFig, 'watch');

redo(hMgr);

set(hFig, p{:});

%------------------------------------------------------------------------
function undo_cb(hcbo, eventStruct, hMgr)

hFig = get(hMgr, 'FigureHandle');
p    = getptr(hFig);
setptr(hFig, 'watch');

undo(hMgr);

set(hFig, p{:});

% [EOF]
