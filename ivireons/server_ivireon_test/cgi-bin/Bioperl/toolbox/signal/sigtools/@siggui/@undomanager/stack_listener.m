function stack_listener(hMgr, eventData)
%STACK_LISTENER Listen for the UNDOSTACK to change.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2004/04/13 00:26:56 $

h = get(hMgr,'Handles');

% Set up the default string
label = 'Undo';

if isempty(hMgr.UndoStack)
    
    % If the undo stack is empty disable the menu item
    enabState = 'Off';
else

    % Use the name of the top transaction for the label
    hTrans = peek(hMgr.Undostack);
    label = [xlate(label) ' ' get(hTrans,'Name')];
    enabState = 'On';
end

set(h.undo, 'Enable',enabState);
set(findobj(h.undo, 'type', 'uimenu'),'Label',label);
set(findobj(h.undo, 'type', 'uipushtool'),'Tooltip',label);

% Set up the default string
label = 'Redo';

if isempty(hMgr.RedoStack)

    % If the redo stack is empty disable the menu item
    enabState = 'Off';
else
    
    % Use the name of the top transaction for the label
    hTrans = peek(hMgr.Redostack);
    label = [xlate(label) ' ' get(hTrans,'Name')];
    enabState = 'On';
end

set(h.redo, 'Enable',enabState);
set(findobj(h.redo, 'type', 'uimenu'),'Label',label);
set(findobj(h.redo, 'type', 'uipushtool'),'Tooltip',label);

% [EOF]
