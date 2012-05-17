function selectgain(this)
%SELECTGAIN  Selects gain value by clicking on the root locus plot.
%
%   See also SISOTOOL

%   Author(s): P. Gahinet
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.21.4.2 $  $Date: 2006/11/17 13:25:48 $

% Enabled only in idle mode
if ~strcmp(this.EditMode,'idle')
    return
end
Axes = this.Axes;
PlotAxes = getaxes(Axes);
LoopData = this.LoopData;
EventMgr = this.EventManager;

% Edited compensator
C = this.GainTargetBlock;
this.setEditedBlock(C);

% Compute new loop gain value
RLInfo = this.OpenLoopData;  % contains open-loop dynamics
CP = get(PlotAxes,'CurrentPoint');
P = CP(1,1) + 1i * CP(1,2);
NumP = RLInfo.Gain * prod(P-RLInfo.Zero);  % evaluate norm. ol numerator at P
DenP = prod(P-RLInfo.Pole);                % evaluate norm. ol denominator at P
if RLInfo.InverseFlag
   NewGainMag = abs(NumP/DenP);
else
   NewGainMag = abs(DenP/NumP);
end

% Freeze axis limits in Root Locus this (axis rescaling gives the 
% illusion of missing the selected point)
Axes.LimitManager = 'off';  % disable any limit updating
XlimMode = Axes.XlimMode;
YlimMode = Axes.YlimMode;
Axes.XlimMode = 'manual';
Axes.YlimMode = 'manual';

% Start transaction 
T = ctrluis.transaction(LoopData,'Name','Edit Gain',...
    'OperationStore','on','InverseOperationStore','on');

% Set new compensator gain
C.setZPKGain(NewGainMag,'mag');

% Commit and stack transaction, and update plots
EventMgr.record(T);
LoopData.dataevent('gain',C);

% Notify status bar and history listeners
Status = sprintf('Loop gain changed to %0.3g',getFormattedGain(C));
EventMgr.newstatus(Status);
EventMgr.recordtxt('history',Status);

% Restore initial axis limit modes
Axes.XlimMode = XlimMode;
Axes.YlimMode = YlimMode;
Axes.LimitManager = 'on';

