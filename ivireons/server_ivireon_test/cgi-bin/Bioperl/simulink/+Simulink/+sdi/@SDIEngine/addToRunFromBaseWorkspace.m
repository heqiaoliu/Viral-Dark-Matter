function addToRunFromBaseWorkspace(this, runID, VarNames)

    % Copyright 2009-2010 The MathWorks, Inc.

    % Get values of variable names
    VarValues = Simulink.sdi.Util.BaseWorkspaceValuesForNames(VarNames);

    % Add data to run
    this.addToRunFromNamesAndValues(runID, VarNames, VarValues);
end
