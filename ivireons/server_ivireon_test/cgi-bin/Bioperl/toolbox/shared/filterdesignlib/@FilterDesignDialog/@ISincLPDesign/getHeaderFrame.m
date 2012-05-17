function headerFrame = getHeaderFrame(this)
%GETHEADERFRAME   Get the headerFrame.

%   Author(s): J. Schickler
%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/04/21 04:22:44 $

orderwidgets = getOrderWidgets(this, 1, true);
ftypewidgets = getFilterTypeWidgets(this, 2);

headerFrame.Type       = 'group';
headerFrame.Name       = FilterDesignDialog.message('filtspecs');
headerFrame.Items      = {orderwidgets{:}, ftypewidgets{:}}; %#ok<CCAT>
headerFrame.LayoutGrid = [4 4];
headerFrame.ColStretch = [0 1 0 1];
headerFrame.Tag        = 'FilterSpecsGroup';

% [EOF]
