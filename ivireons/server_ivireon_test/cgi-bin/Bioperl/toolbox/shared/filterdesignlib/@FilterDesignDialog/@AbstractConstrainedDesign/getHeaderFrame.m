function headerFrame = getHeaderFrame(this)
%GETHEADERFRAME   Get the headerFrame.

%   Author(s): J. Schickler
%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/04/21 04:21:04 $

[irtype_lbl, irtype] = getWidgetSchema(this, 'ImpulseResponse', ...
    FilterDesignDialog.message('impresp'), 'combobox', 1, 1);
irtype.Entries        = { ...
    FilterDesignDialog.message('fir'), ...
    FilterDesignDialog.message('iir')};
irtype.DialogRefresh  = true;

orderwidgets = getOrderWidgets(this, 2, true);

if isfdtbxdlg(this)
    ftypewidgets = getFilterTypeWidgets(this, 3);
end

headerFrame.Type       = 'group';
headerFrame.Name       = FilterDesignDialog.message('filtspecs');

if isfdtbxdlg(this)
    headerFrame.Items      = {irtype_lbl, irtype, orderwidgets{:}, ftypewidgets{:}}; %#ok<CCAT>
    headerFrame.LayoutGrid = [3 4];
else
    headerFrame.Items      = {irtype_lbl, irtype, orderwidgets{:}}; %#ok<CCAT>
    headerFrame.LayoutGrid = [2 4];
end
headerFrame.ColStretch = [0 1 0 1];
headerFrame.Tag        = 'FilterSpecsGroup';

% [EOF]
