function headerFrame = getHeaderFrame(this)
%GETHEADERFRAME   Get the headerFrame.

%   Author(s): J. Schickler
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2009/05/23 08:10:53 $

[irtype_lbl, irtype] = getWidgetSchema(this, 'ImpulseResponse', ...
    FilterDesignDialog.message('impresp'), 'combobox', 1, 1);

irtype.Entries        = FilterDesignDialog.message({'fir', 'iir'});
irtype.DialogRefresh  = true;

orderwidgets = getOrderWidgets(this, 2, true);

[type_lbl, type] = getWidgetSchema(this, 'Type', FilterDesignDialog.message('ResponseType'), ...
    'combobox', 3, 1);
type.Entries = FilterDesignDialog.message({'lp', 'hp'});
type.DialogRefresh = true;

options = {'Lowpass', 'Highpass'};
type.ObjectMethod = 'selectComboboxEntry';
type.MethodArgs  = {'%dialog', '%value','Type', options};
type.ArgDataTypes = {'handle', 'mxArray', 'string', 'mxArray'};

% Turn off immediate mode, since the since the appropriate UDD
% property is set in the associated callback selectComboboxEntry.
type.Mode = false;

% Remove the ObjectProperty for this widget since the appropriate UDD
% property is set in the associated callback selectComboboxEntry.
type = rmfield(type, 'ObjectProperty');

%set default Type on top
indx = find(strcmp(options, this.Type));
if ~isempty(indx)
type.Value = indx - 1;
end

[ftype_lbl, ftype] = getWidgetSchema(this, 'FilterType',  ...
    FilterDesignDialog.message('FilterType'), ...
    'combobox', 4, 1);

if strcmpi(this.Type, 'highpass') && strcmpi(this.ImpulseResponse, 'iir')
    ftype.Enabled = false;
    ftype_lbl.Enabled = false;
end

ftypes = set(this, 'FilterType')';

ftype.Entries        = FilterDesignDialog.message(strrep(ftypes(1:3), ' ', ''));
ftype.DialogRefresh  = true;

headerFrame.Type       = 'group';
headerFrame.Name       = FilterDesignDialog.message('freqspecs');
headerFrame.Items      = [{irtype_lbl, irtype}, orderwidgets, ...
    {type_lbl, type, ftype_lbl, ftype}];
headerFrame.LayoutGrid = [4 4];
headerFrame.ColStretch = [0 1 0 1];
headerFrame.Tag        = 'FilterSpecsGroup';

% [EOF]
