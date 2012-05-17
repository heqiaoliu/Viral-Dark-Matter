function setVisible(this)

    % Manage visibility for all controls on dialog
    %
    % Copyright 2009-2010 The MathWorks, Inc.

    % This function designed to accomodate multiple
    % tabs of inputs.  For now there is only one set
    % of inputs that are always visible
    
    % Set visibility
    set(this.ImportFromLabel,              'Visible', 'on');
    set(this.ImportFromBaseRadio,          'Visible', 'on');
    set(this.ImportFromMATRadio,           'Visible', 'on');
    set(this.ImportFromMATLabel,           'Visible', 'on');
    set(this.ImportFromMATEdit,            'Visible', 'on');
    set(this.ImportFromMATButtonContainer, 'Visible', 'on');
    set(this.ImportToLabel,                'Visible', 'on');
    set(this.ImportToNewRadio,             'Visible', 'on');
    set(this.ImportToExistRadio,           'Visible', 'on');
    set(this.ImportToExistLabel,           'Visible', 'on');
    set(this.ImportToExistCombo,           'Visible', 'on');
    set(this.ImportVarsTTContainer,        'Visible', 'on');
    set(this.RefreshButtonContainer,       'Visible', 'on');
    set(this.SelectAllButtonContainer,     'Visible', 'on');
    set(this.ClearAllButtonContainer,      'Visible', 'on');
end