function [mcdcData,flags,mcdcObjs] = report_mcdc_system(sysEntry,currMcdcCnt)
% MCDC_SYSTEM - Synthesize condition coverage data
% for a non-leaf model node.

% Copyright 2003-2008 The MathWorks, Inc.

    global gmcdc gFrmt;
    
    flags = [];

    gFrmt.txtDetail = 2;
    metricEnum = cvi.MetricRegistry.getEnum('mcdc');    	    
    [mcdcObjs,localIdx,localCnt,varLocalCntIdx,totalIdx,totalCnt,varTotalCntIdx,hasVariableSize] = cv('MetricGet',sysEntry.cvId, ...
                                        metricEnum,'.baseObjs', ...
                                        '.dataIdx.shallow','.dataCnt.shallow','.dataCnt.varShallowIdx', ...
                                        '.dataIdx.deep','.dataCnt.deep','.dataCnt.varDeepIdx','.hasVariableSize');

    if isempty(totalCnt)
        localIdx = -1;
        totalIdx = -1;
        totalCnt = 0;
        localCnt = 0;
    end
    
    if totalCnt==0
        mcdcData = [];
        return;
    end
    
    mcdcData.mcdcIndex = currMcdcCnt + (1:length(mcdcObjs));
    if localIdx==-1
        mcdcData.localHits = [];
    else
        mcdcData.localHits = gmcdc(localIdx+1,:);
    end

    mcdcData.totalHits = gmcdc(totalIdx+1,:);

    if hasVariableSize
        if varLocalCntIdx > 0
            localCnt = gmcdc(varLocalCntIdx + 1,end);
        end
        totalCnt = gmcdc(varTotalCntIdx + 1);
    end
    mcdcData.localCnt = localCnt;
    mcdcData.totalCnt = totalCnt;

    if (mcdcData.totalHits(end) == totalCnt)
        flags.fullCoverage = 1;     
        flags.noCoverage = 0;
        flags.leafUncov = 0;
    else
        flags.fullCoverage = 0;
        if (~isempty(mcdcData.localHits) && (mcdcData.localHits(end) ~= localCnt))     
            flags.leafUncov = 1;
        else
            flags.leafUncov = 0;
        end        	
        if mcdcData.totalHits(end)==0
            flags.noCoverage = 1;
        else
            flags.noCoverage = 0;
        end
    end



