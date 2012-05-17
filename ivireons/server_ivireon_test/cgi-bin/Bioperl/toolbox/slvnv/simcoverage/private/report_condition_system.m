function [condData,flags,condObjs] = report_condition_system(sysEntry,currCondCnt)
% CONDITION_SYSTEM - Synthesize condition coverage data
% for a non-leaf model node.

% Copyright 1990-2008 The MathWorks, Inc.
% $Revision: 1.1.6.6 $  $Date: 2009/05/14 18:02:36 $

    global gcondition gFrmt;
    
    flags = [];

    gFrmt.txtDetail = 2;
    metricEnum = cvi.MetricRegistry.getEnum('condition');
    [condObjs,localIdx,localCnt,varLocalCntIdx,totalIdx,totalCnt,varTotalCntIdx,hasVariableSize] = cv('MetricGet',sysEntry.cvId, ...
                                        metricEnum, '.baseObjs', ...
                                        '.dataIdx.shallow','.dataCnt.shallow','.dataCnt.varShallowIdx', ...
                                        '.dataIdx.deep','.dataCnt.deep','.dataCnt.varDeepIdx','.hasVariableSize' );

    if isempty(totalCnt) || totalCnt==0
        condData = [];
        return;
    end
    
    condData.conditionIdx = currCondCnt + (1:length(condObjs));
    if localIdx==-1
        condData.localHits = [];
    else
        condData.localHits = gcondition(localIdx+1,:);
    end
    condData.localCnt = localCnt;
    condData.totalHits = gcondition(totalIdx+1,:);
    condData.totalCnt = totalCnt;
    condData.condCount = length(condObjs);

    if hasVariableSize
        totalCnt = gcondition(varTotalCntIdx + 1);
        if (varLocalCntIdx > 0)
            localCnt = gcondition(varLocalCntIdx + 1,end);
        end
    end
    condData.localCnt = localCnt;
    condData.totalCnt = totalCnt;
    
    if (condData.totalHits(end) == totalCnt)
        flags.fullCoverage = 1;     
        flags.noCoverage = 0;
        flags.leafUncov = 0;
    else
        flags.fullCoverage = 0;
        if (~isempty(condData.localHits) && (condData.localHits(end) ~= localCnt))     
            flags.leafUncov = 1;
        else
            flags.leafUncov = 0;
        end
        if condData.totalHits(end) == 0
            flags.noCoverage = 1;
        else
            flags.noCoverage = 0;
        end
    end


