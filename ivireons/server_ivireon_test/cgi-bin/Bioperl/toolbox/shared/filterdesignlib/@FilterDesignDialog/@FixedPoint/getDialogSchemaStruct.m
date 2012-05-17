function dlg = getDialogSchemaStruct(this)
%GETDIALOGSCHEMASTRUCT   Get the dialogSchemaStruct.

%   Author(s): J. Schickler
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.11 $  $Date: 2009/12/28 04:33:17 $

arithlabel.Type    = 'text';
arithlabel.Name    = FilterDesignDialog.message('arithmeticLabelName');
arithlabel.Tag     = 'ArithmeticLabel';
arithlabel.RowSpan = [1 1];
arithlabel.ColSpan = [1 1];

arith.Type           = 'combobox';
arith.Tag            = 'Arithmetic';
arith.Source         = this;
arith.DialogRefresh  = true;
arith.RowSpan        = [1 1];
arith.ColSpan        = [2 2];
arith.Enabled        = isfdtbxinstalled;

arithModes = set(this, 'Arithmetic');
arithIDs = {'double', 'single', 'fixpt'};
% If fixpt isn't installed, remove it from the list.
if ~isfixptinstalled
    arithModes(end) = [];
    arithIDs(end) = [];
end

if ~isSupportedStructure(this)
    % If the structure does not support fixed-point the Arithmetic pop-up
    % is disabled.
    arithIDs = {'double','double','double'};
    arith.Enabled = false;
end

arith.Entries = FilterDesignDialog.message(arithIDs);
% set default Arithmetic property on top
defaultindx = find(strcmpi(arithModes,this.Arithmetic));
if ~isempty(defaultindx)
    arith.Value = defaultindx - 1;
end
%
arith.ObjectMethod = 'selectComboboxEntry';
arith.MethodArgs  = {'%dialog', '%value', 'Arithmetic', arithModes};
arith.ArgDataTypes = {'handle', 'mxArray', 'string', 'mxArray'};

%
if any(strcmpi(this.Structure, {'cicdecim', 'cicinterp'}))
    arith.Enabled = false;
end

spacer.Type        = 'text';
spacer.Name        = ' ';
spacer.RowSpan     = [2 2];
spacer.ColSpan     = [1 1];
spacer.MaximumSize = [10 10];

items = {arithlabel, arith, spacer};

