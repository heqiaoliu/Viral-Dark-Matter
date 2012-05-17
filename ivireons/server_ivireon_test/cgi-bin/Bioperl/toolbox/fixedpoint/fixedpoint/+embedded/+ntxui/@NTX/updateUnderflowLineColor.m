function updateUnderflowLineColor(ntx)

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $     $Date: 2010/03/31 18:22:15 $

% Interactive mode not allowed when strategy is "WL+IL" (mode 1)
dlg = ntx.hBitAllocationDialog;
if  (dlg.BAGraphicalMode)
    % When re-entering interactive mode, mark threshold cursor as movable
    set(ntx.hlUnder, ...
        'color',ntx.ColorManualThreshold, ...
        'zdata',[0 0]);
else
    % Mark line as "under system control"
    % Push back in z-axis so that the Overthresh cursor, if it is
    % interactive, can cover this cursor.  Otherwise, this black cursor
    % might cover the interactive red cursor, and that's not what we want
    % to present to the user: if a red (interactive) cursor exists, it
    % should be on top.
    set(ntx.hlUnder, ...
        'color',ntx.ColorAutoThreshold, ...
        'zdata',[-1 -1]);
end
