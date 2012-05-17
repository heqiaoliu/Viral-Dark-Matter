function setRenderers_CompareRuns(this) 
    % Copyright 2010 The MathWorks, Inc.
    
    % get column count - only visible columns
    colCount = this.compareRunsTT.TT.getColumnCount;
    colName = cell(1,colCount);
    sd = this.sd;
    % create a cell array of column names
    for i = 1:colCount
        colName{i} = char(this.compareRunsTT.TT.getColumnName(i-1));
    end
    
    % find column indices
    blk1 = strmatch(sd.mgBlkSrc1, colName) - 1;
    blk2   = strmatch(sd.mgBlkSrc2, colName) - 1;
    dataSrc1   = strmatch(sd.mgDataSrc1, colName) - 1;
    dataSrc2  = strmatch(sd.mgDataSrc2, colName) - 1;
    sid1 = strmatch(sd.mgSID1, colName) - 1;
    sid2  = strmatch(sd.mgSID2, colName) - 1;

    align = strmatch(sd.mgAlignedBy, colName) - 1;   
    test = strmatch(sd.mgTest, colName) - 1; 
    plotInd = strmatch(sd.MGInspectColNamePlot, colName);
    
    % set the icon renderer
    iconRenderer = javaObjectEDT('com.mathworks.toolbox.sdi.sdi.CustomIconRenderer');    
    this.compareRunsTT.TT.getColumnModel.getColumn(test).setCellRenderer(iconRenderer);
    column_test = javaMethod('getColumn',                         ...
                             this.compareRunsTT.TT.getColumnModel,...
                             test);
    javaMethodEDT('setResizable', column_test, false);
    javaMethodEDT('setMaxWidth', column_test, 50);
    
    % Blockpath 1
    if ~isempty(blk1)        
        column_blk1 = javaMethod('getColumn',                         ...
                                 this.compareRunsTT.TT.getColumnModel,...
                                 blk1);
        javaMethodEDT('setPreferredWidth', column_blk1, 150);
        tooltiprenderer = javaObjectEDT('com.mathworks.toolbox.sdi.sdi.ToolTipRenderer');
        this.compareRunsTT.TT.getColumnModel.getColumn(blk1).setCellRenderer(tooltiprenderer);
        
    end
    
        
    % channel
    channelInd = strmatch(sd.mgChannel1, colName) - 1;
    
    if ~isempty(channelInd)
        channelRenderer = javaObjectEDT('javax.swing.table.DefaultTableCellRenderer');
        channelRenderer.setHorizontalAlignment(javax.swing.JLabel.RIGHT);
        this.compareRunsTT.TT.getColumnModel.getColumn(channelInd).setCellRenderer(channelRenderer);
    end
    
    % Blockpath 2
    if ~isempty(blk2)        
        column_blk2 = javaMethod('getColumn',                         ...
                                 this.compareRunsTT.TT.getColumnModel,...
                                 blk2);
        javaMethodEDT('setPreferredWidth', column_blk2, 150);
        tooltiprenderer = javaObjectEDT('com.mathworks.toolbox.sdi.sdi.ToolTipRenderer');
        this.compareRunsTT.TT.getColumnModel.getColumn(blk2).setCellRenderer(tooltiprenderer);
    end
    
    % data source 1
    if ~isempty(dataSrc1)
        column_data1 = javaMethod('getColumn',                         ...
                                  this.compareRunsTT.TT.getColumnModel,...
                                  dataSrc1);
        javaMethodEDT('sizeWidthToFit', column_data1);
    end
    
    % data source 2
    if ~isempty(dataSrc2)
        column_data2 = javaMethod('getColumn',                         ...
                                  this.compareRunsTT.TT.getColumnModel,...
                                  dataSrc2);
        javaMethodEDT('sizeWidthToFit', column_data2);
    end
    
    % sid1
    if ~isempty(sid1)
        column_sid1 = javaMethod('getColumn',                         ...
                                 this.compareRunsTT.TT.getColumnModel,...
                                 sid1);
        javaMethodEDT('sizeWidthToFit', column_sid1);
    end
    
    % sid2
    if ~isempty(sid2)
        column_sid2 = javaMethod('getColumn',                         ...
                                 this.compareRunsTT.TT.getColumnModel,...
                                 sid2);
        javaMethodEDT('sizeWidthToFit', column_sid2);
    end
    
    % align by
    alignByRenderer = javaObjectEDT('javax.swing.table.DefaultTableCellRenderer');
    alignByRenderer.setHorizontalAlignment(javax.swing.JLabel.CENTER_ALIGNMENT);
    this.compareRunsTT.TT.getColumnModel.getColumn...
        (align).setCellRenderer(alignByRenderer);   
    
    % Tolerance renderers
    abstolInd   = strmatch(sd.mgAbsTol1, colName);
    reltolInd   = strmatch(sd.mgRelTol1, colName);
    syncInd     = strmatch(sd.mgSync1, colName);
    interpInd   = strmatch(sd.mgInterp1, colName); 
    tolCellRenderer = javaObjectEDT('com.mathworks.toolbox.sdi.sdi.CustomCellRenderer');
    tolCellRenderer.setHorizontalAlignment(javax.swing.JLabel.RIGHT);
    leftTolCellRenderer = javaObjectEDT('com.mathworks.toolbox.sdi.sdi.CustomCellRenderer');
    leftTolCellRenderer.setHorizontalAlignment(javax.swing.JLabel.LEFT);
    
    if ~isempty(abstolInd)
        abstolInd = abstolInd - 1;
        tolJTextField1 = javaObjectEDT('javax.swing.JTextField');
        this.abstolCellEditorCompRuns = javaObjectEDT('com.mathworks.toolbox.sdi.sdi.CustomCellEditor',...
                                                     tolJTextField1, 0, this.sd.mgTolernaceNum);
        this.compareRunsTT.TT.getColumnModel.getColumn...
            (abstolInd).setCellRenderer(tolCellRenderer); 
        this.compareRunsTT.TT.getColumnModel.getColumn...
             (abstolInd).setCellEditor(this.abstolCellEditorCompRuns);   
        this.habstolEditorCompRuns = handle(this.abstolCellEditorCompRuns,...
                                           'callbackproperties');
        this.habstolEditorCompRuns.EditingStoppedCallback = {@this.callback_toleranceCellEditorCompRuns,    ...
                                                            this.habstolEditorCompRuns,                     ...
                                                            Simulink.sdi.ColumnType.absTol};
    end
    
    if ~isempty(reltolInd)
        reltolInd = reltolInd - 1;
        tolJTextField2 = javaObjectEDT('javax.swing.JTextField');
        this.reltolCellEditorCompRuns = javaObjectEDT('com.mathworks.toolbox.sdi.sdi.CustomCellEditor',...
                                                     tolJTextField2, 0, this.sd.mgTolernaceNum);
        this.compareRunsTT.TT.getColumnModel.getColumn...
            (reltolInd).setCellRenderer(tolCellRenderer); 
        this.compareRunsTT.TT.getColumnModel.getColumn...
             (reltolInd).setCellEditor(this.reltolCellEditorCompRuns);
        this.hreltolCellEditorCompRuns = handle(this.reltolCellEditorCompRuns,...
                                           'callbackproperties');
        this.hreltolCellEditorCompRuns.EditingStoppedCallback = {@this.callback_toleranceCellEditorCompRuns,...
                                                            this.hreltolCellEditorCompRuns,         ...
                                                            Simulink.sdi.ColumnType.relTol};
    end
    
    if ~isempty(syncInd)
        syncInd = syncInd - 1;
        this.syncEditorCompRuns = javaObjectEDT('com.mathworks.toolbox.sdi.sdi.SyncMethodEditor',...
                                                 this.compareRunsTT.TT);
        this.compareRunsTT.TT.getColumnModel.getColumn...
            (syncInd).setCellRenderer(leftTolCellRenderer); 
        this.compareRunsTT.TT.getColumnModel.getColumn...
             (syncInd).setCellEditor(this.syncEditorCompRuns);   
        this.hsyncEditorCompRuns = handle(this.syncEditorCompRuns,...
                                         'callbackproperties');
        this.hsyncEditorCompRuns.EditingStoppedCallback = {@this.callback_toleranceCellEditorCompRuns,      ...
                                                            this.hsyncEditorCompRuns,               ...
                                                            Simulink.sdi.ColumnType.sync};
        
    end
    
    if ~isempty(interpInd)
        interpInd = interpInd - 1;
        this.interpCellEditorCompRuns = javaObjectEDT('com.mathworks.toolbox.sdi.sdi.InterpMethodEditor',...
                                                     this.compareRunsTT.TT);
        this.compareRunsTT.TT.getColumnModel.getColumn...
            (interpInd).setCellRenderer(leftTolCellRenderer); 
        this.compareRunsTT.TT.getColumnModel.getColumn...
             (interpInd).setCellEditor(this.interpCellEditorCompRuns);   
        this.hinterpCellEditorCompRuns = handle(this.interpCellEditorCompRuns,...
                                         'callbackproperties');
        this.hinterpCellEditorCompRuns.EditingStoppedCallback = {@this.callback_toleranceCellEditorCompRuns,   ...
                                                               this.hinterpCellEditorCompRuns,         ...
                                                               Simulink.sdi.ColumnType.interp};
        
    end    
    
    % plot column
    if ~isempty(plotInd)
        checkboxCellRenderer = javaObjectEDT('com.mathworks.toolbox.sdi.sdi.CheckBoxColumnRenderer',...
                                              'compRuns');
        checkboxCellEditorInsp   = javaObjectEDT('com.mathworks.toolbox.sdi.sdi.CustomBooleanCheckBoxCellEditor', 1);
        hCheckBoxEditorInsp = handle(checkboxCellEditorInsp, 'callbackproperties');
        hCheckBoxEditorInsp.EditingStoppedCallback = {@this.callback_CheckBoxCompRun};
        this.compareRunsTT.TT.getColumnModel.getColumn(plotInd-1).setCellRenderer(checkboxCellRenderer);
        this.compareRunsTT.TT.getColumnModel.getColumn(plotInd-1).setCellEditor(checkboxCellEditorInsp);
        column_plot = javaMethod('getColumn', this.compareRunsTT.TT.getColumnModel, plotInd-1);
        javaMethodEDT('setResizable', column_plot, false);
        javaMethodEDT('setMaxWidth', column_plot, 55);        
    end
    
    this.compareRunsTT.TT.repaint();