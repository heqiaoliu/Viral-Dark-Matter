function transferScreenToData(this)

    % Copyright 2010 The MathWorks, Inc.
    rowCount = this.ImportVarsTT.getRowCount();
    
    % Get index of "Import?" column
    importColumnIndex = 8;
    
    % Iterate over all columns, setting value to colValue
    status = false;
    for i = 1 : rowCount
        status = this.ImportVarsTTModel.getValueAt(i - 1, importColumnIndex);
        if status
            break;
        end
    end
    
    if ~status
        return;
    end
        
    if ~isempty(this.SimOutExplorer.Outputs)
        if strcmp(this.NewOrExistRun,'new')            
            % Construct the run name
            runCount = this.SDIEngine.runNumByRunID.getCount();
            if runCount > 0
                maxRunNumber = this.SDIEngine.runNumByRunID.getDataByIndex(runCount);
            else
                maxRunNumber = 0;
            end
            
            dataRunName = ['Run ' num2str(maxRunNumber + 1) ': Imported_Data'];
            dataRunID = this.SDIEngine.createRun(dataRunName);
            updateFlag = 'Imported_Data';
            this.SDIEngine.newRunIDs = dataRunID;
            this.SDIEngine.runNumByRunID.insert(dataRunID, maxRunNumber+1);
        else
            runIndex = get(this.ImportToExistCombo,'Value');            
            if (this.runIDByIndexMap.isKey(runIndex))
                dataRunID = this.runIDByIndexMap.getDataByKey(runIndex);
            else
                return;
            end
            updateFlag = dataRunID;
        end
        try
            this.transferScreenToData_TableToRepository(dataRunID, this.SimOutExplorer);
            this.SDIEngine.updateFlag = updateFlag;
        catch ME%#ok
            SD = Simulink.sdi.StringDict;
            errordlg(SD.mgNoRunID, SD.mgError, 'modal');            
        end
    end
end