if strcmpi(this.Arithmetic, 'fixed point')
    
    modelabel.Type = 'text';
    modelabel.Name = FilterDesignDialog.message('modeLabelTxt');
    modelabel.RowSpan = [1 1];
    modelabel.ColSpan = [2 2];
    modelabel.Alignment = 6;
    
    signlabel.Type = 'text';
    signlabel.Name = FilterDesignDialog.message('signLabelTxt');
    signlabel.RowSpan = [1 1];
    signlabel.ColSpan = [3 3];
    signlabel.Alignment = 6;
    
    wordlabel.Type = 'text';
    wordlabel.Name = FilterDesignDialog.message('wordLabelTxt');
    wordlabel.RowSpan = [1 1];
    wordlabel.ColSpan = [4 4];
    wordlabel.Alignment = 6;
    
    fraclabel.Type = 'text';
    fraclabel.Name = FilterDesignDialog.message('fracLabelTxt');
    fraclabel.RowSpan = [1 1];
    fraclabel.ColSpan = [5 5];
    fraclabel.Alignment = 6;
    
    opts = struct('Name', 'InputSignalName', 'Tag', 'Input', ...
        'Row', 3, 'Mode', 'BinaryPointScaling');
    [label, mode, signed, word, frac] = getFormatRow(this, opts);
    
    showOperationParameters = true;
    
    switch this.Structure
        case {'dffir', 'dffirt', 'dfsymfir', 'dfasymfir', 'firdecim', ...
                'firtdecim', 'firinterp', 'firsrc'}
            struct_items = getFIRItems(this, 4);
            
            if strcmpi(this.FilterInternals, 'full precision')
                showOperationParameters = false;
            end
            
        case 'df1'
            struct_items = getDF1Items(this, 5);
        case 'df2'
            struct_items = getDF2Items(this, 4);
        case 'df1t'
            struct_items = getDF1TItems(this, 4);
        case 'df2t'
            struct_items = getDF2TItems(this, 4);
        case 'df1sos'
            struct_items = getDF1SOSItems(this, 4);
        case 'df2sos'
            struct_items = getDF2SOSItems(this, 4);
        case 'df2tsos'
            struct_items = getDF2TSOSItems(this, 4);
        case 'df1tsos'
            struct_items = getDF1TSOSItems(this, 4);
        case {'cicdecim', 'cicinterp'}
            struct_items = getCICItems(this, 4);
            showOperationParameters = false;
        case {'fd','farrowfd'}
            struct_items = getFDItems(this, 4);
            if strcmpi(this.FilterInternals, 'full precision')
                showOperationParameters = false;
            end
            
        otherwise
            fprintf('%s not completed yet.', this.Structure);
    end
    
    dtype.Type  = 'group';
    dtype.Name  = FilterDesignDialog.message('FixedPtDType');
    dtype.Items = [{modelabel, signlabel, wordlabel, fraclabel, spacer ...
        label, mode, signed, word, frac}, struct_items];
    dtype.RowSpan    = [3 3];
    dtype.ColSpan    = [1 3];
    dtype.LayoutGrid = [20 5];
    dtype.RowStretch = [zeros(1, 19) 1];
    dtype.ColStretch = [0 0 0 1 1];
    
    items = [items {dtype}];
    
    if showOperationParameters
        opParams = getFixptOperationalParameters(this, 4);
        items = [items {opParams}];
    end
end

dlg.Type       = 'group';
dlg.Items      = items;
dlg.RowStretch = [zeros(1, 4) 1];
dlg.ColStretch = [0 0 1];
dlg.LayoutGrid = [5 3];

% -------------------------------------------------------------------------
function items = getFDItems(this, startrow)

opts.Row = startrow;

% Get the coefficient row
items = getCoeffRow(this, opts);

opts  = struct('Row', opts.Row+1, 'Name', 'FractionalDelay', 'Tag', 'FD');
items = getAutoRow(this, opts, items);

% The Fractional Delay is unsigned.
if strcmpi(this.FDMode, 'specify word length')
    items{end-1}.Name = FilterDesignDialog.message('no');
else
    items{end-2}.Name = FilterDesignDialog.message('no');
end

% Get the Filter Internals popup
[fintlabel, fint] = getFilterInternals(this, opts.Row+1);

items = [items {fintlabel, fint}];

% If we are in "specify precision" show the other rows.
if strcmpi(this.FilterInternals, 'specify precision')
    
    opts  = struct('Name', 'FixedPtProduct', 'Tag', 'Product','Row', fint.RowSpan(1)+1);
    items = getFormatRow(this, opts, items);
    
    opts  = struct('Name', 'FixedPtAccum', 'Tag', 'Accum', 'Row', opts.Row+1);
    items = getFormatRow(this, opts, items);
    
    opts  = struct('Name', 'Multiplicand', 'Tag', 'Multiplicand', 'Row', opts.Row+1);
    items = getFormatRow(this, opts, items);
    
    opts  = struct('Name', 'FDProduct', 'Tag', 'FDProd', 'Row', opts.Row+1);
    items = getFormatRow(this, opts, items);
    
    opts  = struct('Name', 'FixedPtOutput', 'Tag','Output', 'Row', opts.Row+1);
    items = getFormatRow(this, opts, items);
end

% -------------------------------------------------------------------------
function items = getDF1TItems(this, startrow)

% Add the coefficients
opts  = struct('Row', startrow, 'FracName',{{'Num.','Den.'}});
items = getCoeffRow(this, opts);

% Add Multiplicand
opts  = struct('Row', opts.Row+1, 'Name', 'Multiplicand', 'Tag', 'Multiplicand');
items = getFormatRow(this, opts, items);

