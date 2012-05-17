function updateOverflowLineColor(ntx)

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $     $Date: 2010/03/31 18:22:08 $

% Interactive mode not allowed when strategy is "WL+FL" (mode 2)
dlg = ntx.hBitAllocationDialog;
if  (dlg.BAGraphicalMode)
    % When re-entering interactive modes, mark threshold cursor as movable
    set(ntx.hlOver, ...
        'color',ntx.ColorManualThreshold, ...
        'zdata',[0 0]);
else
    % Mark line as "under system control"
    % When doing this, push it "back" on z-axis so
    % the other cursor, if interactive, can remain "on top"
    set(ntx.hlOver, ...
        'color',ntx.ColorAutoThreshold, ...
        'zdata', [-1 -1]);
end
