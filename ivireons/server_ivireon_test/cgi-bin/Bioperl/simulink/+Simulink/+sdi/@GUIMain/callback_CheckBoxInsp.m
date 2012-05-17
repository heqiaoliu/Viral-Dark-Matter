function callback_CheckBoxInsp(this, ~, ~)

    % Copyright 2010 The MathWorks, Inc.
    
    plotInd = strcmp(this.sd.MGInspectColNamePlot, this.colNames);
    plotInd = find(plotInd == 1);
    % plot column index
    plotInd = plotInd - 1;
    
    % get the signal ID
    id = this.checkboxCellEditorInsp.getSelected();
    
    selectedRows = this.InspectTT.TT.getSelectedRows();
	totalRows = this.InspectTT.TT.getRowCount();
            
    % get if the checkbox is checked or not
    onTableChkBoxValue = this.checkboxCellEditorInsp.getCellEditorValue();    
    if (~isempty(id) && ~isempty(onTableChkBoxValue))
        this.SDIEngine.setVisibility(int32(id),onTableChkBoxValue);
    end
    
    try        
        if (~isempty(onTableChkBoxValue))
            for i = 1:length(selectedRows)
                rowAtIndex = this.InspectTT.TT.getRowAt(selectedRows(i));
                if ~rowAtIndex.hasChildren()
                    % get the id
                    id = rowAtIndex.getValueAt(20);
                    % set the status in the table
                    rowAtIndex.setValueAt(onTableChkBoxValue, plotInd);
                    % set the visibility of the signal
                    this.SDIEngine.setVisibility(int32(id), onTableChkBoxValue);
                end
            end
            
            for j = 1:totalRows
                rowAtj = this.InspectTT.TT.getRowAt(j-1);
                
                if ~rowAtj.hasChildren()
                    helperCallback(this, rowAtj, plotInd);
                else
                    if ~(rowAtj.isExpanded)
                        childrenCount = rowAtj.getChildrenCount();
                        for k = 1:childrenCount
                            rowAtk = rowAtj.getChildAt(k-1);
                            if ~rowAtk.hasChildren()
                                helperCallback(this, rowAtk, plotInd);
                            else
                                grandChildrenCount = rowAtk.getChildrenCount();
                                for l = 1:grandChildrenCount
                                    % get the id
                                    rowAtl = rowAtk.getChildAt(l-1);
                                    helperCallback(this, rowAtl, plotInd);
                                end
                            end
                        end
                    end
                end
            end
            
            
            % repaint the table
            this.InspectTT.TT.repaint();
            
            % update inspect signals axis
            this.updateInspAxes();
        end
        
    catch %#ok
        % Do nothing here as the table may have collapsed or erased and we
        % don't need to do anything.
    end
end

function helperCallback(this, row, plotInd)
	id = row.getValueAt(20);
	% get the status in the table
	toSetVal = row.getValueAt(plotInd);
	% set the visibility of the signal
	this.SDIEngine.setVisibility(int32(id), toSetVal);
end