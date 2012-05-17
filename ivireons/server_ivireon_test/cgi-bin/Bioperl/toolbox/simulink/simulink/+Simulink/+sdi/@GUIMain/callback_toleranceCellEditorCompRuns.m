function callback_toleranceCellEditorCompRuns(this, source, ~, editorCallback,...
                                              colType)

    % This function gets call before updateCriteriaViaComboBox to update
    % the fields of the ChooserPanel.
    %
    % Copyright 2009-2010 The MathWorks, Inc.

    % Set pointer
    figurePointer = get(this.HDialog, 'Pointer');
    set(this.HDialog, 'Pointer', 'watch');
    drawnow;  
    
    tsr = Simulink.sdi.SignalRepository;
    sd = this.sd;
    celleditor = [];
    treeTable = this.compareRunsTT.TT;
    id = [];
           
    if (colType == Simulink.sdi.ColumnType.absTol)
        celleditor = this.abstolCellEditorCompRuns;
    elseif(colType == Simulink.sdi.ColumnType.relTol)
        celleditor = this.reltolCellEditorCompRuns;
    end
    
    abstolInd   = strmatch(sd.mgAbsTol1, this.colNamesCompRun);
    reltolInd   = strmatch(sd.mgRelTol1, this.colNamesCompRun);
    syncInd     = strmatch(sd.mgSync1, this.colNamesCompRun);
    interpInd   = strmatch(sd.mgInterp1, this.colNamesCompRun);  
    
    % call editor callback helpers depending upon column type
    switch colType
        case Simulink.sdi.ColumnType.absTol
            [id, absTol, status] = helperCustomEditorCallback(this,          ...
                                                              editorCallback,...
                                                              tsr, abstolInd,...
                                                              celleditor,    ...
                                                              'absolute');
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
            if ~status
                return;
            end
            
            this.helperUpdateChildren(reltolInd, @tsr.setRelativeTolerance,...
                                      id, source, relTol, treeTable);
            
        case Simulink.sdi.ColumnType.sync                       
            [toleranceVal, id, s] = helperComboBoxCallback(this, editorCallback);
            if ~s
                return;
            end
                            
            this.helperUpdateChildren(syncInd, @tsr.setSyncMethod,...
                                      id, source, toleranceVal, treeTable);
            
        case Simulink.sdi.ColumnType.interp
            [toleranceVal, id, s] = helperComboBoxCallback(this, editorCallback);
            if ~s
                return;
            end
            
            this.helperUpdateChildren(interpInd, @tsr.setInterpMethod,...
                                      id, source, toleranceVal, treeTable);
    end
    
    if ~isempty(celleditor)
        % get the selected row
        row = celleditor.getSelectedRow;
        % recompare the signal
        if ~isempty(id) 
            helperReCompare(this, id, row);
            this.compareRunsTT.TT.repaint();
        end    
    end
    
    this.plotUpdateCompRuns(this.state_SelectedSignalCompRun);
    set(this.HDialog, 'Pointer', figurePointer);
    this.dirty = true;
end

% helper function for combox editors
function [toleranceVal, id, status] =  helperComboBoxCallback...
                                       (this, editorCallback)
    treeTable = this.compareRunsTT.TT;                                   
    selectedRow = javaMethodEDT('getSelectedRow',treeTable);        
    id = int32(treeTable.getModel.getValueAt(selectedRow, 0)); 
    status = true;   
    comboBox = javaMethodEDT('getComboBox',editorCallback);
    toleranceVal = javaMethodEDT('getSelectedItem', comboBox);
end

% helper function for Abs and Rel tol editors
function [id, relTol, status] = helperCustomEditorCallback(this, editorCallback,...
                                                           tsr, reltolInd,      ...
                                                           celleditor,          ...
                                                           typeTol)
    sd = this.sd;
    tol = editorCallback.Component.getText;
    relTol = str2double(tol);
    id = int32(celleditor.getSelected);
    status = true;
    
    % Tol cannot be negative or non-numeric
    if isnan(relTol) || relTol < 0
        errordlg(sd.mgTolernaceNum, sd.mgError, 'modal');
        tolV = tsr.getTolerance(id);
        relTolV = getfield(tolV, typeTol);
        row = celleditor.getSelectedRow;
        row.setValueAt(num2str(relTolV), reltolInd - 1);
        this.compareRunsTT.TT.repaint();
        status = false;
        set(this.HDialog, 'Pointer', 'arrow');
    end
end

% helper for recomparing two signals
function helperReCompare(this, lhsSignalID, row)
    [status, ids] = this.SDIEngine.getChildrenAndParent(lhsSignalID);
    
    if (~status)
        return;
    end
    
    try
        match = helperAlignRuns(this, lhsSignalID); 
        if ~(row.hasChildren)
            row.setValueAt(match, 1);        
        end
    catch %#ok
        % there is no aligned id. No need to do anything
    end
                                             
    if ~isempty(ids)
        for i=1:length(ids)
            lhsID = ids(i);
            helperAlignRuns(this, lhsID);
        end
    end
    
    if row.hasChildren()
        count = row.getChildrenCount;
        for j = 1:count
            child = row.getChildAt(j-1);
            lhsID = child.getValueAt(0);
            match = helperAlignRuns(this, int32(lhsID));
            child.setValueAt(match, 1);             
        end
    end
end

% helper for finding if the signal matches or not
function match = helperAlignRuns(this, lhsSignalID)
    rhsSignalID = this.SDIEngine.AlignRuns.getAlignedID(lhsSignalID);
    
    if isempty(rhsSignalID)
        match = 'Unset';
        return;
    end
    
    lhsSig = this.SDIEngine.getSignal(lhsSignalID);
    lhsRunID = lhsSig.RunID;
    rhsSig = this.SDIEngine.getSignal(rhsSignalID);
    rhsRunID = rhsSig.RunID;
    dsr = this.SDIEngine.diffSignals(lhsRunID, lhsSignalID,...
        rhsRunID, rhsSignalID);
    % Archive signal difference results
    this.SDIEngine.DiffRunResult.addResult(dsr);
    result = this.SDIEngine.DiffRunResult.lookupResult(lhsSignalID,...
        rhsSignalID);
    match = result.Match;
    
    if (match)
        match = 'aligned';
    else
        match = 'failed';
    end
end
    


