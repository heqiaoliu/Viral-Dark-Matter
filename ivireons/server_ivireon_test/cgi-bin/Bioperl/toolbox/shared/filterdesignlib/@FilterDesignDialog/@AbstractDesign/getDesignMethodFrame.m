function design = getDesignMethodFrame(this)
%GETDESIGNMETHODFRAME   Get the designMethodFrame.

%   Author(s): J. Schickler

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.10 $  $Date: 2009/10/16 06:38:10 $


row = [1 1];

tunable = ~isminorder(this);

% Add the design method combobox and label.
[method_lbl, method] = getWidgetSchema(this, 'DesignMethod',  ...
    FilterDesignDialog.message('designmethod'), ...
    'combobox', row, 1);

method_lbl.Tunable    = tunable;
method.Enabled        = this.Enabled;
method.Tunable        = tunable;

% Get the valid methods to populate the entries.
if this.Enabled
    method.Entries = FilterDesignDialog.message(getValidMethods(this, 'short'));
    
    validMethods = getValidMethods(this);
    %set default DesignMethod on top
    indx = find(strcmp(validMethods, this.DesignMethod));
    if ~isempty(indx)
        method.Value = indx - 1;
    end
    
    method.ObjectMethod = 'selectComboboxEntry';
    method.MethodArgs  = {'%dialog', '%value','DesignMethod', validMethods};
    method.ArgDataTypes = {'handle', 'mxArray', 'string', 'mxArray'};
    
    % Turn off immediate mode, since the since the appropriate UDD
    % property is set in the associated callback selectComboboxEntry.
    method.Mode = false;
    method.DialogRefresh = true;
    
    % Remove the ObjectProperty for this widget since the appropriate UDD
    % property is set in the associated callback selectComboboxEntry.
    method = rmfield(method, 'ObjectProperty');

else
    method.Entries = {this.DesignMethod};
end

row = row+1;

% Add the structure combobox and label.
[structure_lbl, structure] = getWidgetSchema(this, 'Structure',  ...
    FilterDesignDialog.message('structure'), ...
    'combobox', row, 1);

structure.DialogRefresh  = true;
structure.Enabled        = this.Enabled;


if this.Enabled
    % Get the valid structures to populate the entries.
    validStructures = getValidStructures(this);   
    
    structure.Entries = FilterDesignDialog.message(validStructures);
    validStructuresFull = getValidStructures(this, 'full');
    %set default Structure on top
    indx = find(strcmpi(validStructuresFull,this.Structure));
    if ~isempty(indx)
        structure.Value = indx - 1;
    end
    structure.ObjectMethod = 'selectComboboxEntry';
    structure.MethodArgs  = {'%dialog', '%value','Structure', ...
        validStructuresFull};
    structure.ArgDataTypes = {'handle', 'mxArray', 'string', 'mxArray'};
    
    % Turn off immediate mode, since the since the appropriate UDD
    % property is set in the associated callback selectComboboxEntry.
    structure.Mode = false;
    
    % Remove the ObjectProperty for this widget since the appropriate UDD
    % property is set in the associated callback selectComboboxEntry.
    structure = rmfield(structure, 'ObjectProperty');

else
    structure.Entries = {this.Structure};
end


items = {method_lbl, method, structure_lbl, structure};

% Add the SOS settings if the structure is an SOS.
if any(strcmpi(this.Structure, {'direct-form i sos', 'direct-form ii sos', ...
        'direct-form i transposed sos', 'direct-form ii transposed sos'}))
    
    if isfdtbxdlg(this)
        
        row = row+1;
        
        scale.Name           = FilterDesignDialog.message('scalesos');
        scale.Type           = 'checkbox';
        scale.Source         = this;
        scale.ObjectProperty = 'Scale';
        scale.Mode           = true;
        scale.Tag            = 'Scale';
        scale.RowSpan        = [row row];
        scale.ColSpan        = [1 2];
        scale.Enabled        = this.Enabled;
        
        items = {items{:}, scale}; %#ok<CCAT>
    end
end

if this.Enabled
    options = getOptions(this, row(1)+1);
else
    options = getOptionsStatic(this, row(1)+1);
