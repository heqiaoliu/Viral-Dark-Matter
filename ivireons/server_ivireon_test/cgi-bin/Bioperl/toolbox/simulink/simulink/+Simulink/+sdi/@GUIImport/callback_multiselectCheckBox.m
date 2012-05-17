function callback_multiselectCheckBox(this, ~, ~)
    
    % Copyright 2010 The MathWorks, Inc.
    
    % what is the value?
    onTableChkBoxValue = this.ImportVarsCheckboxCellEditor.getCellEditorValue();
    
    % get selected rows
    selectedRows = this.ImportVarsTT.getSelectedRows();
    
    % get the number of selected rows
    count = length(selectedRows);
    
    % get the number of columns
    colCount = this.ImportVarsTT.getColumnCount();
    
    % set the same value for selected rows
    for i=1:count
        this.ImportVarsTT.setValueAt(onTableChkBoxValue,...
                                          selectedRows(i),   ...
                                          colCount-1);
    end  
    
    % repaint the tree
    this.ImportVarsTT.repaint();
end