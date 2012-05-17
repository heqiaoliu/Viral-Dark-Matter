function filterTypeWidgets = getFilterTypeWidgets(this, row)
%GETFILTERTYPEWIDGETS Get the filterTypeWidgets.

%   Author(s): J. Schickler
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2009/05/23 08:10:47 $

[ftype_lbl, ftype] = getWidgetSchema(this, 'FilterType', ...
    FilterDesignDialog.message('filttype'), ...
    'combobox', row, 1);

ftypes = set(this, 'FilterType')';
if strcmpi(this.ImpulseResponse, 'iir')
    ftypes(end) = []; % Remove SRC
end
ftypes = strrep(ftypes, ' ', '');

% populate the entries of the combobox from the xlate file. 
ftype.Entries        = FilterDesignDialog.message(ftypes);
ftype.DialogRefresh  = true;

if ~allowsMultirate(this)
    ftype.Enabled = false;
end

% Put up widgets for the factors depending on which type was chosen.
switch lower(this.FilterType)
    case {'decimator', 'interpolator'}
        str = lower(this.FilterType);
        str = [str(1:5) 'f'];
        [factor_lbl, factor] = getWidgetSchema(this, ...
            'Factor', FilterDesignDialog.message(str), 'edit', row, 3);
        filterTypeWidgets = {ftype_lbl, ftype, factor_lbl, factor};
    case {'sample-rate converter'}
        [ifactor_lbl, ifactor] = getWidgetSchema(this, ...
            'Factor', FilterDesignDialog.message('interf'), 'edit', row, 3);
        [dfactor_lbl, dfactor] = getWidgetSchema(this, ...
            'SecondFactor', FilterDesignDialog.message('decimf'), 'edit', row+1, 3);
        filterTypeWidgets = {ftype_lbl, ftype, ...
            ifactor_lbl, ifactor, dfactor_lbl, dfactor};
    otherwise
        filterTypeWidgets = {ftype_lbl, ftype};
end

% [EOF]
