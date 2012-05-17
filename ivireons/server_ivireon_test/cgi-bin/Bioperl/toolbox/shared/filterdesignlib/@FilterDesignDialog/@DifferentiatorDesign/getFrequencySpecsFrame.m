function fspecs = getFrequencySpecsFrame(this)
%GETFREQUENCYSPECSFRAME   Get the frequencySpecsFrame.

%   Author(s): J. Schickler
%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/12/05 02:22:24 $

% Add the constraints popup.
items = getConstraintsWidgets(this, 'Frequency', 1);

% Make frequency constraints non-tunable because the filter order can only
% be even or odd for a given frequency constraint
items{1}.Tunable = false;
items{2}.Tunable = false;

% Add the Frequency Units widgets
items = getFrequencyUnitsWidgets(this, 2, items);

% Determine which constraints we need to add.
if ~strcmpi(this.FrequencyConstraints, 'unconstrained')
    [items col] = addConstraint(this, 3, 1, items, true, ...
        'Fpass', FilterDesignDialog.message('Fpass'), 'Passband edge');
    items       = addConstraint(this, 3, col, items, true, ...
        'Fstop', FilterDesignDialog.message('Fstop'), 'Stopband edge');
end

fspecs.Name       = FilterDesignDialog.message('freqspecs');
fspecs.Type       = 'group';
fspecs.Items      = items;
fspecs.LayoutGrid = [4 4];
fspecs.RowStretch = [0 0 0 1];
fspecs.ColStretch = [0 1 0 1];
fspecs.Tag        = 'FreqSpecsGroup';

% [EOF]
