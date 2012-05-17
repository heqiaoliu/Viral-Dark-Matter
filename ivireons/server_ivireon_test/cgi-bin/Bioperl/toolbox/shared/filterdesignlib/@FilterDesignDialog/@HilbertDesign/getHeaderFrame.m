function headerFrame = getHeaderFrame(this)
%GETHEADERFRAME   Get the headerFrame.

%   Author(s): Nan Li
%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/04/21 04:22:37 $

if isfdtbxdlg(this)
    [irtype_lbl, irtype] = getWidgetSchema(this, 'ImpulseResponse', ...
        FilterDesignDialog.message('impresp'), 'combobox', 1, 1);
    
    irtype.Entries        = FilterDesignDialog.message({'fir', 'iir'});
    irtype.DialogRefresh  = true;
    
    orderwidgets = getOrderWidgets(this, 2, true);
    ftypewidgets = getFilterTypeWidgets(this, 3);    
else
    orderwidgets = getOrderWidgets(this, 2, false);
end

headerFrame.Type       = 'group';
headerFrame.Name       = FilterDesignDialog.message('filtspecs');

if isfdtbxdlg(this)
    headerFrame.Items      = {irtype_lbl, irtype, orderwidgets{:}, ftypewidgets{:}}; %#ok<CCAT>
    headerFrame.LayoutGrid = [3 4];
else
    headerFrame.Items      = {orderwidgets{:}}; %#ok<CCAT>
    headerFrame.LayoutGrid = [1 4];
end
headerFrame.ColStretch = [0 1 0 1];
headerFrame.Tag        = 'FilterSpecsGroup';

% [EOF]
