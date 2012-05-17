function tableSortandRender(this, rowList)

    % Copyright 2010 The MathWorks, Inc.
    % reassign rows
    this.commonTableModel.setOriginalRows(rowList);
    
    if strcmpi(this.sortCriterion, 'GRUNNAME')
        this.commonTableModel.setSortedByRunName(true);
    else
        this.commonTableModel.setSortedByRunName(false);
    end
            
    % repaint tables
    this.InspectTT.TT.repaint();
    this.compareSignalsTT.TT.repaint();
    
end