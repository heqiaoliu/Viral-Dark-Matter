function fspecs = getFrequencySpecsFrame(this)
%GETFREQUENCYSPECSFRAME   Get the frequencySpecsFrame.

%   Author(s): J. Schickler
%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/04/21 04:23:19 $

% Add the constraints popup.
items = getConstraintsWidgets(this, 'Frequency', 1);

% Add the Frequency Units widgets
items = getFrequencyUnitsWidgets(this, 2, items);

% Determine which constraints we need to add.
switch lower(this.FrequencyConstraints)
    case 'center frequency and quality factor'
        items = addConstraint(this, 3, 1, items, true, 'F0', FilterDesignDialog.message('F0'));
        items = addConstraint(this, 3, 3, items, true, 'Q', FilterDesignDialog.message('Q'), 'Q');
    case 'center frequency and bandwidth'
        items = addConstraint(this, 3, 1, items, true, 'F0', FilterDesignDialog.message('F0'));
        items = addConstraint(this, 3, 3, items, true, 'BW', FilterDesignDialog.message('BW'));
end

fspecs.Name       = FilterDesignDialog.message('freqspecs');
fspecs.Type       = 'group';
fspecs.Items      = items;
fspecs.LayoutGrid = [4 4];
fspecs.RowStretch = [0 0 0 1];
fspecs.ColStretch = [0 1 0 1];
fspecs.Tag        = 'FreqSpecsGroup';

% [EOF]
