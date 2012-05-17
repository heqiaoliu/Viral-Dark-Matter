function fspecs = getFrequencySpecsFrame(this)
%GETFREQUENCYSPECSFRAME   Get the frequencySpecsFrame.

%   Author(s): J. Schickler
%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/04/21 04:21:47 $

% Add the constraints popup.
items = getConstraintsWidgets(this, 'Frequency', 1);

% Add the Frequency Units widgets
items = getFrequencyUnitsWidgets(this, 2, items);

% Determine which constraints we need to add.
hasfpass = ~isempty(strfind(lower(this.FrequencyConstraints), 'passband edge'));
hasfstop = ~isempty(strfind(lower(this.FrequencyConstraints), 'stopband edge'));
hasf6db  = ~isempty(strfind(lower(this.FrequencyConstraints), '6db point'));

[items col] = addConstraint(this, 3, 1,   items, hasf6db,  ...
    'F6dB', FilterDesignDialog.message('Fc'), '6dB point');
[items col] = addConstraint(this, 3, col, items, hasfpass, ...
    'Fpass', FilterDesignDialog.message('Fpass'), 'Passband edge');
items       = addConstraint(this, 3, col, items, hasfstop, ...
    'Fstop', FilterDesignDialog.message('Fstop'), 'Stopband edge');

fspecs.Name       = FilterDesignDialog.message('freqspecs');
fspecs.Type       = 'group';
fspecs.Items      = items;
fspecs.LayoutGrid = [4 4];
fspecs.RowStretch = [0 0 0 1];
fspecs.ColStretch = [0 1 0 1];
fspecs.Tag        = 'FreqSpecsGroup';

% [EOF]
