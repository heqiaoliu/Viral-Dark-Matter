function fspecs = getFrequencySpecsFrame(this)
%GETFREQUENCYSPECSFRAME Get the frequencySpecsFrame.


%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/04/21 04:23:10 $


% Add the constraints popup.
items = getConstraintsWidgets(this, 'Frequency', 1);
items{1}.Visible = true;
items{2}.Visible = true;

% Add the Frequency Units widgets
items = getFrequencyUnitsWidgets(this, 2, items);

% Determine which constraints we need to add.
switch lower(this.FrequencyConstraints)
    case 'center frequency, bandwidth, passband width'
        items = addConstraint(this, 3, 1, items, true, 'F0', FilterDesignDialog.message('F0'));
        items = addConstraint(this, 3, 3, items, true, 'BW', FilterDesignDialog.message('BW'));
        items = addConstraint(this, 4, 1, items, true, 'BWpass', FilterDesignDialog.message('BWpass'));
    case 'center frequency, bandwidth, stopband width'
        items = addConstraint(this, 3, 1, items, true, 'F0', FilterDesignDialog.message('F0'));
        items = addConstraint(this, 3, 3, items, true, 'BW', FilterDesignDialog.message('BW'));
        items = addConstraint(this, 4, 1, items, true, 'BWstop', FilterDesignDialog.message('BWstop'));
    case 'center frequency, bandwidth'
        items = addConstraint(this, 3, 1, items, true, 'F0', FilterDesignDialog.message('F0'));
        items = addConstraint(this, 3, 3, items, true, 'BW', FilterDesignDialog.message('BW'));
    case 'center frequency, quality factor'
        items = addConstraint(this, 3, 1, items, true, 'F0', FilterDesignDialog.message('F0'));
        items = addConstraint(this, 3, 3, items, true, 'Qa', FilterDesignDialog.message('Q')); 
    case 'shelf type, cutoff frequency, quality factor'
        %Add a widget to control F0 via a ShelfType property which can be
        %set to Lowpass, or Highpass
        items = getShelfTypeWidget(this,items,3,1);
        items = addConstraint(this, 3, 3, items, true, 'Qa', FilterDesignDialog.message('Q')); 
        items = addConstraint(this, 4, 1, items, true, 'Fc', FilterDesignDialog.message('Fcutoff'));
    case 'shelf type, cutoff frequency, shelf slope parameter'
        %Add a widget to control F0 via a ShelfType property which can be
        %set to Lowpass, or Highpass
        items = getShelfTypeWidget(this,items,3,1);        

        items = addConstraint(this, 3, 3, items, true, 'S', FilterDesignDialog.message('S')); 
        items = addConstraint(this, 4, 1, items, true, 'Fc', FilterDesignDialog.message('Fcutoff'));        
    case 'low frequency, high frequency'
        items = addConstraint(this, 3, 1, items, true, 'Flow', FilterDesignDialog.message('Flow'));
        items = addConstraint(this, 3, 3, items, true, 'Fhigh', FilterDesignDialog.message('Fhigh'));
end

fspecs.Name       = FilterDesignDialog.message('freqspecs');
fspecs.Type       = 'group';
fspecs.Items      = items;
fspecs.LayoutGrid = [4 4];
fspecs.RowStretch = [0 0 0 1];
fspecs.ColStretch = [0 1 0 1];
fspecs.Tag        = 'FreqSpecsGroup';


function items = getShelfTypeWidget(this,items,row,col)
%getShelfTypeWidget create a shelf type widget
[shelf_lbl, shelf] = getWidgetSchema(this, 'ShelfType', ...
    FilterDesignDialog.message('ShelfType'), 'combobox', row, col);
shelf_lbl.Tunable = true;
shelf.DialogRefresh  = true;
options = {'Lowpass', 'Highpass'};
shelf.Entries = FilterDesignDialog.message({'lp','hp'});
shelf.Tunable = true;
%
%set default ShelfType on top
indx = find(strcmpi(options, this.ShelfType));
if ~isempty(indx)
shelf.Value = indx - 1;
end
shelf.ObjectMethod = 'selectComboboxEntry';
shelf.MethodArgs  = {'%dialog', '%value','ShelfType', options};
shelf.ArgDataTypes = {'handle', 'mxArray', 'string', 'mxArray'};

% Turn off immediate mode, since the since the appropriate UDD
% property is set in the associated callback selectComboboxEntry.
shelf.Mode = false; 

% Remove the ObjectProperty for this widget since the appropriate UDD
% property is set in the associated callback selectComboboxEntry.
shelf = rmfield(shelf, 'ObjectProperty');
%
items = {items{:}, shelf_lbl, shelf}; %#ok<CCAT>

% [EOF]