% Add State
opts  = struct('Row', opts.Row+1, 'FracName',{{'Num.','Den.'}});
items = getStateRow(this, opts, true, items);

% Add Product
opts  = struct('Row', opts.Row+1, 'FracName',{{'Num.','Den.'}});
items = getProductRow(this, opts, items);

% Add Accum
opts  = struct('Row', opts.Row+1, 'FracName',{{'Num.','Den.'}});
items = getAccumRow(this, opts, items);

% Add Output
opts  = struct('Row', opts.Row+1);
items = getOutputRow(this, opts, items);

% -------------------------------------------------------------------------
function items = getDF1Items(this, startrow)

% Add the coefficients
opts  = struct('Row', startrow, 'FracName',{{'Num.','Den.'}});
items = getCoeffRow(this, opts);

% Add Product
opts  = struct('Row', opts.Row+1, 'FracName',{{'Num.','Den.'}});
items = getProductRow(this, opts, items);

% Add Accum
opts  = struct('Row', opts.Row+1, 'FracName',{{'Num.','Den.'}});
items = getAccumRow(this, opts, items);

% Add Output
opts  = struct('Row', opts.Row+1, 'Name', ...
    'FixedPtOutput','Tag', 'Output');

items = getFormatRow(this, opts, items);

% -------------------------------------------------------------------------
function items = getDF2Items(this, startrow)

% Add the coefficients
opts  = struct('Row', startrow, 'FracName',{{'Num.','Den.'}});
items = getCoeffRow(this, opts);

% Add State
opts  = struct('Row', opts.Row+1);
items = getStateRow(this, opts, false, items);

% Add Product
opts  = struct('Row', opts.Row+1, 'FracName',{{'Num.','Den.'}});
items = getProductRow(this, opts, items);

% Add Accum
opts  = struct('Row', opts.Row+1, 'FracName',{{'Num.','Den.'}});
items = getAccumRow(this, opts, items);

% Add Output
opts  = struct('Row', opts.Row+1);
items = getOutputRow(this, opts, items);

% -------------------------------------------------------------------------
function items = getDF2TItems(this, startrow)

% Add the coefficients
opts  = struct('Row', startrow, 'FracName',{{'Num.','Den.'}});
items = getCoeffRow(this, opts);

% Add State
opts  = struct('Row', opts.Row+1);
items = getStateRow(this, opts, true, items);

% Add Product
opts  = struct('Row', opts.Row+1, 'FracName',{{'Num.','Den.'}});
items = getProductRow(this, opts, items);

% Add Accum
opts  = struct('Row', opts.Row+1, 'FracName', 'FracName',{{'Num.','Den.'}});
items = getAccumRow(this, opts, items);

% Add Output
opts  = struct('Row', opts.Row+1, 'Name', ...
    'FixedPtOutput','Tag', 'Output');
items = getFormatRow(this, opts, items);

% -------------------------------------------------------------------------
function items = getDF1TSOSItems(this, startrow)

opts  = struct('Row', startrow, 'FracName',{{'Num.','Den.','ScaleValue'}});
items = getCoeffRow(this, opts);

% Add Section Input
opts  = struct('Row', opts.Row+1, 'Name', ...
    'SectionInput','Tag', 'SectionInput');
items = getAutoRow(this, opts, items);

% Add Section Output
opts  = struct('Row', opts.Row+1, 'Name', ...
    'SectionOutput','Tag', 'SectionOutput');
items = getAutoRow(this, opts, items);

% Add State
opts  = struct('Row', opts.Row+1, 'FracName',{{'Num.','Den.'}});
items = getStateRow(this, opts, true, items);

opts  = struct('Row', opts.Row+1, 'Name', ...
    'Multiplicand', 'Tag', 'Multiplicand' );
items = getFormatRow(this, opts, items);

% Add Product
opts  = struct('Row', opts.Row+1, 'FracName',{{'Num.','Den.'}});
items = getProductRow(this, opts, items);

