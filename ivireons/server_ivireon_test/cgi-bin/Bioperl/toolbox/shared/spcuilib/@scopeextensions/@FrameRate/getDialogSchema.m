function dlgstruct = getDialogSchema(this,arg) %#ok
%GetDialogSchema Construct FrameRate dialog.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.8 $ $Date: 2009/04/27 19:53:58 $

% -------------------------------------------
% Basic items
% -------------------------------------------

% Source frame rate
%
orig1.Name           = 'Source rate:';
orig1.Type           = 'text';
orig1.RowSpan        = [1 1];
orig1.ColSpan        = [1 1];
orig1.ToolTip        = 'Original frame rate of source';
orig1.Tag            = 'Sourcefps_label';

s=sprintf('%g frames/sec', this.Sourcefps);
orig2.Name           = s;
orig2.Type           = 'text';
orig2.RowSpan        = [1 1];
orig2.ColSpan        = [2 2];
orig2.ToolTip        = 'Original frame rate of source';
orig2.Tag            = 'Sourcefps';

% Desired/specified frame rate
%
desired1.Name           = 'Desired playback rate:';
desired1.Type           = 'text';
desired1.RowSpan        = [2 2];
desired1.ColSpan        = [1 1];
desired1.ToolTip        = 'Desired frame rate during playback';
desired1.Tag            = 'Desiredfps_label';

desired2.Name           = '';
desired2.Type           = 'edit';
desired2.ObjectProperty = 'Desiredfps';
desired2.RowSpan        = [2 2];
desired2.ColSpan        = [2 2];
desired2.ToolTip        = 'Desired frame rate during playback';
desired2.Mode           = false;
desired2.Tag            = 'Desiredfps';

% units
%
desired_units.Name           = 'frames/sec';
desired_units.Tag           = 'DesiredUnit';
desired_units.Type           = 'text';
desired_units.RowSpan        = [2 2];
desired_units.ColSpan        = [3 3];

% Actual/measured rate
%
% Apparent rate = (timer rate) * (showCount+skipCount)/showCount
%
actual1.Name           = 'Actual playback rate:';
actual1.Type           = 'text';
actual1.RowSpan        = [3 3];
actual1.ColSpan        = [1 1];
actual1.ToolTip        = sprintf('Average frame rate achieved during screen updating');
actual1.Tag            = 'Actualfps_label';

s = sprintf('%.1f frames/sec', ...
    this.measuredRate * ...
    (this.SchedShowCount + this.SchedSkipCount) ./ this.SchedShowCount );
actual2.Name           = s;
actual2.Type           = 'text';
actual2.RowSpan        = [3 3];
actual2.ColSpan        = [2 2];
actual2.Tag            = 'actual';
actual2.ToolTip        = actual1.ToolTip;

basicItems.Type = 'group';
basicItems.Name = 'Frame Rate';
basicItems.LayoutGrid = [3 3];
basicItems.RowStretch = [0 0 1];
basicItems.ColStretch = [1 0 1];  % [0 0 1] disables, [1 0 1] enables
basicItems.RowSpan = [1 1];
basicItems.ColSpan = [1 1];
basicItems.Tag   = 'Basicinfo';
basicItems.Items = {orig1, orig2, ...
                   desired1, desired2, desired_units, ...
                   actual1, actual2};

% -----------------------------
% Advanced items
% -----------------------------

% Enable frame drop
%
allowDecim.Name           = 'Allow frame drop to achieve desired playback rate';
allowDecim.Type           = 'checkbox';
allowDecim.ObjectProperty = 'SchedEnable';
allowDecim.Tag            = 'allowDecim';
allowDecim.RowSpan        = [1 1];
allowDecim.ColSpan        = [1 3];
allowDecim.ToolTip        = sprintf(...
    ['When enabled, frames can be dropped according to a\n' ...
     'schedule in order to achieve desired playback rate.']);
% allowDecim.Mode          = true;  % immediate apply
allowDecim.DialogRefresh = true; % refresh done via object method
allowDecim.ObjectMethod   = 'handleButtons';
allowDecim.MethodArgs     = {'DropFramesCheckBox'};
allowDecim.ArgDataTypes   = {'string'};

if isempty(this.dialog)
    % Creating new frame rate dialog
    decimEnable = this.SchedEnable;
else
    % Dialog already open
    decimEnable = getWidgetValue(this.dialog,'allowDecim');
end

% Minimum refresh rate
%
minrate1.Name           = 'Minimum refresh rate:';
minrate1.Tag            = 'MinRefreshRate';
minrate1.Type           = 'text';
minrate1.RowSpan        = [2 2];
minrate1.ColSpan        = [1 1];
minrate1.ToolTip        = 'Increase to reduce display flicker and provide smooth screen updating.';
minrate1.Visible        = decimEnable;

minrate2.Name           = '';
minrate2.Type           = 'edit';
minrate2.ObjectProperty = 'SchedRateMin';
minrate2.RowSpan        = [2 2];
minrate2.ColSpan        = [2 2];
minrate2.Mode           = false;
minrate2.Tag            = 'SchedRateMin';
minrate2.Visible        = decimEnable;
minrate2.DialogRefresh  = true;
minrate2.ToolTip        = minrate1.ToolTip;

