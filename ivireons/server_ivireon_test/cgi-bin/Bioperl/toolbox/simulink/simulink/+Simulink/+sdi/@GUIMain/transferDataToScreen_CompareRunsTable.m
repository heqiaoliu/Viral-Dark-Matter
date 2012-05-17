function transferDataToScreen_CompareRunsTable(this)
    
    % Copyright 2010 The MathWorks, Inc.
    numCol = length(this.colNamesCompRun);
    rowList = this.populateCompareRunsTable(numCol);
    this.compareRunsTTModel.setOriginalRows(rowList);
    this.compareRunsTT.TT.repaint();
end % TransferDataToScreen_Table