% Add Accum
opts  = struct('Row', opts.Row+1, 'FracName',{{'Num.','Den.'}});
items = getAccumRow(this, opts, items);

% Add Output
opts  = struct('Row', opts.Row+1);
items = getOutputRow(this, opts, items);

% -------------------------------------------------------------------------
function items = getDF2TSOSItems(this, startrow)

opts  = struct('Row', startrow, 'FracName',{{'Num.','Den.','ScaleValue'}});
items = getCoeffRow(this, opts);

% Add Section Input
opts  = struct('Row', opts.Row+1, 'Name', ...
    'SectionInput', ...
    'Tag', 'SectionInput');
items = getFormatRow(this, opts, items);

% Add Section Output
opts  = struct('Row', opts.Row+1, 'Name', 'SectionOutput', ...
    'Tag','SectionOutput');
items = getFormatRow(this, opts, items);

% Add State
opts  = struct('Row', opts.Row+1);
items = getStateRow(this, opts, true, items);

% Add Product
opts  = struct('Row', opts.Row+1, 'FracName',{{'Num.','Den.'}});
items = getProductRow(this, opts, items);

% Add Accum
opts  = struct('Row', opts.Row+1, 'FracName',{{'Num.','Den.'}});
items = getAccumRow(this, opts, items);

% Add Output
opts  = struct('Row', opts.Row+1);
items = getOutputRow(this, opts, items);

% -------------------------------------------------------------------------
function items = getDF2SOSItems(this, startrow)

% Add the coefficients.
opts  = struct('Row', startrow, 'FracName',{{'Num.','Den.','ScaleValue'}});
items = getCoeffRow(this, opts);

% Add Section Input
opts  = struct('Row', opts.Row+1, 'Name', 'SectionInput', ...
    'Tag', 'SectionInput');
items = getAutoRow(this, opts, items);

% Add Section Output
opts  = struct('Row', opts.Row+1, 'Name', 'SectionOutput', ...
    'Tag','SectionOutput');
items = getAutoRow(this, opts, items);

% Add State
opts  = struct('Row', opts.Row+1);
items = getStateRow(this, opts, false, items);

% Add Product
opts  = struct('Row', opts.Row+1, 'FracName', {{'Num.', 'Den.'}});
items = getProductRow(this, opts, items);

% Add Accum
opts  = struct('Row', opts.Row+1, 'FracName', {{'Num.', 'Den.'}});
items = getAccumRow(this, opts, items);

% Add Output
opts  = struct('Row', opts.Row+1);
items = getOutputRow(this, opts, items);

% -------------------------------------------------------------------------
function items = getDF1SOSItems(this, startrow)

opts  = struct('Row', startrow, 'FracName',{{'Num.','Den.','ScaleValue'}});
items = getCoeffRow(this, opts);

% Add the State.
opts  = struct('Row', opts.Row+1, 'Name', {{'NumState', 'DenState' }});
items = getStateRow(this, opts, false, items);

% Add product
opts  = struct('Row', opts.Row+2, 'FracName', {{'Num.', 'Den.'}});

items = getProductRow(this, opts, items);

% Add Accumulator
opts  = struct('Row', opts.Row+2, 'FracName', {{'Num.', 'Den.'}});
items = getAccumRow(this, opts, items);

% Add Output
opts  = struct('Row', opts.Row+1);
items = getOutputRow(this, opts, items);

% -------------------------------------------------------------------------
function items = getFIRItems(this, startrow)

opts.Row = startrow;

% Get the coefficient row
items = getCoeffRow(this, opts);

% Get the Filter Internals popup
[fintlabel, fint] = getFilterInternals(this, opts.Row+1);

items = [items {fintlabel, fint}];

