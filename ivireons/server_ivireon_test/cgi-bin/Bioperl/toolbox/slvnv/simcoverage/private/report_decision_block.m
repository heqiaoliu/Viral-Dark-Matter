function [decData,flags,decObjs] = report_decision_block(blockInfo,currDecCount)
% DECISION_BLOCK - Synthesize decision coverage data
% for a leaf model object.

% Copyright 1990-2008 The MathWorks, Inc.
% $Revision: 1.1.6.6 $  $Date: 2009/05/14 18:02:38 $

    global gdecision gFrmt;
    flags = [];

    gFrmt.txtDetail = 2;
    metricEnum = cvi.MetricRegistry.getEnum('decision');    
    [decObjs,localIdx,localCnt,varLocalCntIdx, hasLocalVariableSize] = cv('MetricGet',blockInfo.cvId,metricEnum,'.baseObjs', ...
                                        '.dataIdx.shallow','.dataCnt.shallow', '.dataCnt.varShallowIdx', '.hasLocalVariableSize');
    
    if isempty(decObjs)
        decData = [];
        return;
    end

    decData.decisionIdx = currDecCount + (1:length(decObjs));
    decData.outHitCnts = gdecision(localIdx+1,:);
    if hasLocalVariableSize
        localCnt = gdecision(varLocalCntIdx + 1,end);
    end
    decData.totalCnts = localCnt;
    
    if (decData.outHitCnts(end) == localCnt )
        flags.fullCoverage = 1;     
        flags.noCoverage = 0;
        flags.leafUncov = 0;
    else
        flags.fullCoverage = 0;     
        flags.leafUncov = 1;
        if decData.outHitCnts(end) == 0
            flags.noCoverage = 1;
        end
    end




