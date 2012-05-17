function validateRunIDs(this, lhsRunID, rhsRunID)
    % Cache SDI engine

%   Copyright 2010 The MathWorks, Inc.

    SE = this.SDIEngine;
    
    % If either LHS or RHS are empty, resolve LHS
    % and RHS to runs 1 and 2 respectively
    if isempty(lhsRunID)
        lhsRunID = SE.getRunByIndex(1).getID();
    end
    if isempty(rhsRunID)
        rhsRunID = SE.getRunByIndex(2).getID();
    end
    
    % ToDo: Make sure IDs are actually valid
    
    % Cache resolved IDs on alignment object
    SE.AlignRuns.setLHSDataRunID(lhsRunID);
    SE.AlignRuns.setRHSDataRunID(rhsRunID);
end