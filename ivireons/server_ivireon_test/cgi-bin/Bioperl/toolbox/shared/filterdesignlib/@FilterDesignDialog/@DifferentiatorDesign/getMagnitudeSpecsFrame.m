function mspecs = getMagnitudeSpecsFrame(this)
%GETMAGNITUDESPECSFRAME   Get the magnitudeSpecsFrame.

%   Author(s): J. Schickler
%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/04/21 04:22:13 $

items = getConstraintsWidgets(this, 'Magnitude', 1);

if isminorder(this)

    items = getMagnitudeUnitsWidgets(this, 2, items);

    [items col] = addConstraint(this, 3, 1,   items, true, ...
        'Apass', FilterDesignDialog.message('Apass'), 'Passband ripple');
    items       = addConstraint(this, 3, col, items, true, ...
        'Astop', FilterDesignDialog.message('Astop'), 'Stopband attenuation');
else
    help = FilterDesignDialog.message('NoMagConstHelpTxt');
    helptext.Type     = 'text';
    helptext.WordWrap = true;
    helptext.Name     = help;
    helptext.RowSpan  = [1 1];
    helptext.ColSpan  = [1 4];

    items = {helptext};
end

mspecs.Name       = FilterDesignDialog.message('magspecs');
mspecs.Type       = 'group';
mspecs.Items      = items;
mspecs.LayoutGrid = [4 4];
mspecs.RowStretch = [0 0 0 1];
mspecs.ColStretch = [0 1 0 1];
mspecs.Tag        = 'MagSpecsGroup';

% [EOF]
