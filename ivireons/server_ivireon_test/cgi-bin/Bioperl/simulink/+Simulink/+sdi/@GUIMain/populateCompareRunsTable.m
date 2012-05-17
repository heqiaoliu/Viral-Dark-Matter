function rowList = populateCompareRunsTable(this, numCols)

    % Copyright 2010 The MathWorks, Inc.
    
    % Cache SDI engine
    sde = this.SDIEngine;
    rowList = javaObjectEDT('java.util.ArrayList');
   
    % Cache IDs
    lhsID = int32(sde.AlignRuns.getLHSDataRunID());
    rhsID = int32(sde.AlignRuns.getRHSDataRunID());
    
    % Construct table data
    if (~isempty(lhsID) && (lhsID ~= rhsID))
        
        count = this.SDIEngine.DiffRunResult.getCount();        
        
        for i = 1: count
            diffObj = sde.DiffRunResult.getResultByIndex(i);
            lhsSignalID = diffObj.LHSSignalObj.DataID;
            [status, ids] = this.SDIEngine.getChildrenAndParent(lhsSignalID);
            
            if (~status)
                continue;
            else
                % Create leaf row
                leafRow = javaObjectEDT                         ...
                          ('com.mathworks.toolbox.sdi.sdi.Row', ...
                          numCols);                
                helperPopulate(this, diffObj, leafRow)
                
                if ~isempty(ids)
                    % Set values at various columns for root leaf row
                    blksrc = diffObj.LHSSignalObj.BlockSource;
                    leafRow.setValueAt(blksrc, 1);
                    leafRow.setValueAt(' ', 12);
                    leafRow.setValueAt(' ', 13);
                    leafRow.setValueAt(' ', 14);
                    % number of ids
                    sz = length(ids);                    
                    % Set values at various columns for root leaf row
                    secondLeafRow = javaObjectEDT                        ...
                                   ('com.mathworks.toolbox.sdi.sdi.Row', ...
                                    numCols, 2);
                    
                    % Needs implementation            
                    helperPopulate(this, lhsSignalID, secondLeafRow);                    
                    leafRow.addChild(secondLeafRow);
                    
                    for z = 1:sz
                        % Populate leaves
                        secondLeafRow = javaObjectEDT                        ...
                                       ('com.mathworks.toolbox.sdi.sdi.Row', ...
                                        numCols, 2);
                          
                        helperPopulate(this, int32(ids(z)), secondLeafRow);
                        % add leaf
                        leafRow.addChild(secondLeafRow);
                    end
                end
            end
            rowList.add(leafRow);
        end        
    end
end

function helperPopulate(this, arg2, leafRow)
    % cache SDIEngine
    sde = this.SDIEngine;
    
    if isinteger(arg2)
        % lhsSignalID was passed
        lhsSignalID = arg2;
        rhsSignalID = sde.AlignRuns.getAlignedID(lhsSignalID);
        
        % get diff result from two signal IDs
        result = sde.DiffRunResult.lookupResult(lhsSignalID,...
                                                           rhsSignalID);
        
    else
        % diffObj was passed
        result = arg2;
        lhsSignalID = result.LHSSignalObj.DataID;
    end

                                                   
    blk1 = result.LHSSignalObj.BlockSource;
    dataSrc1 = result.LHSSignalObj.DataSource;
    tol = sde.getTolerance(lhsSignalID);
    sync = sde.getSyncOptions(lhsSignalID);
    absTol = num2str(tol.absolute);
    relTol = num2str(tol.relative);
    interp = sync.InterpMethod;
    sync = sync.SyncMethod;
    channel = num2str(result.LHSSignalObj.Channel);

    sid1 = result.LHSSignalObj.SID;
    typeStr = sde.AlignRuns.getLHSTypeByID(lhsSignalID);

    blk2 = [];
    dataSrc2 = [];
    sid2 = [];

    if (result.Match)
        match = 'aligned';
    else
        match = 'failed';
    end

    if ~isempty(result.RHSSignalObj)
        blk2 = result.RHSSignalObj.BlockSource;
        dataSrc2 = result.RHSSignalObj.DataSource;
        sid2 = result.RHSSignalObj.SID;
    else
        match = 'unaligned';
    end
    
    leafRow.setValueAt(lhsSignalID, 0);
    leafRow.setValueAt(match, 1);
    leafRow.setValueAt(blk1, 2);
    leafRow.setValueAt(blk2, 3);
    leafRow.setValueAt(dataSrc1, 4);
    leafRow.setValueAt(dataSrc2, 5);
    leafRow.setValueAt(sid1, 6);
    leafRow.setValueAt(sid2, 7);
    leafRow.setValueAt(absTol, 8);
    leafRow.setValueAt(relTol, 9);
    leafRow.setValueAt(sync, 10);
    leafRow.setValueAt(interp, 11);
    leafRow.setValueAt(channel, 12);
    leafRow.setValueAt(typeStr, 13);
    leafRow.setValueAt(false, 14);
end
