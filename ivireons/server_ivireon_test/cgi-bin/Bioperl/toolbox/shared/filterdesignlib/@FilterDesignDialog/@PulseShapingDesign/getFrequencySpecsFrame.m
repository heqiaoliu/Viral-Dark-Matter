function fspecs = getFrequencySpecsFrame(this)
%GETFREQUENCYSPECSFRAME Get the frequencySpecsFrame.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/04/21 04:23:26 $

if strcmpi(this.PulseShape, 'gaussian')
    [bt_lbl, bt] = getWidgetSchema(this, 'BT', ...
        FilterDesignDialog.message('BT'), 'edit', 1, 1);
    items = {bt_lbl, bt};
else
    [rolloff_lbl, rolloff] = getWidgetSchema(this, 'Beta', ...
        FilterDesignDialog.message('RolloffFactor'), 'edit', 1, 1);
    items = {rolloff_lbl, rolloff};
end

% Add the Frequency Units widgets
items = getFrequencyUnitsWidgets(this, 2, items);

fspecs.Name       = FilterDesignDialog.message('freqspecs');
fspecs.Type       = 'group';
fspecs.Items      = items;
fspecs.LayoutGrid = [2 4];
fspecs.RowStretch = [0 1];
fspecs.ColStretch = [0 1 0 1];
fspecs.Tag        = 'FreqSpecsGroup';

% [EOF]
