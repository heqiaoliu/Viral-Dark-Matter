function s = getCurrentUserSettings(ntx)
% Return structure of user-defined property settings
% Useful for storing user settings for subsequent invocation of tool.
%
% See installDefaultUserSettings() for definitions of all variable.s

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $     $Date: 2010/03/31 18:21:14 $

% -- From DialogPanel object
%
dp = ntx.dp;
s.Info.AutoHide   = dp.AutoHide;
s.Info.PanelLock  = dp.PanelLock;
s.Info.PanelWidth = dp.PanelWidth;
s.Info.DockedDialogNamesInit = getDockedDialogNames(dp);

% -- From NTX application
%
s.Body.HistBarWidth      = ntx.HistBarWidth;
s.Body.HistVerticalUnits = ntx.HistVerticalUnits;

s.Body.ColorFixedLine       = ntx.ColorFixedLine;
s.Body.ColorManualThreshold = ntx.ColorManualThreshold;
s.Body.ColorAutoThreshold   = ntx.ColorAutoThreshold;
s.Body.ColorOverflowBar     = ntx.ColorOverflowBar;
s.Body.ColorNormalBar       = ntx.ColorNormalBar;
s.Body.ColorUnderflowBar    = ntx.ColorUnderflowBar;

s.Body.DTXIntSpanText    = ntx.DTXIntSpanText;   % xxx internal only?
s.Body.DTXFracSpanText   = ntx.DTXFracSpanText;

% -- For Options dialog
%
dlg = ntx.hOptionsDialog;

s.Body.OptionsRefresh    = dlg.OptionsRefresh;

% -- For Allocation dialog:
%
dlg = ntx.hBitAllocationDialog;

s.Body.BASigned     = dlg.BASigned;
s.Body.BARounding   = dlg.BARounding;

s.Body.BAStrategy     = dlg.BAStrategy;
s.Body.BAWLBits       = dlg.BAWLBits;
s.Body.BATargetSQNR   = dlg.BATargetSQNR;

s.Body.BAILMethod      = dlg.BAILMethod;
s.Body.BAILMagInteractive = dlg.BAILMagInteractive;
s.Body.BAILPercent     = dlg.BAILPercent;
s.Body.BAILCount       = dlg.BAILCount;
s.Body.BAILUnits       = dlg.BAILUnits;
s.Body.BAILSpecifyMagnitude = dlg.BAILSpecifyMagnitude;
s.Body.BAILSpecifyBits = dlg.BAILSpecifyBits;
s.Body.BAILGuardBits   = dlg.BAILGuardBits;

s.Body.BAFLMethod      = dlg.BAFLMethod;
s.Body.BAFLMagInteractive = dlg.BAFLMagInteractive;
s.Body.BAFLPercent     = dlg.BAFLPercent;
s.Body.BAFLCount       = dlg.BAFLCount;
s.Body.BAFLUnits       = dlg.BAFLUnits;
s.Body.BAFLSpecifyMagnitude = dlg.BAFLSpecifyMagnitude;
s.Body.BAFLSpecifyBits = dlg.BAFLSpecifyBits;
s.Body.BAFLExtraBits   = dlg.BAFLExtraBits;
