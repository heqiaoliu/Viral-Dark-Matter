function mainFrame = getMainFrame(this)
%GETMAINFRAME Get the mainFrame.

%   Author(s): J. Schickler
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/05/23 08:10:50 $

[ftype_lbl, ftype] = getWidgetSchema(this, 'FilterType',  ...
    FilterDesignDialog.message('filttype'), ...
    'combobox', 1, 1);

options = {'Decimator', 'Interpolator'};
ftype.Entries        = FilterDesignDialog.message(strrep(options, ' ', ''));
ftype.DialogRefresh  = true;

ftype.ObjectMethod = 'selectComboboxEntry';
ftype.MethodArgs  = {'%dialog', '%value','FilterType', options};
ftype.ArgDataTypes = {'handle', 'mxArray', 'string', 'mxArray'};

% Turn off immediate mode, since the since the appropriate UDD
% property is set in the associated callback selectComboboxEntry.
ftype.Mode = false;

% Remove the ObjectProperty for this widget since the appropriate UDD
% property is set in the associated callback selectComboboxEntry.
ftype = rmfield(ftype, 'ObjectProperty');

%set default Type on top
indx = find(strcmp(options, this.FilterType));
if ~isempty(indx)
ftype.Value = indx - 1;
end

[factor_lbl, factor] = getWidgetSchema(this, 'Factor',  ...
    FilterDesignDialog.message('Factor'), ...
    'edit', 1, 3);

[ddelay_lbl, ddelay] = getWidgetSchema(this, 'DifferentialDelay', ...
    FilterDesignDialog.message('DifferentialDelay'), 'edit', 2, 1);

items = {ftype_lbl, ftype, factor_lbl, factor, ddelay_lbl, ddelay};

items = getFrequencyUnitsWidgets(this, 3, items);

[fpass_lbl, fpass] = getWidgetSchema(this, 'Fpass', FilterDesignDialog.message('Fpass'), ...
    'edit', 4, 1);
items = {items{:}, fpass_lbl, fpass}; %#ok<CCAT>

items = getMagnitudeUnitsWidgets(this, 5, items);

[fstop_lbl, fstop] = getWidgetSchema(this, 'Astop', FilterDesignDialog.message('Astop'), ...
    'edit', 6, 1);
items = {items{:}, fstop_lbl, fstop}; %#ok<CCAT>

mainFrame.Type       = 'group';
mainFrame.Name       = FilterDesignDialog.message('freqspecs');
mainFrame.Items      = items;
mainFrame.LayoutGrid = [7 4];
mainFrame.RowStretch = [0 0 0 0 0 0 1];
mainFrame.ColStretch = [0 1 0 1];
mainFrame.Tag        = 'MainGroup';

% [EOF]
