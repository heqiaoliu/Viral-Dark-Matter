function mainFrame = getMainFrame(this)
%GETMAINFRAME Get the mainFrame.

%   Author(s): J. Schickler
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/04/21 04:21:30 $

header = getHeaderFrame(this);
header.RowSpan = [1 1];
header.ColSpan = [1 1];
    
filtresp = getFilterRespFrame(this);
filtresp.RowSpan = [2 2];
filtresp.ColSpan = [1 1];

design = getDesignMethodFrame(this);
design.RowSpan = [3 3];
design.ColSpan = [1 1];

mainFrame.Type       = 'panel';
mainFrame.Items      = {header, filtresp, design};
mainFrame.LayoutGrid = [5 1];
mainFrame.RowStretch = [0 0 0 0 3];
mainFrame.Tag        = 'Main';


% -------------------------------------------------------------------------
function headerFrame = getHeaderFrame(this)

if isfdtbxdlg(this)
    [irtype_lbl, irtype] = getWidgetSchema(this, 'ImpulseResponse', ...
        FilterDesignDialog.message('impresp'), 'combobox', 1, 1);
    irtype.Entries       = FilterDesignDialog.message(lower({'FIR', 'IIR'}));
    irtype.DialogRefresh = true;
end

[order_lbl, order] = getWidgetSchema(this, 'Order', FilterDesignDialog.message('order'), 'edit', 2, 1);

if isfdtbxdlg(this)
    dorder_lbl.Name           = FilterDesignDialog.message('DenOrder');
    dorder_lbl.Type           = 'checkbox';
    dorder_lbl.Source         = this;
    dorder_lbl.Mode           = true;
    dorder_lbl.DialogRefresh  = true;
    dorder_lbl.RowSpan        = [3 3];
    dorder_lbl.ColSpan        = [1 1];
    dorder_lbl.Enabled        = this.Enabled;
    dorder_lbl.Tag            = 'SpecifyDenominator';
    
    if strcmpi(this.ImpulseResponse, 'iir')
        dorder_lbl.ObjectProperty = 'SpecifyDenominator';
    else
        dorder_lbl.Enabled = false;
    end
    
    dorder.Type          = 'edit';
    dorder.Source        = this;
    dorder.Mode          = true;
    dorder.DialogRefresh = true;
    dorder.RowSpan       = [3 3];
    dorder.ColSpan       = [2 2];
    dorder.Enabled       = this.Enabled;
    dorder.Tag           = 'DenominatorOrder';
    
    if this.SpecifyDenominator && strcmpi(this.ImpulseResponse, 'iir')
        dorder.ObjectProperty = 'DenominatorOrder';
    else
        dorder.Enabled = false;
    end
    
    ftype_widgets = getFilterTypeWidgets(this, 4);
end

headerFrame.Type       = 'group';
headerFrame.Name       = FilterDesignDialog.message('filtspecs');
if isfdtbxdlg(this)
    headerFrame.Items      = {irtype_lbl, irtype, order_lbl, order, dorder_lbl, ...
        dorder, ftype_widgets{:}};
    headerFrame.LayoutGrid = [5 4];
    headerFrame.ColStretch = [0 1 0 1];
else
    headerFrame.Items      = {order_lbl, order};
    headerFrame.LayoutGrid = [2 4];
    headerFrame.ColStretch = [0 1 0 1];
end
headerFrame.Tag        = 'FilterSpecsGroup';

% -------------------------------------------------------------------------
function filtresp = getFilterRespFrame(this)

[nbands_lbl, nbands] = getWidgetSchema(this, 'NumberOfBands', FilterDesignDialog.message('NumBands'), ...
    'combobox', 1, 1);
nbands.Entries = {'1','2','3','4','5','6','7','8','9','10'};
nbands.DialogRefresh = true;

if ~this.isfir && ...
        ~strcmpi(this.ResponseType, 'amplitudes')
    nbands_lbl.Enabled = false;
    nbands.Enabled     = false;
end