minrate_units = desired_units;
minrate_units.Tag     = 'SchedRateMinUnits';
minrate_units.Visible = decimEnable;

% Fastest timer rate
%
maxrate1.Name           = 'Maximum refresh rate:';
maxrate1.Tag            = 'MaxRefreshRate';
maxrate1.Type           = 'text';
maxrate1.RowSpan        = [3 3];
maxrate1.ColSpan        = [1 1];
maxrate1.ToolTip        = 'Decrease to reduce processor load.';
maxrate1.Visible        = decimEnable;

maxrate2.Name           = '';
maxrate2.Type           = 'edit';
maxrate2.ObjectProperty = 'SchedRateMax';
maxrate2.RowSpan        = [3 3];
maxrate2.ColSpan        = [2 2];
maxrate2.Mode           = false;
maxrate2.Tag            = 'SchedRateMax';
maxrate2.Visible        = decimEnable;
maxrate2.DialogRefresh  = true;
maxrate2.ToolTip        = maxrate1.ToolTip;

maxrate_units = desired_units;
maxrate_units.RowSpan = [3 3];
minrate_units.Tag     = 'SchedRateMaxUnits';
maxrate_units.Visible = decimEnable;

% Frame drop schedule
%
dropsched1.Name           = 'Playback schedule:';
dropsched1.Tag            = 'PlaySchedule';
dropsched1.Type           = 'text';
dropsched1.RowSpan        = [4 4];
dropsched1.ColSpan        = [1 1];
dropsched1.Visible        = decimEnable;
dropsched1.ToolTip      = sprintf(['Number of sequential frames to show then drop\n', ...
                                  'in order to meet desired playback rate.']);

if this.SchedShowCount==1, f1=''; else f1='s'; end
if this.SchedSkipCount==1, f2=''; else f2='s'; end
dropsched2.Name     = sprintf('Show %d frame%s, Drop %d frame%s',...
                              this.SchedShowCount, f1, ...
                              this.SchedSkipCount, f2);
dropsched2.Tag      = 'DropSched';
dropsched2.Type     = 'text';
dropsched2.RowSpan  = [4 4];
dropsched2.ColSpan  = [2 2];
dropsched2.Visible  = decimEnable;
dropsched2.ToolTip  = dropsched1.ToolTip;

% Display refresh rate
%
refrate1.Name       = 'Refresh rate:';
refrate1.Tag        = 'RefRate';
refrate1.Type       = 'text';
refrate1.RowSpan    = [5 5];
refrate1.ColSpan    = [1 1];
refrate1.Visible    = decimEnable;
refrate1.ToolTip = sprintf(['Rate that display must be updated, based on playback\n', ...
                            'schedule, in order to meet desired playback rate.']);

refrate2.Name    = sprintf('%g frames/sec', this.Schedfps);
refrate2.Tag     = 'RefRateSecond';
refrate2.Type    = 'text';
refrate2.RowSpan = [5 5];
refrate2.ColSpan = [2 2];
refrate2.Visible = decimEnable;
refrate2.ToolTip = refrate1.ToolTip;

% Panel of "Advanced" items underneath the "toggle button"
%
advItems.Type = 'group';
advItems.Name = 'Frame Drop';
advItems.Tag  = 'FrameDrop';
advItems.LayoutGrid = [5 3];
advItems.RowStretch = [0 0 0 0 1];
advItems.ColStretch = [1 0 1];
advItems.RowSpan    = [2 2];  % within main container
advItems.ColSpan    = [1 1];
advItems.Items      = {allowDecim, ...
                       minrate1, minrate2, minrate_units, ...
                       maxrate1, maxrate2, maxrate_units, ...
                       dropsched1, dropsched2, ...
                       refrate1, refrate2};

% Invisible widgets, to make DDG update this dialog
% based on changes to parameters
%
invisItems.Name           = '';
invisItems.Tag            = 'MeasuredRate';
invisItems.Type           = 'edit';
invisItems.Visible        = false;
invisItems.ObjectProperty = 'measuredRate';
invisItems.RowSpan        = [3 3];
invisItems.ColSpan        = [1 1];
invisItems.Mode           = false;

% Group it all together
%
allItems.Type = 'panel';
allItems.Name = 'Frame Rate';
allItems.LayoutGrid = [3 1];
allItems.RowStretch = [0 0 1];
allItems.ColStretch = 0;
allItems.RowSpan = [1 1];
allItems.ColSpan = [1 1];
allItems.Tag = 'allinfo';
allItems.Items = {basicItems, advItems, invisItems};

% ----------------------------------------------
% Return main dialog structure
% ----------------------------------------------
%
dlgstruct = this.StdDlgProps;
dlgstruct.Items           = {allItems};
dlgstruct.PreApplyMethod  = 'preApply';
dlgstruct.PostApplyMethod = 'postApply';
dlgstruct.DialogTag       = 'FrameRate';

% [EOF]
