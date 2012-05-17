function updateBar(ntx,data)
% Update bars in dynamic bar plot
% Also update any text displays that depend on histogram data.
%
% updateBar(ntx,data) updates the histogram data and the display.
% updateBar(ntx) updates the display without updating the data.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $     $Date: 2010/04/21 21:21:51 $

% If data not passed,
%  - force graphical update using current data
%  - skip (and disregard) decimation
%  - useful when changing y-axis units
% If data passed,
%  - apply decimation
%  - update histogram states
%  - perform graphical histogram bar update
%
if nargin > 1
    isFirstUpdate = updateHistData(ntx,data); % update histo states (not graphics)
   
    % Suppress resetting of data statistics on first call
    % This maintains SQNR statistics for the first-time data sent to tool,
    % which would otherwise be reset due to a change in data type that is
    % almost inevitable on the first update
    allowReset = ~isFirstUpdate;
else
    allowReset = true;
end

updateNumericTypesAndSigns(ntx,allowReset);% xxx clears out initial SSQE, etc
checkXAxisLock(ntx);
updateHistBarPlot(ntx);

performAutoBA(ntx); % Perform automatic bit allocation

% Update visible dialogs
updateDialogContent(ntx.dp);

% Update threshold over/underflow amount text
updateUnderflowTextAndXPos(ntx);
updateOverflowTextAndXPos(ntx);
updateBarThreshColor(ntx);

% These are called by updateThreshold(),
%    which is itself called by performAutoBA():
% updateInputDataDialog(ntx);

% Minimal update of display
setYAxisLimits(ntx);
updateXTickLabels(ntx);  % - optimized
updateDTXTextAndLinesYPos(ntx);
showOutOfRangeBins(ntx);
