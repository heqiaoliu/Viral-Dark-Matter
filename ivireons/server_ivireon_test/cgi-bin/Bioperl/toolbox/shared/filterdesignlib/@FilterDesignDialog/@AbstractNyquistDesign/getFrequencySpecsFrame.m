function fspecs = getFrequencySpecsFrame(this)
%GETFREQUENCYSPECSFRAME   Get the frequencySpecsFrame.

%   Author(s): J. Schickler
%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/06/11 16:04:53 $

% Add the constraints popup.
items = getConstraintsWidgets(this, 'Frequency', 1);

items = getFrequencyUnitsWidgets(this, 2, items);

% Determine which constraints we need to add.
if strcmpi(this.FrequencyConstraints, 'transition width');

    items = addConstraint(this, 3, 1, items, true, ...
        'TransitionWidth', FilterDesignDialog.message('TWLabel'), 'Transition width');
else

    % If there is nothing added, add a spacer to reduce flicker.
    spacer.Name    = ' ';
    spacer.Type    = 'text';
    spacer.ColSpan = [1 1];
    spacer.RowSpan = [3 3];
    spacer.Tag     = 'Spacer';

    items = {items{:}, spacer}; %#ok<CCAT>
    
    spacer.RowSpan = [3 3];
    
    items = {items{:}, spacer}; %#ok<CCAT>
end

fspecs.Name       = FilterDesignDialog.message('freqspecs');
fspecs.Type       = 'group';
fspecs.Items      = items;
fspecs.LayoutGrid = [4 4];
fspecs.RowStretch = [0 0 0 1];
fspecs.ColStretch = [0 1 0 1];
fspecs.Tag        = 'FreqSpecsGroup';

% [EOF]
