function headerFrame = getHeaderFrame(this)
%GETHEADERFRAME Get the headerFrame.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/04/21 04:23:27 $


[irtype_lbl, irtype] = getWidgetSchema(this, 'PulseShape', ...
    FilterDesignDialog.message('PulseShape'), 'combobox', 1, 1);
irtype.Entries = getEntries(set(this, 'PulseShape'));

%set default PulseShape on top
indx = find(strcmp(set(this, 'PulseShape'), this.PulseShape));
if ~isempty(indx)
irtype.Value = indx - 1;
end
irtype.DialogRefresh  = true;

[ordermode_lbl, ordermode] = getWidgetSchema(this, 'OrderMode2', ...
    FilterDesignDialog.message('ordermode'), 'combobox', 2, 1);
if strcmpi(this.PulseShape, 'gaussian')
    options = {'Specify symbols'};
    ordermode.Entries = getEntries(options);
    ordermode.Enabled = false;
else
    options = {'Minimum', 'Specify order', 'Specify symbols'};
    ordermode.Entries = getEntries(options);
    %set default OrderMode2 on top
    indx = find(strcmp(options, this.OrderMode2));
    if ~isempty(indx)
    ordermode.Value = indx - 1;
    end
end
ordermode.DialogRefresh = true;

%
ordermode.ObjectMethod = 'selectComboboxEntry';
ordermode.MethodArgs  = {'%dialog', '%value','Ordermode2', ...
    options};
ordermode.ArgDataTypes = {'handle', 'mxArray', 'string', 'mxArray'};

% Turn off immediate mode, since the since the appropriate UDD
% property is set in the associated callback selectComboboxEntry.
ordermode.Mode = false;

% Remove the ObjectProperty for this widget since the appropriate UDD
% property is set in the associated callback selectComboboxEntry.
ordermode = rmfield(ordermode, 'ObjectProperty');


switch lower(this.OrderMode2)
    case 'minimum'
        [order_lbl, order] = getWidgetSchema(this, 'Order', FilterDesignDialog.message('order'), 'edit', 2, 3);
        order              = rmfield(order, 'ObjectProperty');
        order_lbl.Enabled  = false;
        order.Enabled      = false;
    case 'specify order'
        [order_lbl, order] = getWidgetSchema(this, 'Order', FilterDesignDialog.message('order'), 'edit', 2, 3);
    case 'specify symbols'
        [order_lbl, order] = getWidgetSchema(this, 'NumberOfSymbols', ...
            FilterDesignDialog.message('NumSymbols'), 'edit', 2, 3);
end

[samples_lbl, samples] = getWidgetSchema(this, 'SamplesPerSymbol', ...
    FilterDesignDialog.message('SamplesPerSymbol'), 'edit', 3, 1);

if isfdtbxdlg(this)
    ftype_widgets = getFilterTypeWidgets(this, 4);
end

headerFrame.Type       = 'group';
headerFrame.Name       = FilterDesignDialog.message('filtspecs');

if isfdtbxdlg(this)
    headerFrame.Items      = [{irtype_lbl, irtype, ordermode_lbl, ordermode, ...
        order_lbl, order, samples_lbl, samples} ftype_widgets];
    headerFrame.LayoutGrid = [4 4];
else
    headerFrame.Items      = {irtype_lbl, irtype, ordermode_lbl, ordermode, ...
        order_lbl, order, samples_lbl, samples};
    headerFrame.LayoutGrid = [3 4];
end

headerFrame.ColStretch = [0 1 0 1];
headerFrame.Tag        = 'FilterSpecsGroup';
% ---

function Entries = getEntries(originalEntries)
Entries = originalEntries;

for i = 1:length(originalEntries)
indx = find(isspace(originalEntries{i}));
Entries{i}(indx+ 1) = upper(Entries{i}(indx+ 1));
Entries{i}(indx) = [];
Entries{i} = FilterDesignDialog.message(Entries{i});
end

% [EOF]
