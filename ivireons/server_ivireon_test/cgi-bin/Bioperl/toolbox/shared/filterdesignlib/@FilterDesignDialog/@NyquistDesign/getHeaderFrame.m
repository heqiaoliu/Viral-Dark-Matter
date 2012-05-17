function headerFrame = getHeaderFrame(this)
%GETHEADERFRAME   Get the headerFrame.

%   Author(s): J. Schickler
%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2009/12/28 04:33:21 $

[band_lbl, band] = getWidgetSchema(this, 'Band', FilterDesignDialog.message('Band'), 'edit', 1, 1);

band.DialogRefresh  = true;

[irtype_lbl, irtype] = getWidgetSchema(this, 'ImpulseResponse', ...
    FilterDesignDialog.message('impresp'), 'combobox', 2, 1);

try
    bandvalue = evaluatevars(this.Band);
catch %#ok<CTCH>
    
    % If we cannot evaluate the Band setting, assume that it is not 2.
    % This will disable the IRType popup and keep us from getting into a
    % bad state.
    bandvalue = 3;
end

irtype.Entries        = FilterDesignDialog.message({'fir', 'iir'});
irtype.DialogRefresh  = true;

if bandvalue == 2
    irtype.Enabled = this.Enabled;
else
    irtype.Enabled = false;
end

[ordermode_lbl, ordermode] = getWidgetSchema(this, 'OrderMode', ...
    FilterDesignDialog.message('FiltOrderMode'), 'combobox', 3, 1);

ordermode.DialogRefresh  = true;
ordermode.Entries        = FilterDesignDialog.message({'Minimum', 'Specify'});

[order_lbl, order] = getWidgetSchema(this, 'Order', FilterDesignDialog.message('order'), 'edit', 3, 3);

if isminorder(this)
    order_lbl.Visible = false;
    order.Visible     = false;
end

ftype_widgets = getFilterTypeWidgets(this, 4);
if (strcmpi(this.FilterType,'decimator') || ...
        strcmpi(this.FilterType,'interpolator')) && ...
        strcmpi(this.ImpulseResponse,'iir')
    this.Factor = '2';
    ftype_widgets{4}.Enabled = false;
end

headerFrame.Type       = 'group';
headerFrame.Name       = FilterDesignDialog.message('filtspecs');
headerFrame.Items      = {band_lbl, band, irtype_lbl, irtype, ordermode_lbl, ...
    ordermode, order_lbl, order, ftype_widgets{:}}; %#ok<CCAT>
headerFrame.LayoutGrid = [5 4];
headerFrame.ColStretch = [0 1 0 1];
headerFrame.Tag        = 'FilterSpecsGroup';

% [EOF]
