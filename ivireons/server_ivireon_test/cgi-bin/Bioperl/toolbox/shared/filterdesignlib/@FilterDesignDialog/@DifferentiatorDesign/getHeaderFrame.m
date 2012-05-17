function headerFrame = getHeaderFrame(this)
%GETHEADERFRAME   Get the headerFrame.

%   Author(s): J. Schickler
%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/04/21 04:22:09 $

if isfdtbxdlg(this)
    orderwidgets = getOrderWidgets(this, 1, true);
    ftypewidgets = getFilterTypeWidgets(this, 2);
else
    orderwidgets = getOrderWidgets(this, 1, false);
end

headerFrame.Type       = 'group';
headerFrame.Name       = FilterDesignDialog.message('filtspecs');
if isfdtbxdlg(this)
    headerFrame.Items      = {orderwidgets{:}, ftypewidgets{:}}; %#ok<CCAT>
    headerFrame.LayoutGrid = [2 4];
else
    headerFrame.Items      = {orderwidgets{:}}; %#ok<CCAT>
    headerFrame.LayoutGrid = [1 4];
end
headerFrame.ColStretch = [0 1 0 1];
headerFrame.Tag        = 'FilterSpecsGroup';

% [EOF]
