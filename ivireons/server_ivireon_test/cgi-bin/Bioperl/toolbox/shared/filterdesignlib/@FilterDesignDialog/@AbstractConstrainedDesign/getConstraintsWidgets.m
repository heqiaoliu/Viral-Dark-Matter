function items = getConstraintsWidgets(this, type, row)
%GETCONSTRAINTSWIDGETS   Get the constraintsWidgets.

%   Author(s): J. Schickler
%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2010/02/17 18:58:23 $

[constraints_lbl, constraints] = getWidgetSchema(this, ...
    sprintf('%sConstraints', type), FilterDesignDialog.message([lower(type) 'consts']), ...
    'combobox', row, 1);
constraints.ColSpan = [2 4];
constraints.DialogRefresh  = true;
if strcmpi(type, 'Frequency')
    
    Freq = getValidFreqConstraints(this);
    FreqEntries = cell(1, length(Freq));
    % populate the entries from xlate file
    for i = 1:length(Freq)
        FreqEntries{i} = FilterDesignDialog.message(getConstraintsID(this, Freq{i}));
    end
        
    constraints.Entries = FreqEntries;
    
    % set default FrequencyConstraints on the top
    defaultindx = find(strcmpi(Freq,this.FrequencyConstraints));
    if ~isempty(defaultindx)
    constraints.Value = defaultindx - 1;
    end
    
    constraints.ObjectMethod = 'selectComboboxEntry';
    constraints.MethodArgs  = {'%dialog', '%value', 'FrequencyConstraints', Freq};
    constraints.ArgDataTypes = {'handle', 'mxArray', 'string', 'mxArray'};
    
    % Remove the ObjectProperty for this widget since the appropriate UDD
    % property is set in the associated callback selectComboboxEntry.
    constraints = rmfield(constraints, 'ObjectProperty'); 
else    
    availableconstraints = getValidMagConstraints(this);
    MagEntries = cell(1, length(availableconstraints));
    % populate the entries from xlate file
    for i = 1:length(availableconstraints)
        MagEntries{i} = FilterDesignDialog.message( ...
            getConstraintsID(this, availableconstraints{i}));
    end
    
    constraints.Entries = MagEntries;
    
    % set default MagnitudeConstraints on the top
    defaultindx = find(strcmpi(availableconstraints,this.MagnitudeConstraints));
    if ~isempty(defaultindx)
    constraints.Value = defaultindx - 1;
    end
    constraints.ObjectMethod = 'selectComboboxEntry';
    constraints.MethodArgs  = {'%dialog', '%value', 'MagnitudeConstraints', availableconstraints};
    constraints.ArgDataTypes = {'handle', 'mxArray', 'string', 'mxArray'};
    
    % Remove the ObjectProperty for this widget since the appropriate UDD
    % property is set in the associated callback selectComboboxEntry.
    constraints = rmfield(constraints, 'ObjectProperty'); 
end

if isminorder(this)
    constraints_lbl.Visible = false;
    constraints.Visible     = false;
else
    constraints_lbl.Tunable = true;
    constraints.Tunable     = true;
end



items = {constraints_lbl, constraints};

% [EOF]
