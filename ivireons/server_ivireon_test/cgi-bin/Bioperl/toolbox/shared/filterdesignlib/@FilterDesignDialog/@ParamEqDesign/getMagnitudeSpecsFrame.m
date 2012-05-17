function mspecs = getMagnitudeSpecsFrame(this)
%GETMAGNITUDESPECSFRAME Get the magnitudeSpecsFrame.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/04/21 04:23:14 $

items = getConstraintsWidgets(this, 'Magnitude', 1);
items{1}.Name = FilterDesignDialog.message('gainconstraints');
items{1}.Visible = true;
items{2}.Visible = true;

%Magnitude unit widget, dB is the only valid choice in fdesign.parameq
[mag_lbl, mag] = getWidgetSchema(this, 'MagnitudeUnits', ...
    FilterDesignDialog.message('gainunits'), 'combobox', 2, 1);
mag_lbl.Tunable = true;
mag.DialogRefresh  = true;
mag.Entries = FilterDesignDialog.message({'dB'});
mag.Tunable = true;
items = {items{:}, mag_lbl, mag};

% Determine which constraints we need to add.
switch lower(this.MagnitudeConstraints)
    case 'reference, center frequency, bandwidth, passband'
        items = addConstraint(this, 3, 1, items, true, 'Gref', FilterDesignDialog.message('Gref'));
        items = addConstraint(this, 3, 3, items, true, 'G0',    FilterDesignDialog.message('G0'));
        items = addConstraint(this, 4, 1, items, true, 'GBW',   FilterDesignDialog.message('GBW'));
        items = addConstraint(this, 4, 3, items, true, 'Gpass', FilterDesignDialog.message('Gpass'));
    case 'reference, center frequency, bandwidth, stopband'
        items = addConstraint(this, 3, 1, items, true, 'Gref', FilterDesignDialog.message('Gref'));
        items = addConstraint(this, 3, 3, items, true, 'G0',    FilterDesignDialog.message('G0'));
        items = addConstraint(this, 4, 1, items, true, 'GBW',   FilterDesignDialog.message('GBW'));
        items = addConstraint(this, 4, 3, items, true, 'Gstop', FilterDesignDialog.message('Gstop'));
    case 'reference, center frequency, bandwidth, passband, stopband'
        items = addConstraint(this, 3, 1, items, true, 'Gref', FilterDesignDialog.message('Gref'));
        items = addConstraint(this, 3, 3, items, true, 'G0',    FilterDesignDialog.message('G0'));
        items = addConstraint(this, 4, 1, items, true, 'GBW',   FilterDesignDialog.message('GBW'));
        items = addConstraint(this, 4, 3, items, true, 'Gpass', FilterDesignDialog.message('Gpass'));
        items = addConstraint(this, 5, 1, items, true, 'Gstop', FilterDesignDialog.message('Gstop'));
    case 'reference, center frequency, bandwidth'
        items = addConstraint(this, 3, 1, items, true, 'Gref', FilterDesignDialog.message('Gref'));
        items = addConstraint(this, 3, 3, items, true, 'G0',  FilterDesignDialog.message('G0'));
        items = addConstraint(this, 4, 1, items, true, 'GBW', FilterDesignDialog.message('GBW'));
    case 'reference, center frequency'
        items = addConstraint(this, 3, 1, items, true, 'Gref', FilterDesignDialog.message('Gref'));
        items = addConstraint(this, 3, 3, items, true, 'G0',  FilterDesignDialog.message('G0'));    
    case 'boost/cut'
        %Gbc will control the boost or cut gain of the shelving filters
        items = addConstraint(this, 3, 1, items, true, 'Gbc', FilterDesignDialog.message('Gboostcut'));            
end

mspecs.Name       = FilterDesignDialog.message('gainspecs');
mspecs.Type       = 'group';
mspecs.Items      = items;
mspecs.LayoutGrid = [6 4];
mspecs.RowStretch = [0 0 0 0 0 1];
mspecs.ColStretch = [0 1 0 1];
mspecs.Tag        = 'MagSpecsGroup';

% [EOF]
