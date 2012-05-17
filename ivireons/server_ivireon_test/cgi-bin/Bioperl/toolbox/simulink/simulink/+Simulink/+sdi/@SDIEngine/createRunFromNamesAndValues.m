function [dataRunID,    ...
          DataRunIndex] = createRunFromNamesAndValues(this,     ...
                                                      RunName,  ...
                                                      VarNames, ...
                                                      VarValues,...
                                                      varargin)
    
    % Copyright 2009-2010 The MathWorks, Inc.
        
    % Validate run name
    if ~Simulink.sdi.Util.validateType(RunName, 'char')
        DAStudio.error('SDI:sdi:ValidateString');
    end
    
    res = cellfun(@isempty, VarNames);
    
    if any(res == true)
        DAStudio.error('SDI:sdi:EmptyVarNames');
    end
    
    tsr = Simulink.sdi.SignalRepository;    
    dataRunID = this.createRun(RunName);
    
    % pass in the model name as well if it exists
    this.addToRunFromNamesAndValues(dataRunID, VarNames, VarValues, varargin{:});
    sigCount = tsr.getSignalCount(dataRunID);
    
    % no data in the run so remove it. 
    if sigCount == 0
       tsr.removeEmptyRun(dataRunID);
       dataRunID = [];
       if ~isempty(varargin)
           this.warnDialogParam = varargin{1};
       end
    end
    
    DataRunIndex = tsr.getRunCount();
    this.DoOnCreateRun(dataRunID);  
    this.newRunIDs = dataRunID;
           
    % populate the runID vs runNumber map
    if ~isempty(dataRunID)        
        runCount = this.runNumByRunID.getCount();
        
        if runCount > 0
            maxRunNumber = this.runNumByRunID.getDataByIndex(runCount);
        else
            maxRunNumber = 0;
        end
        
        this.runNumByRunID.insert(dataRunID, maxRunNumber+1);
    end
    
    % if the call is from createRunFromModel then just save the model name
    if isempty(varargin)
        this.updateFlag = RunName; % should fire event   
    else        
        this.updateFlag = varargin{1}; % varargin{1} is the model name
    end
   
end