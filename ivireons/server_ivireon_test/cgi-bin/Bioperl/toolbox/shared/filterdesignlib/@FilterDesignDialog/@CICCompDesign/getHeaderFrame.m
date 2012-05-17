function headerFrame = getHeaderFrame(this)
%GETHEADERFRAME   Get the headerFrame.

%   Author(s): J. Schickler
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2009/05/23 08:10:49 $

orderwidgets = getOrderWidgets(this, 1, true);
ftypewidgets = getFilterTypeWidgets(this, 2);

[nsecs_lbl, nsecs] = getWidgetSchema(this, 'NumberOfSections', ...
    FilterDesignDialog.message('NumCICSections'), 'combobox', 4, 1);

tunable = ~isminorder(this);

nsecs_lbl.Tunable = tunable;

nsecs.Editable       = true;
nsecs.Entries        = {'1','2','3','4','5','6','7','8'};
nsecs.Tunable        = tunable;

[diffdelay_lbl, diffdelay] = getWidgetSchema(this, 'DifferentialDelay', ...
    FilterDesignDialog.message('DifferentialDelay'), 'combobox', 4, 3);

diffdelay_lbl.Tunable = tunable;

diffdelay.Editable       = true;
diffdelay.Entries        = {'1','2'};
diffdelay.Tunable        = tunable;

headerFrame.Type       = 'group';
headerFrame.Name       = FilterDesignDialog.message('filtspecs');
headerFrame.Items      = {orderwidgets{:}, ftypewidgets{:}, nsecs_lbl, nsecs, ...
    diffdelay_lbl, diffdelay}; %#ok<CCAT>
headerFrame.LayoutGrid = [4 4];
headerFrame.ColStretch = [0 1 0 1];
headerFrame.Tag        = 'FilterSpecsGroup';

% [EOF]
