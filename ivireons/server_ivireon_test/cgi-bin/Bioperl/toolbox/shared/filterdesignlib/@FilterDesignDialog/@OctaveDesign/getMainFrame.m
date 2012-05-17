function main = getMainFrame(this)
%GETDIALOGSCHEMA   Get the dialog information.

%   Author(s): J. Schickler
%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/04/21 04:23:07 $

% Add the order widgets.
[order_lbl, order] = getOrderWidgets(this, 1, false);

% Convert to an editable comboboxes with a few reasonable values.
order.Type     = 'combobox';
order.Entries  = {'4','6','8','10'};
order.Editable = true;

% Render "BandsPerOctave"
[bands_lbl, bands] = getWidgetSchema(this, 'BandsPerOctave', ...
    FilterDesignDialog.message('BandsPerOctave'), 'combobox', 2, 1);

% Add the combobox entries and make it editable.
bands.Editable      = true;
bands.Entries       = {'1', '3', '6', '12', '24'}; % <-- Typical values
bands.DialogRefresh = true;
bands.Tunable       = true;
bands_lbl.Tunable   = true;

items = getFrequencyUnitsWidgets(this, 3);
items{2}.DialogRefresh = true;
items{2}.Entries       = items{2}.Entries(2:3);

% 
Freq = set(this, 'FrequencyUnits');
Freq = Freq(2:3);
    % set default FrequencyUnits on the top
    defaultindx = find(strcmpi(Freq,this.FrequencyUnits));
    if ~isempty(defaultindx)
    items{2}.Value = defaultindx - 1;
    end
    items{2}.ObjectMethod = 'selectComboboxEntry';
    items{2}.MethodArgs  = {'%dialog', '%value', 'FrequencyUnits', ...
        Freq};
    items{2}.ArgDataTypes = {'handle', 'mxArray', 'string', 'mxArray'};
    
    % Turn off immediate mode, since the since the appropriate UDD
    % property is set in the associated callback selectComboboxEntry.
    items{2}.Mode = false; 
    
    % Remove the ObjectProperty for this widget since the appropriate UDD
    % property is set in the associated callback selectComboboxEntry.
    items{2} = rmfield(items{2},  'ObjectProperty'); 

%
items{4}.DialogRefresh = true;


% Add the center frequency combobox.
[centerfreq_lbl, centerfreq] = getWidgetSchema(this, 'F0', ...
    FilterDesignDialog.message('CenterFrequency'), 'combobox', 4, 1);

if isfdtbxinstalled

    % Get the center frequency values from the FDesign.
    validFreqs = validfrequencies(getFDesign(this, this));
    entries = cell(1, length(validFreqs));
    for indx = 1:length(validFreqs)
        entries{indx} = num2str(validFreqs(indx), 5);
    end
else
    entries = {'1000'};
end

% Convert the entries to the units specified by the user.
entries = convertfrequnits(entries, 'Hz', this.FrequencyUnits);

centerfreq.Editable = true;
centerfreq.Entries  = entries;
centerfreq.Tunable  = true;

centerfreq_lbl.Tunable = true;

items = {bands_lbl, bands, order_lbl, order, items{:}, centerfreq_lbl, centerfreq};

fspecs.Type       = 'group';
fspecs.Name       = FilterDesignDialog.message('filtspecs');
fspecs.Items      = items;
fspecs.LayoutGrid = [3 4];
fspecs.ColStretch = [0 1 0 1];
fspecs.RowSpan    = [1 1];
fspecs.ColSpan    = [1 1];
fspecs.Tag        = 'MainGroup';

design         = getDesignMethodFrame(this);
design.RowSpan = [2 2];
design.ColSpan = [1 1];

main.Type = 'panel';
main.Items = {fspecs, design};

% [EOF]
