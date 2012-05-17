function createAppSpecificDialogs(ntx)
% Create NTX application dialogs

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $     $Date: 2010/05/20 02:17:56 $

% Use New dialog objects
dp = ntx.dp;

% Legend dialog
%
% Instantiate dialog using content and border objects
dialogContent = embedded.ntxui.LegendDialog(ntx);
ntx.hLegendDialog = dialogContent;
createAndRegisterDialog(dp,dialogContent);

% Counts dialog
%
dialogContent = embedded.ntxui.InputDataDialog(ntx);
ntx.hInputDataDialog = dialogContent;
createAndRegisterDialog(dp,dialogContent);

% Suggested Type dialog
%
dialogContent = embedded.ntxui.ResultingTypeDialog(ntx);
ntx.hResultingTypeDialog = dialogContent;
createAndRegisterDialog(dp,dialogContent);

% Bit Allocation dialog
%
dialogContent = embedded.ntxui.BitAllocationDialog(ntx);
ntx.hBitAllocationDialog = dialogContent;
createAndRegisterDialog(dp,dialogContent);
onPropertyPostSet(dialogContent,...
    {'BAWLMethod','BAWLBits',...
    'BAGraphicalMode','BAILMethod', 'BAILFLMethod' ,...
    'BAILCount','BAILPercent','BAILUnits',...
    'BAILSpecifyMagnitude','BAILSpecifyBits','BAILGuardBits', ...
    'BAFLMethod', ...
    'BAFLSpecifyMagnitude','BAFLSpecifyBits','BAFLExtraBits'}, ...
    @(h,ev)updateDTXControls(ntx));
% Update integer bits/overflow cursor before extra IL/FL bits change since we previously accounted for it.
onPropertyPreSet(dialogContent,...
    {'BAILGuardBits','BAFLExtraBits'}, ...
    @(h,ev)updateThresholdPosition(ntx));

onPropertyPostSet(dialogContent,...
    {'BASigned','BARounding'},...
    @(h,ev)updateSignedRoundingProperty(ntx,ev));

function updateSignedRoundingProperty(ntx,ev)
 % Update the histogram and NumericType based on  property changes to 
 % Signedness and Rounding.
 switch ev.Source.Name
     case 'BASigned'
         % Change .IsSigned flag
         updateSignedStatus(ntx);
         % React to .IsSigned flag, including numerictype changes
         initHistDisplay(ntx);
         
     case 'BARounding'
         % change .SmallNegAreOverflow flag
         updateSmallNegAreOverflow(ntx);
         % react to change, including numerictype changes
         initHistDisplay(ntx);
         % Not a change in "displayed" numeric type, but rounding
         % influences SNR, etc
         datatypeChanged(ntx);
 end
