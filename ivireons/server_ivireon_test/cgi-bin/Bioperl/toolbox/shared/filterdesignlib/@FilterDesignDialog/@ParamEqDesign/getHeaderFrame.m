function headerFrame = getHeaderFrame(this)
%GETHEADERFRAME Get the headerFrame.

%   Author(s): J. Schickler
%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/04/21 04:23:12 $

items = getOrderWidgets(this, 2, true);

headerFrame.Type       = 'group';
headerFrame.Name       = FilterDesignDialog.message('filtspecs');
headerFrame.Items      = items;
headerFrame.LayoutGrid = [3 4];
headerFrame.ColStretch = [0 1 0 1];
headerFrame.Tag        = 'FilterSpecsGroup';

% [EOF]
