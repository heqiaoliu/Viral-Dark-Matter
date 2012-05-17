function transferStateToScreen_CompareRuns(this)
    % Cache SDI engine
    
    %   Copyright 2010 The MathWorks, Inc.
    
    sde = this.SDIEngine;
    
    % Run combobox list
    runCount = sde.getRunCount();
    
    this.runIDByComboIndexMap = Simulink.sdi.Map(uint32(0), uint32(0));
    this.comboIndexByRunIDMap = Simulink.sdi.Map(uint32(0), uint32(0));

    if(runCount > 0)
                
        % number of populated runs
        counter = 0;
		lhsRunNames = {};
        for i = 1 : runCount
            runID = sde.getRunID(int32(i));
            sigCount = sde.getSignalCount(runID);
            if sigCount > 0
                counter = counter + 1;
                runName = sde.getRunName(runID); 				
				lhsRunNames{end+1} = runName;
				
				% set the strings for pop up menus.. same for both
				set(this.lhsRunCombo, 'String', lhsRunNames);
				set(this.rhsRunCombo, 'String', lhsRunNames);
				
				% populate the Maps
                this.runIDByComboIndexMap.insert(counter, runID);
                this.comboIndexByRunIDMap.insert(runID, counter);
            end
        end
        
        flagLeft = [];
        flagRight = [];
        
        if ~isempty(this.lhsRunID) && ~isempty(this.rhsRunID)
            flagLeft = this.SDIEngine.isValidRunID(this.lhsRunID);
            flagRight = this.SDIEngine.isValidRunID(this.rhsRunID);            
        end
        
        if(~isempty(flagLeft) && flagLeft)
            index = this.comboIndexByRunIDMap.getDataByKey(this.lhsRunID);
            set(this.lhsRunCombo, 'Value', index);
        else
            if (counter-1) > 0
                set(this.lhsRunCombo, 'Value', counter-1);
            elseif (counter == 0)
                set(this.lhsRunCombo, 'Value', 1);
            else
                set(this.lhsRunCombo, 'Value', counter);
            end
        end
        
        if(~isempty(flagRight) && flagRight)
            index = this.comboIndexByRunIDMap.getDataByKey(this.rhsRunID);
            set(this.rhsRunCombo, 'Value', index);
        elseif (counter == 0)
            set(this.lhsRunCombo, 'Value', 1);
        else
            set(this.lhsRunCombo, 'Value', counter);
        end
    else
        % remove all runs		
		runList = this.sd.mgEmpty;
		set(this.lhsRunCombo, 'String', {runList});
		set(this.rhsRunCombo, 'String', {runList});
		set(this.lhsRunCombo, 'Value', 1);
		set(this.rhsRunCombo, 'Value', 1);
		
    end 
end