function transferDataToScreen(this)

    % Copyright 2010 The MathWorks, Inc.

    % Cache SDI engine
    SE = this.SDIEngine;
    sr = Simulink.sdi.SignalRepository;
    
    % Run combobox list
    runCount = SE.getRunCount();
    runList = cell(1, runCount);
    this.runIDByIndexMap = Simulink.sdi.Map(int32(0), int32(0));
    
    if(runCount > 0)
        for i = 1 : runCount
            runID = sr.getRunID(int32(i));
            runName = sr.getRunName(runID);
            runList{i} = runName;
            this.runIDByIndexMap.insert(i, runID);
        end
    else
        runList = {'<empty>'};
    end
    
    % Run combobox index
    RunIndex = 1;
    if isempty(this.ExistRunID) && (runCount > 0)
        RunIndex = runCount;
    elseif ~isempty(this.ExistRunID)
        runName  = sr.getRunName(this.ExistRunID);
        RunIndex = find(ismember(runList, runName) == 1);
    end

    % Set run import combobox value
    set(this.ImportToExistCombo, 'String', runList);
    set(this.ImportToExistCombo, 'Value',  RunIndex);
    
    % Update table and context menus
    this.transferDataToScreen_ImportFromImportTo();
    this.transferDataToScreen_Table();
    this.transferDataToScreen_TableColumnVisible();
    this.transferDataToScreen_ContextMenu();
end