function mspecs = getMagnitudeSpecsFrame(this)
%GETMAGNITUDESPECSFRAME   Get the magnitudeSpecsFrame.

%   Author(s): J. Schickler
%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/04/21 04:22:55 $
spacer.Name    = ' ';
spacer.Type    = 'text';
spacer.RowSpan = [1 1];
spacer.ColSpan = [1 1];
spacer.Tag     = 'Spacer';

items = getConstraintsWidgets(this, 'Magnitude', 1);

% Determine which constraints we need to add.
hasapass = ~isempty(strfind(lower(this.MagnitudeConstraints), 'passband ripple'));
hasastop = ~isempty(strfind(lower(this.MagnitudeConstraints), 'stopband attenuation'));

if hasapass || hasastop
% str = 'FilterDesignLib:fbdialog:fb';
    items = getMagnitudeUnitsWidgets(this, 2, items);

    [items col] = addConstraint(this, 3, 1,   items, hasapass, ...
        'Apass', FilterDesignDialog.message('Apass'),...
        'Passband ripple');
    items       = addConstraint(this, 3, col, items, hasastop, ...
        'Astop', FilterDesignDialog.message('Astop'), 'Stopband attenuation');
else

    % If there is nothing added, add a spacer to reduce flicker.
    spacer.RowSpan = [2 2];
    spacer.Tag     = 'Spacer2';

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
