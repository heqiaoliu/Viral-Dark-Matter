function mspecs = getMagnitudeSpecsFrame(this)
%GETMAGNITUDESPECSFRAME Get the magnitudeSpecsFrame.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/04/21 04:22:04 $

if strcmp(this.OrderMode2, 'Order')

    help = FilterDesignDialog.message('NoMagConstHelpTxt');

    helptext.Type     = 'text';
    helptext.WordWrap = true;
    helptext.Name     = help;
    helptext.RowSpan  = [1 1];
    helptext.ColSpan  = [1 4];

    items = {helptext};

else
    items = getMagnitudeUnitsWidgets(this, 1);

    [gbw_lbl, gbw] = getWidgetSchema(this, 'GBW', FilterDesignDialog.message('GBW'), 'edit', 2, 1);
    
    items = [items {gbw_lbl gbw}];

end

mspecs.Name       = FilterDesignDialog.message('magspecs');
mspecs.Type       = 'group';
mspecs.Items      = items;
mspecs.LayoutGrid = [3 4];
mspecs.RowStretch = [0 0 1];
mspecs.ColStretch = [0 1 0 1];
mspecs.Tag        = 'MagSpecsGroup';

% [EOF]
