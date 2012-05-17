function fspecs = getFrequencySpecsFrame(this)
%GETFREQUENCYSPECSFRAME   Get the frequencySpecsFrame.

%   Author(s): J. Schickler
%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/04/21 04:22:36 $

% Add the Frequency Units widgets
items = getFrequencyUnitsWidgets(this, 1);

items = addConstraint(this, 2, 1, items, true, ...
    'TransitionWidth', FilterDesignDialog.message('TW'), 'Transition width');

fspecs.Name       = FilterDesignDialog.message('freqspecs');
fspecs.Type       = 'group';
fspecs.Items      = items;
fspecs.LayoutGrid = [4 4];
fspecs.RowStretch = [0 0 0 1];
fspecs.ColStretch = [0 1 0 1];
fspecs.Tag        = 'FreqSpecsGroup';

% [EOF]
