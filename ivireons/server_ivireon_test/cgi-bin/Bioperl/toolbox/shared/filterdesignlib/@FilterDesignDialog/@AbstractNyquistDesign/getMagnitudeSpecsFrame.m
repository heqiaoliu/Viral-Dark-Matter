function mspecs = getMagnitudeSpecsFrame(this)
%GETMAGNITUDESPECSFRAME   Get the magnitudeSpecsFrame.

%   Author(s): J. Schickler
%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/04/21 04:21:24 $

items = getConstraintsWidgets(this, 'Magnitude', 1);

% Determine which constraints we need to add.

if strcmpi(this.MagnitudeConstraints, 'stopband attenuation')

    items = getMagnitudeUnitsWidgets(this, 2, items);
    
    items = addConstraint(this, 3, 1, items, true, ...
        'Astop', FilterDesignDialog.message('Astop'), 'Stopband attenuation');
else

    % If there is nothing added, add a spacer to reduce flicker.
    spacer.Name    = ' ';
    spacer.Type    = 'text';
    spacer.ColSpan = [1 1];
    spacer.RowSpan = [2 2];
    spacer.Tag     = 'Spacer';

    items = {items{:}, spacer}; %#ok<CCAT>
    
    spacer.RowSpan = [3 3];
    
    items = {items{:}, spacer}; %#ok<CCAT>
end

mspecs.Name       = FilterDesignDialog.message('magspecs');
mspecs.Type       = 'group';
mspecs.Items      = items;
mspecs.LayoutGrid = [4 4];
mspecs.RowStretch = [0 0 0 1];
mspecs.ColStretch = [0 1 0 1];
mspecs.Tag        = 'MagSpecsGroup';

% [EOF]
