function transferScreenToData_TableToRepository(this, runID, SOE)
    
    % Copyright 2009-2010 The MathWorks, Inc.
    
    for i = 1 : length(SOE.Outputs)
        if(this.ImportVarsTTModel.getValueAt(i-1,8))
            % Cache ith output
            ithOutput = SOE.Outputs(i);
            this.SDIEngine.addToRunSOEOutput(runID, ithOutput);
        end
    end
end
