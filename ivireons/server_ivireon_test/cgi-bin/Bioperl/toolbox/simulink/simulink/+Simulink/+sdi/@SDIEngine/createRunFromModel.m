function [DataRunID, DataRunIndex] = createRunFromModel(this, ModelName)

    % Copyright 2009-2010 The MathWorks, Inc.

    % Get a list of variables from the model
    VarNames = Simulink.sdi.Util.GetLogVarNamesFromModel(ModelName);

    % Form the run name
    % get the next run id available
    id = this.getNextRunID();
                  
    % populate the runID vs runNumber map
    
    runCount = this.runNumByRunID.getCount();
    
    if runCount > 0
        maxRunNumber = this.runNumByRunID.getDataByIndex(runCount);
    else
        maxRunNumber = 0;
    end
    
    % prepare the prefix
    runPrefix = ['Run ' num2str(maxRunNumber+1) ': ']; 
    % final run name
    RunName = [runPrefix ModelName];

    % Create data run
    [DataRunID, DataRunIndex] = this.createRunFromBaseWorkspace(RunName, ...
                                                                VarNames,...
                                                                ModelName);

end