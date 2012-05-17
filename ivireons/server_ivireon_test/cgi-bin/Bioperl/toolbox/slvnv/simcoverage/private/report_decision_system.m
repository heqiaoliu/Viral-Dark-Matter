function [decData,flags,decObjs] = report_decision_system(sysEntry,currDecCount)
% DECISION_SYSTEM - Synthesize decision coverage data
% for a non-leaf model node.

% Copyright 1990-2008 The MathWorks, Inc.
% $Revision: 1.1.6.7 $  $Date: 2009/05/14 18:02:39 $

    global gdecision gFrmt;
    
    gFrmt.txtDetail = 2;
    metricEnum = cvi.MetricRegistry.getEnum('decision');    
    [decObjs,localIdx,localCnt,varLocalCntIdx, totalIdx,totalCnt,varTotalCntIdx,hasVariableSize,hasLocalVariableSize] = cv('MetricGet',sysEntry.cvId, metricEnum,  ...
                                        '.baseObjs', ...
                                        '.dataIdx.shallow','.dataCnt.shallow','.dataCnt.varShallowIdx', ...
                                        '.dataIdx.deep','.dataCnt.deep', '.dataCnt.varDeepIdx','.hasVariableSize','.hasLocalVariableSize');
    
    if isempty(totalCnt) || totalCnt==0
		flags = [];
        decData = [];
        return;
    end
    
    decData.decisionIdx = currDecCount+(1:length(decObjs));
    if localIdx==-1
        decData.outlocalCnts = [];
    else
        decData.outlocalCnts = gdecision(localIdx+1,:);
    end

    decData.outTotalCnts = gdecision(totalIdx+1,:);
    decData.totalTotalCnts = totalCnt;
    if hasVariableSize
        totalCnt = gdecision(varTotalCntIdx + 1);
    end
    if hasLocalVariableSize
        localCnt = gdecision(varLocalCntIdx + 1, end);
    end
    decData.totalLocalCnts = localCnt;
    decData.totalTotalCnts = totalCnt;
    
    if (decData.outTotalCnts(end) == totalCnt)
        flags.fullCoverage = 1;     
        flags.noCoverage = 0;
        flags.leafUncov = 0;
    else
        flags.fullCoverage = 0;
        if (~isempty(decData.outlocalCnts) && (decData.outlocalCnts(end) ~= localCnt))     
            flags.leafUncov = 1;
        else
            flags.leafUncov = 0;
        end
        if decData.outTotalCnts==0
            flags.noCoverage = 1;
        end
    end



