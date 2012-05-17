function  updateGUI(this, varargin)

    % Copyright 2010 The MathWorks, Inc.
    
    % early return if no params passed
    if isempty(varargin)
        return;
    end
    
    if ~isempty(this.SDIEngine.warnDialogParam)
        % get the model name
        modelName = this.SDIEngine.warnDialogParam;
        this.createMessagesForModel(modelName);       
        this.SDIEngine.warnDialogParam = '';
        return;
    end
    
    % addressing a bug in cell span table. The table has to be at the zero
    % horizontal scroll position when adding new runs. For some reason, it
    % is not able to render properly if there is any horizontal
    % displacement. Will look into this in next release.
    inspectScroll = this.InspectTT.ScrollPane.getHorizontalScrollBar;
    javaMethodEDT('setValue', inspectScroll, 0);
    
    compareSigScroll = this.compareSignalsTT.ScrollPane.getHorizontalScrollBar;
    javaMethodEDT('setValue', compareSigScroll, 0);
    
    if strcmpi(this.sortCriterion, 'GRUNNAME') && ...
       ~isinteger(this.SDIEngine.updateFlag) && ~isempty(this.SDIEngine.newRunIDs)
        % just add specific rows        
        rowList = this.populateTableColumns(this.sortCriterion, ...
                                            this.colNames,      ...
                                            'ASC', false, this.SDIEngine.newRunIDs);                    
        
        % assing newRunIDs to empty for next time.
        this.SDIEngine.newRunIDs = [];
        count = rowList.size();
        
        for i = 1:count        
            this.commonTableModel.addRow(rowList.get(i-1));
            this.commonTableModel.expandRow(rowList.get(i-1), true);
            this.InspectTT.TT.repaint();
            this.compareSignalsTT.TT.repaint();
        end
        
        fileName = this.SDIEngine.updateFlag;
                
    else        
        rowList = this.populateTableColumns(this.sortCriterion, ...
                                            this.colNames,      ...
                                            'ASC');  
        this.tableSortandRender(rowList);  
        if(isinteger(this.SDIEngine.updateFlag))
            fileName = 'Imported_Data';
        else
            fileName = this.SDIEngine.updateFlag;
        end
    end
    
    this.transferStateToScreen_CompareRuns();  
    % set visible (save icons etc.)
    this.SetEnable();
    this.dirty = true;
    % if there is no model or file name just name it simdata
    if isempty(fileName)
        this.defaultName = 'simdata';
    else
        this.defaultName = [char(fileName) '_simdata'];
    end
end

