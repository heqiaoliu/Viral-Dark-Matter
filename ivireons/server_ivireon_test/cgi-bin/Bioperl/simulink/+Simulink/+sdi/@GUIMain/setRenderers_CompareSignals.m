function setRenderers_CompareSignals(this)
    % Copyright 2010 The MathWorks, Inc.
    
    this.TransferDataToScreen_ContextMenuCompareSig();
    this.TransferDataToScreen_ColumnVisibleCompareSigTable();
    
    % Count the number of columns
    colCount = this.compareSignalsTT.TT.getColumnCount;
    colName = cell(1,colCount);
    for i = 1:colCount
        colName{i} = char(this.compareSignalsTT.TT.getColumnName(i-1));
    end
    % cache string dictionary		 
    sd = this.sd;
 
    % text field used by other editors
    tolJTextField = javaObjectEDT('javax.swing.JTextField');
    
    % set editor for Run name
    runNameEditor = javaObjectEDT('com.mathworks.toolbox.sdi.sdi.CustomCellEditor',...
                                      tolJTextField, int32(0));
    this.compareSignalsTT.TT.getColumnModel.getColumn(0).setCellEditor...
                                                         (runNameEditor);
    hRunNameEditor = handle(runNameEditor, 'callbackproperties');
    hRunNameEditor.EditingStoppedCallback = {@this.callback_RunNameEditor};
    
    % channel
    channelInd = strmatch(sd.mgChannel, colName) - 1;
    
    if ~isempty(channelInd)
        channelRenderer = javaObjectEDT('javax.swing.table.DefaultTableCellRenderer');
        channelRenderer.setHorizontalAlignment(javax.swing.JLabel.RIGHT);
        this.compareSignalsTT.TT.getColumnModel.getColumn(channelInd).setCellRenderer(channelRenderer);
    end
    
    % port
    portInd = strmatch(sd.IGPortIndexColName, colName) - 1;
    
    if ~isempty(portInd)
        portRenderer = javaObjectEDT('javax.swing.table.DefaultTableCellRenderer');
        portRenderer.setHorizontalAlignment(javax.swing.JLabel.RIGHT);
        this.compareSignalsTT.TT.getColumnModel.getColumn(portInd).setCellRenderer(portRenderer);
    end
    
    % dimensions
    dimInd = strmatch(sd.mgDimensions, colName) - 1;
    
    if ~isempty(dimInd)
        dimRenderer = javaObjectEDT('javax.swing.table.DefaultTableCellRenderer');
        dimRenderer.setHorizontalAlignment(javax.swing.JLabel.RIGHT);
        this.compareSignalsTT.TT.getColumnModel.getColumn(dimInd).setCellRenderer(dimRenderer);
    end
 
    
    % block source
    blkSrc = strmatch(sd.IGBlockSourceColName, colName) - 1;
    
    if ~isempty(blkSrc)        
        column_blk = javaMethod('getColumn',                         ...
                                 this.compareSignalsTT.TT.getColumnModel,...
                                 blkSrc);
        javaMethodEDT('setPreferredWidth', column_blk, 150);
        tooltiprenderer = javaObjectEDT('com.mathworks.toolbox.sdi.sdi.ToolTipRenderer');
        this.compareSignalsTT.TT.getColumnModel.getColumn(blkSrc).setCellRenderer(tooltiprenderer);
    end
    
    % color - line style
    colorIndex = strmatch(sd.mgLine, colName);
    if ~isempty(colorIndex)
        column_color = javaMethod('getColumn',                            ...
                                  this.compareSignalsTT.TT.getColumnModel,...
                                  colorIndex-1);
        javaMethodEDT('setResizable', column_color, false);
        javaMethodEDT('setMaxWidth', column_color, 45);
        LineStyleCellRenderer = javaObjectEDT...
                                ('com.mathworks.toolbox.sdi.sdi.ColorStyleCellRenderer');
        this.compareSignalsTT.TT.getColumnModel.getColumn...
            (colorIndex-1).setCellRenderer(LineStyleCellRenderer);
        % Line Style - Cell Editor
        this.colorEditorCompSig =                                ...
            javaObjectEDT(                                       ...
            'com.mathworks.toolbox.sdi.sdi.ColorStyleCellEditor',...
            this.compareSignalsTT.TT);
        this.compareSignalsTT.TT.getColumnModel.getColumn...
             (colorIndex-1).setCellEditor(this.colorEditorCompSig);
    end

    % Tolerance values
    abstolInd   = strmatch(sd.mgAbsTol, colName);
    reltolInd   = strmatch(sd.mgRelTol, colName);
    syncInd     = strmatch(sd.mgSyncMethod, colName);
    interpInd   = strmatch(sd.mgInterpMethod, colName); 
    tolCellRenderer = javaObjectEDT('com.mathworks.toolbox.sdi.sdi.CustomCellRenderer');
    tolCellRenderer.setHorizontalAlignment(javax.swing.JLabel.RIGHT);
    leftTolCellRenderer = javaObjectEDT('com.mathworks.toolbox.sdi.sdi.CustomCellRenderer');    
    leftTolCellRenderer.setHorizontalAlignment(javax.swing.JLabel.LEFT);
    
    if ~isempty(abstolInd)
        abstolInd = abstolInd - 1;
        tolJTextField1 = javaObjectEDT('javax.swing.JTextField');
        this.abstolCellEditorCompSig = javaObjectEDT('com.mathworks.toolbox.sdi.sdi.CustomCellEditor',...
                                                     tolJTextField1, this.sd.mgTolernaceNum);
        this.compareSignalsTT.TT.getColumnModel.getColumn...
            (abstolInd).setCellRenderer(tolCellRenderer); 
        this.compareSignalsTT.TT.getColumnModel.getColumn...
             (abstolInd).setCellEditor(this.abstolCellEditorCompSig);   
        this.habstolEditorCompSig = handle(this.abstolCellEditorCompSig,...
                                           'callbackproperties');
        this.habstolEditorCompSig.EditingStoppedCallback = {@this.callback_toleranceCellEditor,    ...
                                                            this.habstolEditorCompSig,             ...
                                                            Simulink.sdi.GUITabType.CompareSignals,...
                                                            Simulink.sdi.ColumnType.absTol};
        
    end
    
    if ~isempty(reltolInd)
        reltolInd = reltolInd - 1;
        tolJTextField2 = javaObjectEDT('javax.swing.JTextField');
        this.reltolCellEditorCompSig = javaObjectEDT('com.mathworks.toolbox.sdi.sdi.CustomCellEditor',...
                                                     tolJTextField2, this.sd.mgTolernaceNum);
        this.compareSignalsTT.TT.getColumnModel.getColumn...
            (reltolInd).setCellRenderer(tolCellRenderer); 
        this.compareSignalsTT.TT.getColumnModel.getColumn...
             (reltolInd).setCellEditor(this.reltolCellEditorCompSig);   
        this.hreltolCellEditorCompSig = handle(this.reltolCellEditorCompSig,...
                                           'callbackproperties');
        this.hreltolCellEditorCompSig.EditingStoppedCallback = {@this.callback_toleranceCellEditor,...
                                                            this.hreltolCellEditorCompSig,         ...
                                                            Simulink.sdi.GUITabType.CompareSignals,...
                                                            Simulink.sdi.ColumnType.relTol};
    end
    
    if ~isempty(syncInd)
        syncInd = syncInd - 1;
        this.syncEditorCompSig = javaObjectEDT('com.mathworks.toolbox.sdi.sdi.SyncMethodEditor',...
                                                   this.compareSignalsTT.TT);
        this.compareSignalsTT.TT.getColumnModel.getColumn...
            (syncInd).setCellRenderer(leftTolCellRenderer); 
        this.compareSignalsTT.TT.getColumnModel.getColumn...
             (syncInd).setCellEditor(this.syncEditorCompSig);   
        this.hsyncEditorCompSig = handle(this.syncEditorCompSig,...
                                         'callbackproperties');
        this.hsyncEditorCompSig.EditingStoppedCallback = {@this.callback_toleranceCellEditor,      ...
                                                            this.hsyncEditorCompSig,               ...
                                                            Simulink.sdi.GUITabType.CompareSignals,...
                                                            Simulink.sdi.ColumnType.sync};
        
    end
    
    if ~isempty(interpInd)
        interpInd = interpInd - 1;
        this.interpCellEditorCompSig = javaObjectEDT('com.mathworks.toolbox.sdi.sdi.InterpMethodEditor',...
                                                     this.compareSignalsTT.TT);
        this.compareSignalsTT.TT.getColumnModel.getColumn...
            (interpInd).setCellRenderer(leftTolCellRenderer); 
        this.compareSignalsTT.TT.getColumnModel.getColumn...
             (interpInd).setCellEditor(this.interpCellEditorCompSig);   
        this.hinterpCellEditorCompSig = handle(this.interpCellEditorCompSig,...
                                         'callbackproperties');
        this.hinterpCellEditorCompSig.EditingStoppedCallback = {@this.callback_toleranceCellEditor,   ...
                                                               this.hinterpCellEditorCompSig,         ...
                                                               Simulink.sdi.GUITabType.CompareSignals,...
                                                               Simulink.sdi.ColumnType.interp};
        
    end
    
    
    % Left and right checkboxes
    leftIndex = strmatch(sd.mgLeft, colName);
    rightIndex = strmatch(sd.mgRight, colName);
    if ~isempty(leftIndex)
        this.checkboxCellEditorLeftCompSig = helperCheckBoxRenderAndEdit...
                                             (this,leftIndex);
        this.checkboxCellEditorRightCompSig = helperCheckBoxRenderAndEdit...
                                              (this,rightIndex);
    end
    
    this.setCallbacks_CompareSignals();
    this.compareSignalsTT.TT.repaint();    
end


% Helper function for setting renderer and editor for checkboxes
function checkboxCellEditor = helperCheckBoxRenderAndEdit(this, index)
    checkboxCellRenderer = javaObjectEDT('com.mathworks.toolbox.sdi.sdi.CheckBoxColumnRenderer');
    checkboxCellEditor   = javaObjectEDT('com.mathworks.toolbox.sdi.sdi.CustomBooleanCheckBoxCellEditor');
    this.compareSignalsTT.TT.getColumnModel.getColumn(index-1).setCellRenderer(checkboxCellRenderer);
    this.compareSignalsTT.TT.getColumnModel.getColumn(index-1).setCellEditor(checkboxCellEditor);
    column = javaMethod('getColumn', this.compareSignalsTT.TT.getColumnModel, index-1);
    javaMethodEDT('sizeWidthToFit', column);
    javaMethodEDT('setResizable', column, false);    
end
    
