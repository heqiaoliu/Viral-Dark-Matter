function tableContextMenuCallback_delete(this, ~, ~)
    % Copyright 2010 The MathWorks, Inc.
    
    % Get tab type
    tabType = this.GetTabType;    
    
    % set tree table based on tab type
    switch tabType
        case Simulink.sdi.GUITabType.InspectSignals
            treeTable = this.InspectTT.TT;            
        case Simulink.sdi.GUITabType.CompareSignals
            treeTable = this.compareSignalsTT.TT;
        otherwise
            return;
    end
    
    % get the common treetablemodel
    treeTableModel = this.commonTableModel;
    
    % get selected rows
    rows = treeTable.getSelectedRows;
        
    if isempty(rows)
        row = this.rowObjClicked;
        rows = treeTable.getRowIndex(row);  
        
        % return if nothing is selected
        if rows == -1
            return;
        end            
    end
    
    % get the number of rows
    sz = max(size(rows));
    
    statusDialog = false;
    % Check if a run is also selected
    for i=1:sz
        row = treeTable.getRowAt(rows(i));
        % Don't throw this warning more than once
        if ~statusDialog && (row.getType == 2)  
            warndlg(this.sd.mgSignalChannel, this.sd.mgWarn, 'modal');
            statusDialog = true;                
        end
        
        if  ~isempty(row) && row.getType == 0            
            choice = questdlg(this.sd.mgDeleteRunAndSignals,...
                              this.sd.mgDelete,             ...
                              this.sd.Yes,this.sd.No,       ...
                              this.sd.No);
            % Handle response
            switch choice
                case this.sd.Yes
                    % delete Signals                    
                    helperDeleteSignals(this, treeTable, treeTableModel, rows);   
                    this.dirty = true;
                    return;
                case this.sd.No
                    return; 
                otherwise
                    return;
            end                        
        end
    end
    
    % Ask if they want to delete a signal
    choice = questdlg(this.sd.mgDeleteSignals,...
                      this.sd.mgDelete,       ...
                      this.sd.Yes,this.sd.No, ...
                      this.sd.No);

    % Handle response
    switch choice
        case this.sd.Yes
            % delete Signals
            helperDeleteSignals(this, treeTable, treeTableModel, rows);                      
        otherwise
            return;
    end
    this.dirty = true;

end

function helperDeleteSignals(this, treeTable, treeTableModel, rows)
    tsr = Simulink.sdi.SignalRepository;
    sz = max(size(rows));
    numCols = length(this.colNames);    
        
    % cahce rows as the order may change 
    for j = 1:sz
        rowObj(j) = treeTable.getRowAt(rows(j));        
    end
        
    for i=1:sz
        % continue if the row is already deleted
        if isempty(rowObj(i)) || (rowObj(i).getType == 2)
            continue;
        end
        
        % if the row has children
        if (rowObj(i).getType == 0)    
            % if the sorting is by run name 
            if strcmpi(this.sortCriterion, 'GRUNNAME')
                group = rowObj(i).getValueAt(numCols+2);
                runID = int32(group);
                this.SDIEngine.deleteRun(runID);
            else
                group = rowObj(i).getValueAt(numCols+2);
                this.SDIEngine.deleteBySortCriterion(group,...
                                                     this.sortCriterion);
            end             
            % remove row
            treeTableModel.removeRow(rowObj(i));              
        else
            signalID = javaMethodEDT('getValueAt', rowObj(i), numCols+1);
            try
                signal = this.SDIEngine.getSignal(int32(signalID));                
                [~, ids, ~] = this.SDIEngine.getChildrenAndParent...
                              (signalID);
                if(~isempty(ids))
                    this.SDIEngine.deleteSignal(signalID);
                    parent = rowObj(i).getParent;
                    
                    if (parent.getChildrenCount == 1 && parent.getType == 0)
                        treeTableModel.removeRow(parent);
                        continue;
                    end
                    % delete the parent and grandparent if needed
                    if ~(rowObj(i).hasChildren)  
                        grandParent = parent.getParent;
                        treeTableModel.removeRow(rowObj(i).getParent);
                        if (grandParent.getChildrenCount == 0)
                            treeTableModel.removeRow(grandParent);                            
                        end
                    else
                        treeTableModel.removeRow(rowObj(i));
                    end
                    continue;
                else
                    parent = rowObj(i).getParent;
                    % delete the parent and grandparent if needed
                    if (parent.getChildrenCount == 1 && parent.getType ~= 0)
                        this.SDIEngine.deleteSignal(signalID);
                        treeTableModel.removeRow(rowObj(i));
                        grandParent = parent.getParent;
                        if (grandParent.getChildrenCount == 1 && grandParent.getType == 0)
                            treeTableModel.removeRow(grandParent);
                            continue;
                        end
                        treeTableModel.removeRow(parent);
                        continue;
                    end
                end
                if strcmpi(this.sortCriterion, 'GRUNNAME')
                    runID = signal.RunID;     
                    % delete the parent if needed
                    if (this.SDIEngine.getSignalCount(runID) == 1)
                        rowInd = treeTable.getRowIndex(rowObj(i));
                        rowRun = treeTable.getRowAt(rowInd-1);
                        treeTableModel.removeRow(rowRun);
                        this.SDIEngine.deleteRun(runID);
                        continue;
                    end
                else
                    group = javaMethodEDT('getValueAt', rowObj(i).getParent,...
                                           numCols+2);
                    count = tsr.getIDCount(group, this.sortCriterion);
                    % delete the parent if needed
                    if(count == 1)                        
                        treeTableModel.removeRow(rowObj(i).getParent);
                        this.SDIEngine.deleteBySortCriterion(group,...
                                                     this.sortCriterion);
                        continue;
                    end                    
                end
                this.SDIEngine.deleteSignal(int32(signalID));
                treeTableModel.removeRow(rowObj(i));            
            catch ME %#ok  
            end            
        end        
    end
    
    % Make sure all plots are updated and Save icon is updated
    this.transferStateToScreen_CompareRuns();
    this.transferStateToScreen_plotUpdateCompareSignals();
    this.SetEnable();
    runCount = this.SDIEngine.getRunCount();
    sigCount = this.SDIEngine.getSignalCount();    
    this.updateInspAxes();     
    this.InspectTT.ScrollPane.repaint();
    this.compareSignalsTT.ScrollPane.repaint();

    if (runCount == 0 || sigCount == 0)
        this.helperClearCompareRunsPlot();
    end
end