end

if ~isempty(options)
    
    items = {items{:}, options}; %#ok<CCAT>
end

design.Type       = 'group';
design.Name       = FilterDesignDialog.message('algorithm');
design.Items      = items;
design.LayoutGrid = [5 2];
design.ColStretch = [0 1];
design.RowStretch = [0 0 0 0 1];
design.Tag        = 'DesignMethodGroup';

% -------------------------------------------------------------------------
function options = getOptionsStatic(this, startrow)

% Statically render design opitons based on "DesignOptionsCache"
opts = get(this,'DesignOptionsCache');

if isempty(opts)
    options = [];
    return;
end

fn = fieldnames(opts);
items = {};
for indx = 1:length(fn)
    text = [];
    v = opts.(fn{indx});
    if islogical(v)
        text.Type     = 'checkbox';
        haslabel      = false;
    else
        text.Type     = 'text';
        haslabel      = true;
    end
    
    col = [0 0];
    row = [indx indx];
    name = FilterDesignDialog.message(fn{indx});
    
    if haslabel
        label.RowSpan = row;
        label.ColSpan = col+1;
        label.Type    = 'text';
        label.Name    = name;
        label.Tag     = sprintf('%sLabel', fn{indx});
        label.Tunable = 1;
        label.Enabled = 1;
        
        text.ColSpan = col+2;
        text.Name    = opts.(fn{indx});
    else
        text.Name    = name;
        text.Value   = opts.(fn{indx});
        text.ColSpan = col+[1 2];
    end
    
    text.RowSpan        = row;
    text.Tag            = fn{indx};
    text.Enabled        = false;
    switch lower(fn{indx})
        case 'halfbanddesignmethod'
            if isfield(opts, 'UseHalfbands') && ~this.UseHalfbands,
                text.Visible = false;
                label.Visible = false;
            end
    end
    if haslabel
        items = {items{:}, label}; %#ok<CCAT>
    end
    items = {items{:}, text}; %#ok<CCAT>
end

if isempty(items)
    options = [];
else
    options.Type       = 'togglepanel';
    options.Name       = FilterDesignDialog.message('DesignOpts');
    options.Items      = items;
    options.Tag        = 'DesignOptionsToggle';
    options.LayoutGrid = [length(fn) 2];
    options.ColStretch = [0 1];
    options.RowSpan    = [startrow startrow];
    options.ColSpan    = [1 2];
end

% -------------------------------------------------------------------------
function options = getOptions(this, startrow)

options = [];  

hd = get(this, 'FDesign');
setSpecsSafely(this, hd, getSpecification(this));

% Make sure the design method is valid
methodEntries = getValidMethods(this, 'short');
method = getSimpleMethod(this);
if ~any(strcmpi(method,methodEntries)),
    return
end

dopts = designoptions(hd, method);

dopts = rmfield(dopts, {'FilterStructure', 'DefaultFilterStructure'});
if isfield(dopts, 'SOSScaleOpts')
    dopts = rmfield(dopts, {'SOSScaleOpts', 'DefaultSOSScaleOpts'});
end
if isfield(dopts, 'SOSScaleNorm')
    dopts = rmfield(dopts, {'SOSScaleNorm', 'DefaultSOSScaleNorm'});
end
if isfield(dopts, 'MinPhase') && isfield(dopts, 'MaxPhase'),
    dopts = rmfield(dopts, {'MinPhase', 'MaxPhase'});
    dopts = rmfield(dopts, {'DefaultMinPhase', 'DefaultMaxPhase'});
    N = length(fieldnames(dopts));
    dopts.PhaseConstraint = {'Linear','Minimum','Maximum'};
    dopts = orderfields(dopts,[1 N+1 2:N]);
    dopts.DefaultPhaseConstraint = 'Linear';
    dopts = orderfields(dopts,[1:N/2+2 N+2 N/2+3:N+1]);
end

fn = fieldnames(dopts);

items = {};

% Design options are tunable if the design is not minimum order.
tunable = ~isminorder(this);

