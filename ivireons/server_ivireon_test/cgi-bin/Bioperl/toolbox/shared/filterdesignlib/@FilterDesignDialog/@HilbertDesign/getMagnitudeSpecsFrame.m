function mspecs = getMagnitudeSpecsFrame(this)
%GETMAGNITUDESPECSFRAME   Get the magnitudeSpecsFrame.

%   Author(s): J. Schickler
%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/04/21 04:22:39 $

if isminorder(this)

    items = getMagnitudeUnitsWidgets(this, 1);

    items = addConstraint(this, 2, 1, items, true, ...
        'Apass', FilterDesignDialog.message('Apass'), 'Passband ripple');
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