% If we are in "specify precision" show the other rows.
if strcmpi(this.FilterInternals, 'specify precision')
    
    opts  = struct('Name', 'FixedPtProduct',  ...
        'Tag','Product', ...
        'Row', fint.RowSpan(1)+1);
    items = getFormatRow(this, opts, items);
    
    opts  = struct('Name', 'FixedPtAccum', ...
        'Tag', 'Accum', 'Row', opts.Row+1);
    
    items = getFormatRow(this, opts, items);
    
    opts  = struct('Name', 'FixedPtOutput', ...
        'Tag', 'Output', 'Row', opts.Row+1);
    items = getFormatRow(this, opts, items);
end

% -------------------------------------------------------------------------
function items = getCICItems(this, startrow)

% Get the Filter Internals popup
[fintlabel, fint] = getFilterInternals(this, startrow);

items = {fintlabel, fint};

switch lower(this.FilterInternals)
    case 'minimum word lengths'
        opts  = struct('Name', 'FixedPtOutput', ...
            'Row', fint.RowSpan(1)+1, ...
            'Tag','Output');
        
        [label, mode, signed, word] = getFormatRow(this, opts);
        mode.Name = FilterDesignDialog.message('SpecifyWordLength');
        items = [items {label, mode, signed, word}];
    case 'specify word lengths'
        opts  = struct('Name', 'FixedPtOutput', ...
            'Row', fint.RowSpan(1)+1,'Tag','Output');
        
        [label, mode, signed, word] = getFormatRow(this, opts);
        mode.Name = FilterDesignDialog.message('SpecifyWordLength');
        items = [items {label, mode, signed, word}];
        
        opts  = struct('Name','Sections', ...
            'Tag','Sections','Row', fint.RowSpan(1)+2);
        
        [label, mode, signed, word] = getFormatRow(this, opts);
        mode.Name = FilterDesignDialog.message('SpecifyWordLength');
        items = [items {label, mode, signed, word}];
        
    case 'specify precision'
        opts  = struct('Name', 'FixedPtOutput', ...
            'Tag', 'Output', 'Row', fint.RowSpan(1)+1);
        
        
        [label, mode, signed, word, frac] = getFormatRow(this, opts);
        items = [items {label, mode, signed, word, frac}];
        
        opts  = struct('Name', 'Sections', ...
            'Row', fint.RowSpan(1)+2, 'Tag', 'Sections');
        
        
        [label, mode, signed, word, frac] = getFormatRow(this, opts);
        items = [items {label, mode, signed, word, frac}];
end

% -------------------------------------------------------------------------
function [label, mode, signed, word, frac] = getFormatRow(this, opts, items)

if nargin < 3
    items = {};
end

row  = opts.Row;
name = opts.Name;

if isfield(opts, 'Tag')
    tag = opts.Tag;
else
    tag = strrep(name, ' ', '');
end

if isfield(opts, 'FracName')
    fracNames = opts.FracName;
else
    fracNames = {tag};
end

enabState = isfdtbxinstalled;

label.Type    = 'text';
label.Name    = [FilterDesignDialog.message(name) ' '];
label.ColSpan = [1 1];
label.RowSpan = [row row];
label.Tag     = sprintf('%sLabel', tag);

mode.Type    = 'text';
mode.Name    = FilterDesignDialog.message('BinaryPointScaling');
mode.ColSpan = [2 2];
mode.RowSpan = [row row];
mode.Tag     = sprintf('%sMode', tag);
mode.Enabled = enabState;

signed.Type      = 'text';
signed.Name      = FilterDesignDialog.message('yes');
signed.ColSpan   = [3 3];
signed.RowSpan   = [row row];
signed.Alignment = 6;
signed.Tag       = sprintf('%sSigned', tag);
signed.Enabled   = enabState;

word.Type           = 'edit';
word.ObjectProperty = sprintf('%sWordLength', tag);
word.Tag            = sprintf('%sWordLength', tag);
word.Source         = this;
word.ColSpan        = [4 4];
word.RowSpan        = [row row];
word.Mode           = true;
word.Enabled        = enabState;

