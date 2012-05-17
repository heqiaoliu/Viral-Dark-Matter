function main = getMainFrame(this)
%GETMAINFRAME   Get the dialog information.

%   Author(s): J. Schickler
%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/04/21 04:22:21 $

if ~strcmpi(this.OperatingMode, 'simulink')

    items = getFrequencyUnitsWidgets(this, 1);

    [fracdelay_lbl, fracdelay] = getWidgetSchema(this, 'FracDelay', ...
        FilterDesignDialog.message('FracDelay'), 'edit', 2, 1);

    items = {items{:}, fracdelay_lbl, fracdelay}; %#ok<CCAT>
else
    items = {};
end

orderwidgets = getOrderWidgets(this, 3, false);

order          = orderwidgets{2};
order.Type     = 'combobox';
order.Entries  = {'1','2','3','4','5','6'};
order.Editable = true;

orderwidgets{2} = order;

items = {items{:}, orderwidgets{:}}; %#ok<CCAT>

main.Type       = 'group';
main.Name       = FilterDesignDialog.message('filtspecs');
main.Items      = items;
main.LayoutGrid = [4 4];
main.RowStretch = [0 0 0 1];
main.ColStretch = [0 1 0 1];
main.Tag        = 'MainGroup';

% [EOF]
