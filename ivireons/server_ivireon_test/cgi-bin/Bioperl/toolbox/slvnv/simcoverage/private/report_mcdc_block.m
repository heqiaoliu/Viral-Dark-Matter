function [mcdcData,flags,mcdcObjs] = report_mcdc_block(blockInfo,currMcdcCnt)
% MCDC_BLOCK - Synthesize decision coverage data
% for a leaf model object.

% Copyright 2003-2008 The MathWorks, Inc.

    global gmcdc gFrmt;
    
    flags = [];

    gFrmt.txtDetail = 2;
	
    metricEnum = cvi.MetricRegistry.getEnum('mcdc');    	
    [mcdcObjs,localIdx,localCnt,varLocalCntIdx,hasVariableSize] = cv('MetricGet',blockInfo.cvId, ...
                                        metricEnum,'.baseObjs', ...
                                        '.dataIdx.shallow','.dataCnt.shallow','.dataCnt.varShallowIdx','.hasVariableSize');

    if isempty(localCnt) || localCnt==0
        mcdcData = [];
        return;
    end

    mcdcData.mcdcIndex = currMcdcCnt + (1:length(mcdcObjs));
    mcdcData.localHits = gmcdc(localIdx+1,:);
    

    if hasVariableSize
        localCnt = gmcdc(varLocalCntIdx + 1,end);
    end
    mcdcData.localCnt = localCnt;

    if (mcdcData.localHits(end) == localCnt)
        flags.fullCoverage = 1;     
        flags.noCoverage = 0;
        flags.leafUncov = 0;
    else
        flags.fullCoverage = 0;     
        flags.leafUncov = 1;
        if mcdcData.localHits(end)==0
            flags.noCoverage = 1;
        else
            flags.noCoverage = 0;
        end
    end



