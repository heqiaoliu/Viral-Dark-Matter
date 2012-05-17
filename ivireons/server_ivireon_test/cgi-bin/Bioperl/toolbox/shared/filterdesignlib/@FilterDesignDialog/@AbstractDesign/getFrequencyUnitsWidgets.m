function items = getFrequencyUnitsWidgets(this, startrow, items)
%GETFREQUENCYUNITSWIDGETS   Get the frequencyUnitsWidgets.

%   Author(s): J. Schickler
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2009/04/21 04:21:13 $

if nargin < 3
    items = {};
    if nargin < 2
        startrow = 1;
    end
end

tunable = ~isminorder(this);

[fsunits_lbl, fsunits] = getWidgetSchema(this, 'FrequencyUnits', ...
    FilterDesignDialog.message('frequnits'), ...
    'combobox', startrow, 1);

fsunits_lbl.Tunable = tunable;

fsunits.DialogRefresh  = true;
options  = set(this, 'FrequencyUnits');

for i = 1:length(options)
    if numel(options{i})> 4
        options{i} = options{i}(1:4);
    end
    options{i} = FilterDesignDialog.message(lower(options{i}));
end
fsunits.Entries = options;

% set default Frequency units on the top
defaultindx = find(strcmpi(set(this, 'FrequencyUnits'), ...
    this.FrequencyUnits));
if ~isempty(defaultindx)
fsunits.Value = defaultindx - 1;
end

fsunits.Tunable = tunable;

if strcmpi(this.FilterType, 'Interpolator')
    str = 'outFs';
else
    str = 'inpFs';
end

[fs_lbl, fs] = getWidgetSchema(this, 'InputSampleRate',  ...
    FilterDesignDialog.message(str), 'edit', ...
    startrow, 3);

fs_lbl.ToolTip = 'Input sample rate';
fs_lbl.Tunable = tunable;

fs.Editable = true;
fs.Tunable  = tunable;

if strncmpi(this.FrequencyUnits, 'normalized', 10)
    fs.Enabled     = false;
    fs_lbl.Enabled = false;
else
    fs.ObjectProperty = fs.Tag;
end

items = {items{:}, fsunits_lbl, fsunits, fs_lbl, fs};

% [EOF]
