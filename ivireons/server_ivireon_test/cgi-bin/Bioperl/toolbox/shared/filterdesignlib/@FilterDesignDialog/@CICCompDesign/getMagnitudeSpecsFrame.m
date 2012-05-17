function mspecs = getMagnitudeSpecsFrame(this)
%GETMAGNITUDESPECSFRAME   Get the magnitudeSpecsFrame.

%   Author(s): J. Schickler
%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/04/21 04:21:51 $

spacer.Name    = ' ';
spacer.Type    = 'text';
spacer.RowSpan = [1 1];
spacer.ColSpan = [1 1];
spacer.Tag     = 'Spacer';

items = getConstraintsWidgets(this, 'Magnitude', 1);

if strcmpi(this.MagnitudeConstraints, 'unconstrained')

        % If there is nothing added, add a spacer to reduce flicker.
    spacer.RowSpan = [2 2];
    spacer.Tag     = 'Spacer2';

    items = {items{:}, spacer}; %#ok<CCAT>

    spacer.RowSpan = [3 3];

    items = {items{:}, spacer}; %#ok<CCAT>

else
    items = getMagnitudeUnitsWidgets(this, 2, items);

    [items col] = addConstraint(this, 3, 1,   items, true, ...
        'Apass', FilterDesignDialog.message('Apass'), 'Passband ripple');
    items       = addConstraint(this, 3, col, items, true, ...
        'Astop', FilterDesignDialog.message('Astop'), 'Stopband attenuation');

end

mspecs.Name       = FilterDesignDialog.message('magspecs');
mspecs.Type       = 'group';
mspecs.Items      = items;
mspecs.LayoutGrid = [4 4];
mspecs.RowStretch = [0 0 0 1];
mspecs.ColStretch = [0 1 0 1];
mspecs.Tag        = 'MagSpecsGroup';


% [EOF]
