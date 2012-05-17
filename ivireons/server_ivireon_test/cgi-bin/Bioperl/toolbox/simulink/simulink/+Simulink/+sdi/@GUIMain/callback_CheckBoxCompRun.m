function callback_CheckBoxCompRun(this, source, ~)

    % Copyright 2010 The MathWorks, Inc.
    
    % get if the checkbox is checked or not
    onTableChkBoxValue = source.getCellEditorValue();

    % get the signal ID
    lhsSignalID = source.getSelected();        
    
    try
        sigObj = this.SDIEngine.getSignal(int32(lhsSignalID));
    catch %#ok
        msgbox(this.sd.mgDeletedData,this.sd.mgWarn,'warn', 'modal');
        rowList = javaObjectEDT('java.util.ArrayList');
        this.compareRunsTTModel.setOriginalRows(rowList);
        this.compareRunsTT.TT.repaint();
        cla(this.AxesCompareRunsData, 'reset');
        title(this.AxesCompareRunsData, this.sd.mgSignals);
        cla(this.AxesCompareRunsDiff, 'reset');
        title(this.AxesCompareRunsDiff, this.sd.mgDifference);
    end

    if (~isempty(lhsSignalID) && ~isempty(onTableChkBoxValue))            
        if(onTableChkBoxValue)
            if ~isempty(this.selectedCompRunRow)
                if(this.selectedCompRunRow ~= source.getSelectedRow)
                    this.selectedCompRunRow.setValueAt(false, 14);     
                    this.compareRunsTT.TT.repaint();
                end
            end
            % set the state variable
            this.state_SelectedSignalCompRun = lhsSignalID;
            % set the selected row
            this.selectedCompRunRow = source.getSelectedRow;
            this.plotUpdateCompRuns(lhsSignalID)
        else
            this.state_SelectedSignalCompRun = -1;
            this.helperClearCompareRunsPlot();
        end
    end
end


