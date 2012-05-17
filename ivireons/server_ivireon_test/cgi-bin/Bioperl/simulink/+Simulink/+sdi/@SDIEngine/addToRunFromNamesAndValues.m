function addToRunFromNamesAndValues(this, runID, VarNames, VarValues, varargin)
    
    % Copyright 2009-2010 The MathWorks, Inc.
    
    % Instantiate a simulation output explorer
    SOE = Simulink.sdi.SimOutputExplorer();
    
    % Explore what's in this variable
    SOE.ExploreVariables(VarNames, VarValues);
    
    % initialize model name
    modelName = [];
    
    % copy model name if passed in
    if ~isempty(varargin)
        modelName = varargin{1};
    end
    
    for i = 1 : length(SOE.Outputs)
        % Cache ith output
        ithOutput = SOE.Outputs(i);
        
        % only add this to run if it is from the same model or no model
        % name is passed
        if isempty(modelName) || strcmp(modelName, ithOutput.ModelSource)
            this.addToRunSOEOutput(runID, ithOutput);       
        end
    end % for
end









