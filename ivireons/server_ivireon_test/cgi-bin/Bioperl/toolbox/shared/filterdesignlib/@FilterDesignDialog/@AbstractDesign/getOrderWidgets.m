function varargout = getOrderWidgets(this, row, allowsMinOrd)
%GETORDERWIDGETS Get the orderWidgets.

%   Author(s): J. Schickler
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/04/21 04:21:16 $

if nargin < 3
    allowsMinOrd = true;
end

col = 1;

% If this dialog allows minimum order, put up the OrderMode widgets.
if allowsMinOrd

    % Define the ordermode widgets with GETWIDGETSCHEMA.
    [ordermode_lbl, ordermode] = getWidgetSchema(this, 'OrderMode', ...
        FilterDesignDialog.message('ordermode'), 'combobox', row, col);
    
    % Force a refresh when the order mode changes to enable the order.
    ordermode.DialogRefresh = true;
    orderMode = set(this, 'OrderMode');
    ordermode.Entries = FilterDesignDialog.message(orderMode);     
    
    col = col+2;
    
    orderWidgets = {ordermode_lbl, ordermode};
else
    orderWidgets = {};
end

% Define the order widgets.
[order_lbl, order] = getWidgetSchema(this, 'Order', ...
    FilterDesignDialog.message('order'), ...
    'edit', row, col);

% If we are minimum order mode disable the order and its label.
if allowsMinOrd && isminorder(this)
    order_lbl.Enabled = false;
    order.Enabled     = false;

    % Remove the object property when we disable.  This will suppress the
    % display of the stored order.  We do this because the stored order is
    % not the order that we will end up using.
    order = rmfield(order, 'ObjectProperty');
end

orderWidgets = {orderWidgets{:}, order_lbl, order}; %#ok<CCAT>

% If the caller requested more than 1 output, return the widgets in
% separate outputs, otherwise return a cell array.
if nargout > 1
    varargout = orderWidgets;
else
    varargout = {orderWidgets};
end

% [EOF]
