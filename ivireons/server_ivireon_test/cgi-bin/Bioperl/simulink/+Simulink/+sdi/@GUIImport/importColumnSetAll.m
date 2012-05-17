function importColumnSetAll(this, colValue)

    % Check (or uncheck) the items to import
    %
    % Copyright 2010 The MathWorks, Inc.

    % Get number of rows in table
    rowCount = this.ImportVarsTT.getRowCount();

    % Get index of "Import?" column
    importColumnIndex = 8;

    % Iterate over all columns, setting value to colValue
    for i = 1 : rowCount
        this.ImportVarsTTModel.setValueAt(colValue, i - 1, importColumnIndex);
    end
    
    this.ImportVarsTT.repaint();
    
end
