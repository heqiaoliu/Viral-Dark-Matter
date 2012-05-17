function callback_RunNameEditor(this, source, ~)

    % Copyright 2010 The MathWorks, Inc.
    % This function gets called after editing has stopped for Run Name. It
    % will make sure that the run name is changed in Signal Repository and
    % also gets reflected in each signal on the table.
    
    % get selected row
    selectedRow = source.getSelectedRow(); 
    
    % return if row is empty
    if isempty(selectedRow)
        return;
    end
    
    % if there are no children then you should not be editing it
    if ~(selectedRow.hasChildren)
        return;
    end
    
    % New run name
    newRunName = source.CellEditorValue;
    
    % column number
    col = length(this.colNames) + 2;
    
    % Run ID
    runID = int32(selectedRow.getValueAt(col));
    
    % set new run name
    this.SDIEngine.setRunName(runID, newRunName);
        
    % get the number of children
    numChildren = selectedRow.getChildrenCount;
    
    % go through each leaf and change the run name
    for i = 1:numChildren
        % find the child
        child = selectedRow.getChildAt(i-1);
        % set run name in table
        child.setValueAt(newRunName, 1);
        
        % check if it has any children, i.e., multidimensional data
        if(child.hasChildren)
            count = child.getChildrenCount;
            for j = 1:count
                grandChild = child.getChildAt(j-1);
                % set run name in table
                grandChild.setValueAt(newRunName, 1);
            end            
        end        
    end
    
    % refresh the table
    this.InspectTT.TT.repaint();
    this.compareSignalsTT.TT.repaint();
    this.transferStateToScreen_CompareRuns();
    this.dirty = true;
end