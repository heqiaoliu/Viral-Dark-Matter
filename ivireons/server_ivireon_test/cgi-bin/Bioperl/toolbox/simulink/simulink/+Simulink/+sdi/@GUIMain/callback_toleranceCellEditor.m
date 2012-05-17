function callback_toleranceCellEditor(this, source, ~, editorCallback, tabType,...
                                      colType)

    % Copyright 2009-2010 The MathWorks, Inc.
    % This function gets called after tolerance values are edited
    
    % get the editing row
    row = source.getSelectedRow();
    
    % if it's coming from Run Name row or it's empty then don't do anything
    if (isempty(row) || row.getType == 0)
        return;
    end
        
    % get the total number of columns
    colNum = max(size(this.colNames));
    % cache signal repository
    tsr = Simulink.sdi.SignalRepository;
    % cache string dictionary
    sd = this.sd;
    % intialize cell editor
    celleditor = [];

    % Cell editor based on tab type and column type
    switch tabType
        case Simulink.sdi.GUITabType.InspectSignals
            treeTable = this.InspectTT.TT;
            
            if (colType == Simulink.sdi.ColumnType.absTol)
                celleditor = this.abstolCellEditorInsp;
            elseif(colType == Simulink.sdi.ColumnType.relTol)
                celleditor = this.reltolCellEditorInsp;
            end
            
        case Simulink.sdi.GUITabType.CompareSignals
            treeTable = this.compareSignalsTT.TT;
            
            if (colType == Simulink.sdi.ColumnType.absTol)
                celleditor = this.abstolCellEditorCompSig;
            elseif(colType == Simulink.sdi.ColumnType.relTol)
                celleditor = this.reltolCellEditorCompSig;
            end
    end
    
    % get the indices for abs tol and rel tol
    abstolInd   = strmatch(sd.mgAbsTol, this.colNames);
    reltolInd   = strmatch(sd.mgRelTol, this.colNames);
    syncInd     = strmatch(sd.mgSyncMethod, this.colNames);
    interpInd   = strmatch(sd.mgInterpMethod, this.colNames);  
    
    switch colType
        case Simulink.sdi.ColumnType.absTol
            [id, absTol, status] = helperCustomEditorCallback(this,          ...
                                                              editorCallback,...
                                                              tsr, abstolInd,...
                                                              celleditor,    ...
                                                              'absolute');
            % if the value is not double
            if ~status
                return;
            end
            
            this.helperUpdateChildren(abstolInd, @tsr.setAbsoluteTolerance,...
                                      id, source, absTol, treeTable);
            
        case Simulink.sdi.ColumnType.relTol
            [id, relTol, status] = helperCustomEditorCallback(this,          ...
                                                              editorCallback,...
                                                              tsr, reltolInd,...
                                                              celleditor,    ...
                                                              'relative');
            % if the value is not double                                                          
            if ~status
                return;
            end
            
            this.helperUpdateChildren(reltolInd, @tsr.setRelativeTolerance,...
                                      id, source, relTol, treeTable);

            
        case Simulink.sdi.ColumnType.sync                       
            [toleranceVal, signalID, s] = helperComboBoxCallback(this, treeTable,...
                                                                 editorCallback, ...
                                                                 colNum);
            % if the value is not defined                                                               
            if ~s
                return;
            end
            
            this.helperUpdateChildren(syncInd, @tsr.setSyncMethod,...
                                      signalID, source, toleranceVal, treeTable);
            
        case Simulink.sdi.ColumnType.interp
            [toleranceVal, signalID, s] = helperComboBoxCallback(this, treeTable,...
                                                                 editorCallback, ...
                                                                 colNum);
            % if the value is not defined                                                             
            if ~s
                return;
            end
            
            this.helperUpdateChildren(interpInd, @tsr.setInterpMethod,...
                                      signalID, source, toleranceVal, treeTable);
    end
    % update the diff plot if needed
    this.transferStateToScreen_plotUpdateCompareSignals();
    this.dirty = true;    
end

% Helper function for Combobox type editors
function [toleranceVal, id, status] =  helperComboBoxCallback...
                                       (this, treeTable, editorCallback, colNum)
    this.SelectedRow = javaMethodEDT('getSelectedRow',treeTable);
    rowObj = javaMethodEDT('getRowAt', treeTable, this.SelectedRow);
    id = int32(javaMethodEDT('getValueAt', rowObj, colNum+1)); 
    status = true;
    
    % Row cannot have children
    if (rowObj.getType == 0)
        status = false;
    end
    
    comboBox = javaMethodEDT('getComboBox',editorCallback);
    toleranceVal = javaMethodEDT('getSelectedItem', comboBox);
end

% Helper for abstol and reltol editors
function [id, relTol, status] = helperCustomEditorCallback(this, editorCallback,...
                                                           tsr, reltolInd,      ...
                                                           celleditor,          ...
                                                           typeTol)
    sd = this.sd;
    tol = editorCallback.Component.getText;
    relTol = str2double(tol);
    
    % get corresponding signal id
    colNum = max(size(this.colNames)) + 1;
    id = int32(celleditor.getSelectedRow.getValueAt(colNum));
    
    % intialize status
    status = true;
    
    % nan values are not acceptable
    if isnan(relTol) || relTol < 0
        errordlg(sd.mgTolernaceNum, sd.mgError, 'modal');
        tolV = tsr.getTolerance(id);
        relTolV = getfield(tolV, typeTol);        
        row = celleditor.getSelectedRow;
        row.setValueAt(num2str(relTolV), reltolInd - 1);
        this.InspectTT.TT.repaint();
        this.compareSignalsTT.TT.repaint();
        status = false;
    end
end



