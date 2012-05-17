function headerFrame = getHeaderFrame(this)
%GETHEADERFRAME   Get the headerFrame.

%   Author(s): J. Schickler
%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/04/21 04:22:01 $

[combtype_lbl, combtype] = getWidgetSchema(this, 'CombType', FilterDesignDialog.message('CombType'), 'combobox', 1, 1);
combtype.DialogRefresh = true;
combtype.Entries = FilterDesignDialog.message({'notch','peak'});

% Set up the order widgets, but heavily modify them.
[ordermode_lbl, ordermode, order_lbl, order] = getOrderWidgets(this, 2, true);
if strcmp(this.CombType, 'Peak')
    numStringID = 'NumPeaks';     % create the ID for displaying on the dialog
else
    numStringID = 'NumNotches';
end
ordermode.Entries = FilterDesignDialog.message({'Order', numStringID});
ordermode.ObjectProperty = 'OrderMode2';

% Refresh the dialog on order changes because we may need to update the
% NotchFrequencies/PeakFrequencies information box.
order.DialogRefresh = true;
if strcmp(this.OrderMode2, 'Number of Features')
    order.ObjectProperty = 'NumPeaksOrNotches';
    order_lbl.Name = FilterDesignDialog.message(numStringID);
    
    % When specifying the number of peaks/notches the user must also
    % specify the order of the shelving filter.
    [nsh_lbl, nsh] = getWidgetSchema(this, 'ShelvingFilterOrder', ...
        FilterDesignDialog.message('ShelvingFilterOrder'), 'edit', 3, 1);
    items = {combtype_lbl, combtype, ordermode_lbl, ordermode, ...
        order_lbl, order, nsh_lbl, nsh};
else
    items = {combtype_lbl, combtype, ordermode_lbl, ordermode, order_lbl, order};
end

headerFrame.Type       = 'group';
headerFrame.Name       = FilterDesignDialog.message('filtspecs');
headerFrame.Items      = items;
headerFrame.LayoutGrid = [3 4];
headerFrame.ColStretch = [0 1 0 1];
headerFrame.Tag        = 'FilterSpecsGroup';

% [EOF]
