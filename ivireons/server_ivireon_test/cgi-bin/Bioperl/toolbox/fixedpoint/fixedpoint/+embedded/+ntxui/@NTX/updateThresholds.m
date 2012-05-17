function updateThresholds(ntx,xq)
% Update graphics to initialize display, during a line drag, etc
%
% xq is the x-coord in exponent units (N, not 2^N) of the threshold line,
% without an offset.  Argument passed only if it changed
%
% If xq arg omitted, updates to text, colors, etc, are still performed

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2.2.1 $     $Date: 2010/07/06 14:39:23 $

% Take action based on which line is being dragged
if nargin < 2
    % Update BOTH graphical lines using LastOver and LastUnder
    % resulting from locked drag, etc
    updateInteractiveMagLinesAndReadouts(ntx,ntx.LastOver,ntx.LastUnder);
else
    switch ntx.WhichLineDragged
        case 1 % Underflow line
            if validUnderflowXDrag(ntx,xq)
                % We will convert the underflow threshold position to the
                % actual fraction length value and then update the cursor
                % position based on the fraction length.
                updateInteractiveMagLinesAndReadouts(ntx,ntx.LastOver,xq+1);
                setUnderflowLineDragged(ntx.hBitAllocationDialog, true);
                setOverflowLineDragged(ntx.hBitAllocationDialog, false);
            end
        case 2 % Overflow line
            if validOverflowXDrag(ntx,xq)
                updateInteractiveMagLinesAndReadouts(ntx,xq,ntx.LastUnder);
                setOverflowLineDragged(ntx.hBitAllocationDialog, true);
                setUnderflowLineDragged(ntx.hBitAllocationDialog, false);
            end
      otherwise
        % Internal message to help debugging. Not intended to be user-visible.
        errID = generatemessageid('invalidIndex');
        error(errID,'Invalid line index specified');
    end
end
% Update other readouts in response to changes in thresholds
updateDTXHistReadouts(ntx);
