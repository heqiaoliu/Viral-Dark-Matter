function headerFrame = getHeaderFrame(this)
%GETHEADERFRAME Get the headerFrame.

%   Author(s): J. Schickler
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/05/23 08:10:54 $

[rtype_lbl, rtype] = getWidgetSchema(this, 'ResponseType', FilterDesignDialog.message('Response'), ...
    'combobox', 1, 1);

rtype_lbl.Tunable = true;
rtype.Entries       = FilterDesignDialog.message(lower({'Peak', 'Notch'}));
rtype.DialogRefresh = true;
rtype.Tunable       = true;

% %
[order_lbl, order] = getOrderWidgets(this, 2, false);

order_lbl.RowSpan = [1 1];
order_lbl.ColSpan = [3 3];
order.RowSpan     = [1 1];
order.ColSpan     = [4 4];

headerFrame.Type       = 'group';
headerFrame.Name       = FilterDesignDialog.message('filtspecs');
headerFrame.Items      = {rtype_lbl, rtype, order_lbl, order};
headerFrame.LayoutGrid = [3 4];
headerFrame.ColStretch = [0 1 0 1];
headerFrame.Tag        = 'FilterSpecsGroup';

% [EOF]