for indx = 1:length(fn)/2
    edit = [];
    v = dopts.(fn{indx});    
    if iscell(v)
        edit.Type = 'combobox';
        edit.Editable = false;   
        

        % if this is a dynamic combo box, then populate the
        % entried from the xlate file.  
        Options = FilterDesignDialog.message(v);
        edit.Entries  = Options;        
        haslabel      = true;
    elseif strcmpi(v, 'bool')
        edit.Type     = 'checkbox';
        haslabel      = false;
    else
        edit.Type     = 'edit';
        haslabel      = true;
    end
    
    col = [0 0];
    row = [indx indx];
    name = FilterDesignDialog.message(fn{indx});
    
    if haslabel
        label.RowSpan = row;
        label.ColSpan = col+1;
        label.Type    = 'text';
        label.Name    = name;
        label.Tag     = sprintf('%sLabel', fn{indx});
        label.Tunable = tunable;
        
        edit.ColSpan = col+2;
        edit.Name    = '';
    else
        edit.Name    = name;
        edit.ColSpan = col+[1 2];
    end
    
    edit.Source         = this;
    edit.ObjectProperty = fn{indx};
    edit.RowSpan        = row;
    edit.Tag            = fn{indx};
    edit.Mode           = true;
    edit.Enabled        = this.Enabled;
    edit.Tunable        = tunable;
    % Add code to remove immediate mode for dynamic combo boxes
    if strcmpi(edit.Type, 'combobox')      
               
        edit.ObjectMethod = 'selectComboboxEntry';
        if strcmpi (fn{indx}, 'HalfbandDesignMethod')
            op = {'Equiripple', 'Kaiser window', ...
                'Butterworth', 'Elliptic', 'IIR quasi-linear phase'};
            edit.MethodArgs  = {'%dialog', '%value', 'HalfbandDesignMethod', op};
            
            % set the default option on the top  
            defaultindx = find(strcmp(op, this.(fn{indx})));
            if ~isempty(defaultindx)
                edit.Value =  defaultindx-1;
            end
        else
            edit.MethodArgs  = {'%dialog', '%value',fn{indx} ,sentencecase(v)};
            
            % set the default option on the top 
            defaultindx = find(strcmp(sentencecase(v), this.(fn{indx})));
            if ~isempty(defaultindx)
                edit.Value =  defaultindx-1;
            end
        end
        edit.ArgDataTypes = {'handle', 'mxArray', 'string', 'mxArray'};
        
              
        % Turn off immediate mode, since the since the appropriate UDD
        % property is set in the associated callback selectComboboxEntry.
        edit.Mode = false;
        
        % Remove the ObjectProperty for this widget since the appropriate
        % UDD property is set in the associated callback
        % selectComboboxEntry.
        edit = rmfield(edit, 'ObjectProperty');
    
    end
    % End Adding code to remove immediate mode for dynamic combo boxes
    switch lower(fn{indx})
        case 'usehalfbands'
            edit.DialogRefresh = true;
        case 'halfbanddesignmethod'
            if isfield(dopts, 'UseHalfbands') && ~this.UseHalfbands,
                edit.Visible = false;
                label.Visible = false;
            else
                % populate the entries of Halfband design methods from
                % xlate file
                Options = {'equiripple', 'kaiserwin', ...
                    'butter', 'ellip', 'iirlinphase'};                
                Options = FilterDesignDialog.message(Options);                
                edit.Entries = Options;
            end
    end
    
    if haslabel
        items = {items{:}, label}; %#ok<CCAT>
    end
    
    items = {items{:}, edit}; %#ok<CCAT>
end

if isempty(items)
    options = [];
else
    options.Type       = 'togglepanel';
    options.Name       = FilterDesignDialog.message('DesignOpts');
    options.Items      = items;
    options.Tag        = 'DesignOptionsToggle';
    options.LayoutGrid = [length(fn)/2 2];
    options.ColStretch = [0 1];
    options.RowSpan    = [startrow startrow];
    options.ColSpan    = [1 2];
end

% -------------------------------------------------------------------------
function str = sentencecase(str)

str = cellstr(str);

for indx = 1:length(str)
    str{indx} = [upper(str{indx}(1)) lower(str{indx}(2:end))];
end

% [EOF]
