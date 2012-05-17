function [condData,flags,condObjs] = report_condition_block(blockInfo,currCondCnt)
% CONDITION_BLOCK - Synthesize decision coverage data
% for a leaf model object.

% Copyright 1990-2008 The MathWorks, Inc.
% $Revision: 1.1.6.5 $  $Date: 2009/05/14 18:02:35 $

    global gcondition gFrmt;
    
    flags = [];

    gFrmt.txtDetail = 2;
    
	metricEnum = cvi.MetricRegistry.getEnum('condition');
    [condObjs,localIdx,localCnt,varLocalCntIdx,hasVariableSize] = cv('MetricGet',blockInfo.cvId,metricEnum ,'.baseObjs', ...
                                        '.dataIdx.shallow','.dataCnt.shallow','.dataCnt.varShallowIdx','.hasVariableSize');
    if isempty(localCnt) || localCnt==0
        condData = [];
        return;
    end

    condData.conditionIdx = currCondCnt + (1:length(condObjs));
    condData.localHits = gcondition(localIdx+1,:);
    condData.condCount = length(condObjs);

    if hasVariableSize
        localCnt = gcondition(varLocalCntIdx + 1,end);
    end
    condData.localCnt = localCnt;
    
    if (condData.localHits(end) == localCnt)
        flags.fullCoverage = 1;     
        flags.noCoverage = 0;
        flags.leafUncov = 0;
    else
        flags.fullCoverage = 0;     
        flags.leafUncov = 1;
        if condData.localHits(end)==0
            flags.noCoverage = 1;
        else
            flags.noCoverage = 0;
        end
    end



