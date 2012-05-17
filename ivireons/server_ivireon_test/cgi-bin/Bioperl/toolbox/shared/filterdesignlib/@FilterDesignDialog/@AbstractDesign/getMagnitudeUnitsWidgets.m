function items = getMagnitudeUnitsWidgets(this, startrow, items)
%GETMAGNITUDEUNITSWIDGETS   Get the magnitudeUnitsWidgets.

%   Author(s): J. Schickler
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/04/21 04:21:14 $

if nargin < 3
    items = {};
    if nargin < 2
        startrow = 2;
    end
end

tunable = ~isminorder(this);

% Define the widgets
[units_lbl, units] = getWidgetSchema(this, 'MagnitudeUnits', ...
    FilterDesignDialog.message('magunits'), ...
    'combobox', startrow, 1);

% Set the widgets as tunable
units_lbl.Tunable = tunable;
units.Tunable     = tunable;


% Define the entries dependent on the Impulse Response.
if strcmpi(this.ImpulseResponse, 'fir')

    unitEntries = {'dB', 'Linear'};    
    options = FilterDesignDialog.message(unitEntries);      
    units.Entries = options;
else

    unitEntries = {'dB', 'Squared'};    
    options = FilterDesignDialog.message(unitEntries);    
    units.Entries = options;
end
    % set default Magnitude units on the top
    defaultindx = find(strcmpi(unitEntries,this.MagnitudeUnits));
    if ~isempty(defaultindx)
    units.Value = defaultindx - 1;
    end
    units.ObjectMethod = 'selectComboboxEntry';
    units.MethodArgs  = {'%dialog', '%value', 'MagnitudeUnits', unitEntries};
    units.ArgDataTypes = {'handle', 'mxArray', 'string', 'mxArray'};
    
    % Turn off immediate mode, since the since the appropriate UDD
    % property is set in the associated callback selectComboboxEntry.
    units.Mode = false; 
    
    % Remove the ObjectProperty for this widget since the appropriate UDD
    % property is set in the associated callback selectComboboxEntry.
    units = rmfield(units, 'ObjectProperty'); 
items = {items{:}, units_lbl, units}; %#ok<CCAT>

% [EOF]
