function doShiftDialogs(dp,ydelta)
% Shift all dialogs within dialog panel.
%
% Since ydelta is a shift relative to the start of the drag,
% we must add this to the cached initial positions of all dialogs
% (Accumulation on *updated* positions would cause acceleration,
%  not uniform velocity, during shift)

% Get cell-array of position vectors, only for visible dialogs

%  Copyright 2010 The MathWorks, Inc.
%  $Revision: 1.1.6.1 $   $Date: 2010/03/31 18:39:41 $

visDlgs = dp.DockedDialogs;
N = numel(visDlgs);
if N > 0
    % .DialogShiftStartPos has the pos rect of currently visible dialogs,
    % each in its own cell of a cell vector of rects
    ss = dp.DialogShiftStartPos;
    offset = [0 ydelta 0 0];
    for i = 1:N
        set(visDlgs(i).DialogBorder.Panel, ...
            'pos',ss{i}+offset);
    end
    
    % Update scroll bar value
    setScrollBarValue(dp);
end
