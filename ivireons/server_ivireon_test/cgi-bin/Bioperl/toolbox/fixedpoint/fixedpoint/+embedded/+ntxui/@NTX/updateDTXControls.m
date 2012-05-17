function updateDTXControls(ntx)
% Update DTX automation controls in dialog panel

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $     $Date: 2010/05/20 02:18:05 $

% Needed whether dialog panel is visible or not, since the BitAllocation
% dialog may be un-docked and still provide push-commands.
if isDialogVisible(ntx.dp,'Bit Allocation')
    % Synchronize the Vertical units on the axis and overflow pop-up.
    changeVerticalUnitsOption(ntx,ntx.hBitAllocationDialog.BAILUnits);
    
    % Update all widgets in the Bit Allocation panel
    setBAWidgets(ntx.hBitAllocationDialog);
    
    % Based on DTX controls, threshold line colors change
    updateUnderflowLineColor(ntx);
    updateOverflowLineColor(ntx);
    
    % If DTX turned on, perform bit allocation computations
    % updateBar will continue to keep this up-to-date for new data
    performAutoBA(ntx);
end
