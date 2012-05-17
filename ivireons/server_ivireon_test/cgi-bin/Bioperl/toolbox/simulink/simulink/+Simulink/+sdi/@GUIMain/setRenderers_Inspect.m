function setRenderers_Inspect(this)
    % Copyright 2010 The MathWorks, Inc.
    
    this.TransferDataToScreen_ContextMenuInspect();
    this.TransferDataToScreen_ColumnVisibleInspectTable();
    sd = this.sd;
    
    % Count the number of columns
    colCount = this.InspectTT.TT.getColumnCount;
    colName = cell(1,colCount);
    for i = 1:colCount
        colName{i} = char(this.InspectTT.TT.getColumnName(i-1));
    end
    
    % text field used by other editors
    tolJTextField = javaObjectEDT('javax.swing.JTextField');
    
    % set editor for Run name
    runNameEditorInsp = javaObjectEDT('com.mathworks.toolbox.sdi.sdi.CustomCellEditor',...
                                      tolJTextField, int32(0));
    this.InspectTT.TT.getColumnModel.getColumn(0).setCellEditor...
                                                  (runNameEditorInsp);
    hRunNameEditorInsp = handle(runNameEditorInsp, 'callbackproperties');
    hRunNameEditorInsp.EditingStoppedCallback = {@this.callback_RunNameEditor};
    
    % channel
    channelInd = strmatch(sd.mgChannel, colName) - 1;
    
    if ~isempty(channelInd)
        channelRenderer = javaObjectEDT('javax.swing.table.DefaultTableCellRenderer');
        channelRenderer.setHorizontalAlignment(javax.swing.JLabel.RIGHT);
        this.InspectTT.TT.getColumnModel.getColumn(channelInd).setCellRenderer(channelRenderer);
    end
    
    % port
    portInd = strmatch(sd.IGPortIndexColName, colName) - 1;
    
    if ~isempty(portInd)
        portRenderer = javaObjectEDT('javax.swing.table.DefaultTableCellRenderer');
        portRenderer.setHorizontalAlignment(javax.swing.JLabel.RIGHT);
        this.InspectTT.TT.getColumnModel.getColumn(portInd).setCellRenderer(portRenderer);
    end
    
    % dimensions
    dimInd = strmatch(sd.mgDimensions, colName) - 1;
    
    if ~isempty(dimInd)
        dimRenderer = javaObjectEDT('javax.swing.table.DefaultTableCellRenderer');
        dimRenderer.setHorizontalAlignment(javax.swing.JLabel.RIGHT);
        this.InspectTT.TT.getColumnModel.getColumn(dimInd).setCellRenderer(dimRenderer);
    end
    
    % **********************************
    % **** Inspect Signals - Select ****
    % **********************************
    
    % Inspect Signals - Select - Cell Renderer
    % Inspect Signals - Select - Cell Editor
    blockInd = strmatch(sd.IGBlockSourceColName, colName) - 1;
    
    if ~isempty(blockInd)
        tooltiprenderer = javaObjectEDT('com.mathworks.toolbox.sdi.sdi.ToolTipRenderer');
        this.InspectTT.TT.getColumnModel.getColumn(blockInd).setCellRenderer(tooltiprenderer);
        column_blk = javaMethod('getColumn',                      ...
                                 this.InspectTT.TT.getColumnModel,...
                                 blockInd);
        javaMethodEDT('setPreferredWidth', column_blk, 150);

    end
    
    plotIndex = strmatch(sd.MGInspectColNamePlot, colName);
    if ~isempty(plotIndex)
        checkboxCellRenderer = javaObjectEDT('com.mathworks.toolbox.sdi.sdi.CheckBoxColumnRenderer', 1);
        this.checkboxCellEditorInsp   = javaObjectEDT('com.mathworks.toolbox.sdi.sdi.CustomBooleanCheckBoxCellEditor');
        this.hCheckBoxEditorInsp = handle(this.checkboxCellEditorInsp, 'callbackproperties');
        this.hCheckBoxEditorInsp.EditingStoppedCallback = {@(s,e)this.callback_CheckBoxInsp};
        this.InspectTT.TT.getColumnModel.getColumn(plotIndex-1).setCellRenderer(checkboxCellRenderer);
        this.InspectTT.TT.getColumnModel.getColumn(plotIndex-1).setCellEditor(this.checkboxCellEditorInsp);
        column_plot = javaMethod('getColumn', this.InspectTT.TT.getColumnModel, plotIndex-1);
        javaMethodEDT('setResizable', column_plot, false);
        javaMethodEDT('setMaxWidth', column_plot, 55);        
    end
    
    this.InspectTT.TableCallback.MouseClickedCallback = ...
        {@this.tableMouseClickedCallback_Inspect};
    
    
    %     % **************************************
    %     % **** Inspect Signals - Line Style ****
    %     % **************************************
    %
    % Inspect Signals - Line Style - Cell Renderer
    
    colorIndex = strmatch(sd.mgLine,colName);
    
    if ~isempty(colorIndex)
        column_color = javaMethod('getColumn', this.InspectTT.TT.getColumnModel, colorIndex-1);
        javaMethodEDT('setResizable', column_color, false);
        javaMethodEDT('setMaxWidth', column_color, 45);
        LineStyleCellRenderer = javaObjectEDT('com.mathworks.toolbox.sdi.sdi.ColorStyleCellRenderer');
        this.InspectTT.TT.getColumnModel.getColumn(colorIndex-1).setCellRenderer(LineStyleCellRenderer);
        % Inspect Signals - Line Style - Cell Editor
        this.colorEditorInsp = javaObjectEDT('com.mathworks.toolbox.sdi.sdi.ColorStyleCellEditor',this.InspectTT.TT);
        this.InspectTT.TT.getColumnModel.getColumn...
            (colorIndex-1).setCellEditor(this.colorEditorInsp);
    end
   
    
    %     % *************************************
    %     % **** Inspect Signals - Tolerance ****
    %     % *************************************
    %

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
        this.abstolCellEditorInsp = javaObjectEDT('com.mathworks.toolbox.sdi.sdi.CustomCellEditor',...
                                                     tolJTextField1, this.sd.mgTolernaceNum);
        this.InspectTT.TT.getColumnModel.getColumn...
            (abstolInd).setCellRenderer(tolCellRenderer); 
        this.InspectTT.TT.getColumnModel.getColumn...
             (abstolInd).setCellEditor(this.abstolCellEditorInsp);   
        this.habstolEditorInsp = handle(this.abstolCellEditorInsp,...
                                           'callbackproperties');
        this.habstolEditorInsp.EditingStoppedCallback = {@this.callback_toleranceCellEditor,       ...
                                                            this.habstolEditorInsp,                ...
                                                            Simulink.sdi.GUITabType.InspectSignals,...
                                                            Simulink.sdi.ColumnType.absTol};
    end
    
    if ~isempty(reltolInd)
        reltolInd = reltolInd - 1;
        tolJTextField2 = javaObjectEDT('javax.swing.JTextField');
        this.reltolCellEditorInsp = javaObjectEDT('com.mathworks.toolbox.sdi.sdi.CustomCellEditor',...
                                                     tolJTextField2, this.sd.mgTolernaceNum);
        this.InspectTT.TT.getColumnModel.getColumn...
            (reltolInd).setCellRenderer(tolCellRenderer); 
        this.InspectTT.TT.getColumnModel.getColumn...
             (reltolInd).setCellEditor(this.reltolCellEditorInsp);   
        this.hreltolCellEditorInsp = handle(this.reltolCellEditorInsp,...
                                           'callbackproperties');
        this.hreltolCellEditorInsp.EditingStoppedCallback = {@this.callback_toleranceCellEditor,   ...
                                                            this.hreltolCellEditorInsp,            ...
                                                            Simulink.sdi.GUITabType.InspectSignals,...
                                                            Simulink.sdi.ColumnType.relTol};
    end
    
    if ~isempty(syncInd)
        syncInd = syncInd - 1;
        this.syncEditorInsp = javaObjectEDT('com.mathworks.toolbox.sdi.sdi.SyncMethodEditor',...
                                                   this.InspectTT.TT);
        this.InspectTT.TT.getColumnModel.getColumn...
            (syncInd).setCellRenderer(leftTolCellRenderer); 
        this.InspectTT.TT.getColumnModel.getColumn...
             (syncInd).setCellEditor(this.syncEditorInsp);   
        this.hsyncEditorInsp = handle(this.syncEditorInsp,...
                                         'callbackproperties');
        this.hsyncEditorInsp.EditingStoppedCallback = {@this.callback_toleranceCellEditor,         ...
                                                            this.hsyncEditorInsp,                  ...
                                                            Simulink.sdi.GUITabType.InspectSignals,...
                                                            Simulink.sdi.ColumnType.sync};
        
    end
    
    if ~isempty(interpInd)
        interpInd = interpInd - 1;
        this.interpCellEditorInsp = javaObjectEDT('com.mathworks.toolbox.sdi.sdi.InterpMethodEditor',...
                                                     this.InspectTT.TT);
        this.InspectTT.TT.getColumnModel.getColumn...
            (interpInd).setCellRenderer(leftTolCellRenderer); 
        this.InspectTT.TT.getColumnModel.getColumn...
             (interpInd).setCellEditor(this.interpCellEditorInsp);   
        this.hinterpCellEditorInsp = handle(this.interpCellEditorInsp,...
                                         'callbackproperties');
        this.hinterpCellEditorInsp.EditingStoppedCallback = {@this.callback_toleranceCellEditor,      ...
                                                               this.hinterpCellEditorInsp,            ...
                                                               Simulink.sdi.GUITabType.InspectSignals,...
                                                               Simulink.sdi.ColumnType.interp};
    end
    
    this.setCallbacks_Inspect();
    this.InspectTT.TT.repaint();
end