[response_lbl, response] = getWidgetSchema(this, 'ResponseType', FilterDesignDialog.message('RespType'), ...
    'combobox', 2, 1);
response.DialogRefresh = true;
respType = set(this, 'ResponseType');

if ~isfdtbxdlg(this)
    respType(2:end) = [];
end
respType = cellfun(@(x)x(1:4), respType, 'UniformOutput', 0);
response.Entries = FilterDesignDialog.message(lower(respType));

if ~this.isfir && ...
        this.NumberOfBands > 0
    response_lbl.Enabled = false;
    response.Enabled     = false;
end

items = {nbands_lbl, nbands, response_lbl, response};

items = getFrequencyUnitsWidgets(this, 3, items);
items{end-3}.Tunable     = false;
items{end-2}.Tunable     = false;
items{end-1}.Tunable     = false;
items{end}.Tunable       = false;
items{end}.DialogRefresh = true;

spacer.Type = 'text';
spacer.Name = ' ';
spacer.RowSpan = [4 4];
spacer.ColSpan = [1 4];

band_label.Type = 'text';
band_label.Name = FilterDesignDialog.message('BandProps');
band_label.RowSpan = [5 5];
band_label.ColSpan = [1 4];

band_table = getBandTable(this);
band_table.RowSpan = [6 6];
band_table.ColSpan = [1 4];

items = {items{:}, spacer, band_label, band_table};

filtresp.Type       = 'group';
filtresp.Name       = FilterDesignDialog.message('respspecs');
filtresp.Items      = items;
filtresp.LayoutGrid = [6 4];
filtresp.ColStretch = [0 0 0 4];
filtresp.Tag        = 'FilterSpecsGroup';

% -------------------------------------------------------------------------
function band_table = getBandTable(this)

nBands = this.NumberOfBands+1;
switch lower(this.responseType)
    case 'amplitudes'
        colHeaders = {FilterDesignDialog.message('Frequencies'), ...
            FilterDesignDialog.message('Amplitudes')};
    case 'magnitudes and phases'
        colHeaders = {FilterDesignDialog.message('Frequencies'), ...
            FilterDesignDialog.message('Magnitudes'), ...
            FilterDesignDialog.message('Phases')};
    case 'frequency response'
        colHeaders = {FilterDesignDialog.message('Frequencies'), ...
            FilterDesignDialog.message('FrequencyResponse')};
end
nCols = length(colHeaders);

rowHeaders = cell(1, nBands);
for indx = 1:nBands;
    rowHeaders{indx} = sprintf('%d', indx);
end

band_table.Type                       = 'table';
band_table.Tag                        = 'BandTable';
band_table.Size                       = [nBands nCols];
band_table.ColHeader                  = colHeaders;
band_table.RowHeader                  = rowHeaders;
band_table.Grid                       = true;
band_table.RowHeaderWidth             = 2;
band_table.ColumnCharacterWidth       = repmat(36/nCols, 1, nCols);
band_table.ValueChangedCallback       = ...
    @(hdlg, row, col, value) onValueChanged(this, row, col, value);
band_table.Editable                   = this.Enabled;
band_table.Tunable                    = true;

data = cell(nBands, nCols);
for indx = 1:nBands
    data(indx, :) = getTableRowSchema(this.(sprintf('Band%d', indx)), ...
        this.ResponseType, indx);
end

band_table.Data = data;

% -------------------------------------------------------------------------
function onValueChanged(this, row, col, value)

prop = sprintf('Band%d', row+1);

hBand = get(this, prop);

switch col
    case 0
        set(hBand, 'Frequencies', value);
        updateMethod(this);
    case 1
        switch this.ResponseType
            case 'Amplitudes'
                set(hBand, 'Amplitudes', value);
            case 'Magnitudes and phases'
                set(hBand, 'Magnitudes', value);
            case 'Frequency response'
                set(hBand, 'FreqResp', value);
        end
    case 2
        set(hBand, 'Phases', value);
end

% [EOF]