if length(fracNames) > 1
    
    items = cell(1, 2*numel(fracNames));
    for indx = 1:numel(fracNames)
        
        itemlabel.Type = 'text';
        itemlabel.Name = sprintf('%s: ', FilterDesignDialog.message(fracNames{indx}));
        itemlabel.ColSpan = [1 1];
        itemlabel.RowSpan = [indx indx];
        itemlabel.Tag     = sprintf('%sFracLengthLabel%d', tag, indx);
        
        item.Type           = 'edit';
        item.ObjectProperty = sprintf('%sFracLength%d', tag, indx);
        item.Tag            = sprintf('%sFracLength%d', tag, indx);
        item.Source         = this;
        item.ColSpan        = [2 2];
        item.RowSpan        = [indx indx];
        item.Mode           = true;
        item.Enabled        = enabState;
        
        items{2*indx-1} = itemlabel;
        items{2*indx}   = item;
    end
    
    frac.Type  = 'panel';
    frac.Items = items;
    frac.LayoutGrid = [length(fracNames) 2];
    frac.Tag   = sprintf('%sFracLengthPanel', tag);
else
    frac.Type           = 'edit';
    frac.ObjectProperty = sprintf('%sFracLength1', tag);
    frac.Tag            = sprintf('%sFracLength1', tag);
    frac.Source         = this;
    frac.Mode           = true;
    frac.Enabled        = enabState;
end
frac.ColSpan        = [5 5];
frac.RowSpan        = [row row];

if nargout == 1
    label = [items {label, mode, signed, word, frac}];
end

% -------------------------------------------------------------------------
function fixptparam = getFixptOperationalParameters(this, row)

enabState = isfdtbxinstalled;

