function updateColorPlotHelper(this, tabType, colorEditorCallback)
    
    % This function gets call after ToleranceCellEditorCallback when the
    % user click finish editing the tolerance column.
    %
    % Copyright 2009-2010 The MathWorks, Inc.
    
    % find out if OK was hit or not
    status = colorEditorCallback.getOKStatus();
    
    % if OK was not hit, abort immediately
    if ~status
        return;
    end
    
    switch tabType
        case Simulink.sdi.GUITabType.InspectSignals
            treeTable = this.InspectTT.TT;
        case Simulink.sdi.GUITabType.CompareSignals
            treeTable = this.compareSignalsTT.TT;
    end
    colNum = 20;

    colorComboBox = javaMethodEDT('getComboBox',colorEditorCallback);     
    this.SelectedRow = javaMethodEDT('getSelectedRow',treeTable);
    rowObj = javaMethodEDT('getRowAt', treeTable, this.SelectedRow);
    
    if (rowObj.hasChildren)
        return;
    end
    
    signalID = javaMethodEDT('getValueAt', rowObj, colNum);
    
    % Set the criteria
    if ~isempty(colorComboBox)
        colorStyleLine = javaMethodEDT('getSelectedItem', colorComboBox);
        if ~isempty(colorStyleLine) && ~ischar(colorStyleLine)
            color    = javaMethodEDT('getColor', colorStyleLine);
            red      = javaMethodEDT('getRed', color);
            blue     = javaMethodEDT('getBlue', color);
            green    = javaMethodEDT('getGreen', color);
            this.SDIEngine.setLineColor(signalID, red/255, green/255, blue/255);
            
            % If this values are change update this in ColorStyleStrokeFactory
            % file.
            % DAVID: Why not use enums?
            strokeConfig = javaMethodEDT('getDashArray', colorStyleLine.drawingStroke)';
            if isequal(strokeConfig, [10 0 10 0])
                this.SDIEngine.setLineStyle(signalID, '-');
            elseif isequal(strokeConfig, [8 2 8 2])
                this.SDIEngine.setLineStyle(signalID, '--');
            elseif isequal(strokeConfig, [2 2 2 2])
                this.SDIEngine.setLineStyle(signalID, ':');
            elseif isequal(strokeConfig, [10 2 2 2])
                this.SDIEngine.setLineStyle(signalID, '-.');
            else
                DAStudio.warning('SDI:sdi:InvalidStyle');
            end
        end
        
        this.HInspectPlot.clearPlot;
        this.updateInspAxes();
        this.transferStateToScreen_plotUpdateCompareSignals();
        javaMethodEDT('updateUI', this.InspectTT.TT);
        javaMethodEDT('updateUI', this.compareSignalsTT.TT);
    end
end