rmode.Name           = FilterDesignDialog.message('FixedPtRoundMode');
rmode.Type           = 'combobox';
rmode.ObjectProperty = 'RoundMode';
rmode.RowSpan        = [1 1];
rmode.ColSpan        = [1 1];
rmode.Source         = this;
rmode.Tag            = 'RoundMode';
rmode.Entries        = getEntries(set(this, 'RoundMode')');

%set default RoundMode on top
defaultindx = find(strcmpi(set(this, 'RoundMode'),this.RoundMode));
if ~isempty(defaultindx)
    rmode.Value = defaultindx - 1;
end

rmode.Enabled        = enabState;
rmode.Mode           = true;

omode.Name           = FilterDesignDialog.message('FixedPtOverflowMode');
omode.Type           = 'combobox';
omode.ObjectProperty = 'OverflowMode';
omode.RowSpan        = [1 1];
omode.ColSpan        = [2 2];
omode.Source         = this;
omode.Tag            = 'OverflowMode';
omode.Entries        = getEntries(set(this,'OverflowMode')');

%set default OverflowMode on top
defaultindx = find(strcmpi(set(this, 'OverflowMode'),this.OverflowMode));
if ~isempty(defaultindx)
    omode.Value = defaultindx - 1;
end

omode.Enabled        = enabState;
omode.Mode           = true;

items = {rmode, omode};

if any(strcmpi(this.Structure, {'df1', 'df2', 'df1t', 'df2t', 'df1sos', ...
        'df2sos', 'df2tsos', 'df1tsos'})) && ~strcmpi(this.AccumMode, 'Full precision')
    cast.Type           = 'checkbox';
    cast.ObjectProperty = 'CastBeforeSum';
    cast.RowSpan        = [2 2];
    cast.ColSpan        = [1 2];
    cast.Name           = FilterDesignDialog.message('CastBeforeSum');
    cast.Source         = this;
    cast.Tag            = 'CastBeforeSum';
    cast.Enabled        = enabState;
    cast.Mode           = true;
    
    items = [items {cast}];
end

fixptparam.Type       = 'group';
fixptparam.Name       = FilterDesignDialog.message('FixedPtOpParams');
fixptparam.Items      = items;
fixptparam.LayoutGrid = [2 2];
fixptparam.RowSpan    = [row row];
fixptparam.ColSpan    = [1 3];
fixptparam.Tag        = 'FixedPointOperationalParameters';

% -------------------------------------------------------------------------
function items = getCoeffRow(this, opts, items)

if nargin < 3
    items = {};
end

opts.Name = 'FixedPtCoefficients';
opts.Tag  = 'Coeff';

[label, mode, signed, word, frac] = getFormatRow(this, opts);

mode                = rmfield(mode, 'Name');
mode.Type           = 'combobox';
mode.Source         = this;
mode.ObjectProperty = 'CoeffMode';
mode.Mode           = true;
mode.DialogRefresh  = true;
mode.Entries =  getEntries(set(this, 'CoeffMode')');

%set default CoeffMode on top
defaultindx = find(strcmpi(set(this, 'CoeffMode'),this.CoeffMode));
if ~isempty(defaultindx)
    mode.Value = defaultindx - 1;
end
signed.Type           = 'checkbox';
signed.Source         = this;
signed.ObjectProperty = 'CoeffSigned';
signed = rmfield(signed, 'Name');

items = [items {label, mode, signed, word}];
if strcmpi(this.CoeffMode, 'binary point scaling')
    items = [items {frac}];
end

% -------------------------------------------------------------------------
function items = getProductRow(this, opts, items)

if nargin < 3
    items = {};
end

opts.Name = 'FixedPtProduct';
opts.Tag  = 'Product';

[label, mode, signed, word, frac] = getFormatRow(this, opts);

% Change the Mode to a combobox.
mode                = rmfield(mode, 'Name');
mode.Type           = 'combobox';
mode.Source         = this;
mode.ObjectProperty = 'ProductMode';
mode.Mode           = true;
mode.DialogRefresh  = true;
mode.Entries =  getEntries(set(this, 'ProductMode')');

%set default ProductMode on top
defaultindx = find(strcmpi(set(this, 'ProductMode'),this.ProductMode));
if ~isempty(defaultindx)
    mode.Value = defaultindx - 1;
end

% Only add the wordlength when needed.
items = [items {label, mode, signed}];
if any(strcmpi(this.ProductMode, {'keep lsb', 'keep msb', 'specify precision'}))
    items = [items {word}];
end

% Only add the frac length when needed.
if strcmpi(this.ProductMode, 'specify precision')
    items = [items {frac}];
end

% -------------------------------------------------------------------------
function items = getStateRow(this, opts, auto, old_items)

if nargin < 3
    old_items = {};
end

if isfield(opts, 'Name')
    name = cellstr(opts.Name);
else
    name = {'State'};
end

opts.Tag = 'State';

for indx = 1:length(name)
    opts.Name = name{indx};
    if auto
        items = getAutoRow(this, opts);
    else
        items = getFormatRow(this, opts);
    end
    
    items{1}.Tag = strrep(strrep(name{indx}, '.', ''), ' ', '');
    
    items{4}.ObjectProperty = sprintf('%s%d', items{4}.ObjectProperty, indx);
    items{4}.Tag            = items{4}.ObjectProperty;
    
    if length(items) > 4
        if ~strcmpi(items{5}.Type, 'panel')
            items{5}.ObjectProperty = sprintf('%s%d', items{5}.ObjectProperty(1:end-1), indx);
            items{5}.Tag            = items{5}.ObjectProperty;
        end
    end
    
    old_items = [old_items items]; %#ok<AGROW>
    opts.Row = opts.Row+1;
end
items = old_items;

items = [old_items items];


% -------------------------------------------------------------------------
function items = getAutoRow(this, opts, items)

if nargin < 3
    items = {};
end

[label, mode, signed, word, frac] = getFormatRow(this, opts);

if isfield(opts, 'Tag')
    tag = opts.Tag;
else
    tag = strrep(opts.Name, ' ', '');
end

mode                = rmfield(mode, 'Name');
mode.Type           = 'combobox';
mode.Source         = this;
mode.ObjectProperty = [tag 'Mode'];
mode.Mode           = true;
mode.DialogRefresh  = true;
mode.Entries = getEntries(set(this, mode.ObjectProperty)');

%set default option on top
defaultindx = find(strcmpi(set(this, mode.ObjectProperty), ...
    this.(mode.ObjectProperty)));
if ~isempty(defaultindx)
    mode.Value = defaultindx - 1;
end


items = [items {label, mode, signed, word}];
if strcmpi(this.(mode.ObjectProperty), 'binary point scaling')
    items = [items {frac}];
end

% -------------------------------------------------------------------------
function items = getAccumRow(this, opts, items)

if nargin < 3
    items = {};
end

opts.Name = 'FixedPtAccum';
opts.Tag  = 'Accum';

[label, mode, signed, word, frac] = getFormatRow(this, opts);

mode                = rmfield(mode, 'Name');
mode.Type           = 'combobox';
mode.Source         = this;
mode.ObjectProperty = 'AccumMode';
mode.Mode           = true;
mode.DialogRefresh  = true;
mode.Entries = getEntries(set(this, 'AccumMode')');

%set default AccumMode on top
defaultindx = find(strcmpi(set(this, 'AccumMode'),this.AccumMode));
if ~isempty(defaultindx)
    mode.Value = defaultindx - 1;
end

items = [items {label, mode, signed}];
if any(strcmpi(this.AccumMode, {'keep lsb', 'keep msb', 'specify precision'}))
    items = [items {word}];
end

if strcmpi(this.AccumMode, 'specify precision')
    items = [items {frac}];
end

% -------------------------------------------------------------------------
function items = getOutputRow(this, opts, items)

if nargin < 3
    items = {};
end

opts.Name = 'FixedPtOutput';
opts.Tag  = 'Output';

[label, mode, signed, word, frac] = getFormatRow(this, opts);

mode                = rmfield(mode, 'Name');
mode.Type           = 'combobox';
mode.Source         = this;
mode.ObjectProperty = 'OutputMode';
mode.Mode           = true;
mode.DialogRefresh  = true;
mode.Entries = getEntries(set(this, 'OutputMode')');

%set default OutputMode on top
defaultindx = find(strcmpi(set(this, 'OutputMode'),this.OutputMode));
if ~isempty(defaultindx)
    mode.Value = defaultindx - 1;
end

items = [items {label, mode, signed, word}];
if strcmpi(this.OutputMode, 'specify precision')
    items = [items {frac}];
end

% -------------------------------------------------------------------------
function [fintlabel, fint] = getFilterInternals(this, startrow)

fintlabel.Type    = 'text';
fintlabel.Name    = FilterDesignDialog.message('FilterInternals');
fintlabel.RowSpan = [startrow startrow];
fintlabel.ColSpan = [1 1];
fintlabel.Tag     = 'FilterInternalsLabel';
FiltInt = set(this, 'FilterInternals')';
if ~any(strcmpi(this.Structure, {'cicdecim', 'cicinterp'}))
    FiltInt(2:3) = [];
    
end
entries = getEntries(FiltInt);

%set default FilterInternals on top
defaultindx = find(strcmpi(FiltInt, this.FilterInternals));
if ~isempty(defaultindx)
    fint.Value = defaultindx - 1;
end


fint.Type           = 'combobox';
fint.Entries        = entries;
fint.Source         = this;
fint.DialogRefresh  = true;
fint.Tag            = 'FilterInternals';
fint.RowSpan        = fintlabel.RowSpan;
fint.ColSpan        = [2 2];
fint.Enabled        = isfdtbxinstalled;
fint.ObjectMethod = 'selectComboboxEntry';
fint.MethodArgs  = {'%dialog', '%value', 'FilterInternals', FiltInt};
fint.ArgDataTypes = {'handle', 'mxArray', 'string', 'mxArray'};
% ------------------------------
function Entries = getEntries(originalEntries)
Entries = originalEntries;

for i = 1:length(originalEntries)
    indx = find(isspace(originalEntries{i}));
    Entries{i}(indx+ 1) = upper(Entries{i}(indx+ 1));
    Entries{i}(indx) = [];
    Entries{i} = FilterDesignDialog.message(Entries{i});
end




%EOF
