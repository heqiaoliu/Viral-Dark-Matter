function this = create(handle)

%   Copyright 1997-2008 The MathWorks, Inc.

try
this = [];
modelH = bdroot(handle);
ph = get_param(get_param(handle,'parent'),'parent');
isCoverage = false;
    isCoverage = strcmpi(get_param(modelH,'compileSupportedByCoverage'), 'on') && ...
    strcmpi(get_param(modelH ,'RecordCoverage'), 'on') && ...
                 get_param(ph, 'CoverageId') ~= 0;

 
isAssert = false;

try %some masks does not have this param
   isAssert  =   strcmpi(get_param(ph, 'enableStopSim'), 'on');
catch MEx %#ok<NASGU>
end
if (isCoverage || isAssert)
        
    mv = get_param(ph,'MaskWSVariables');
    idx = strmatch('customAVTParams',{mv.Name});
    pointHandles = sldvshareprivate('checkSldvSpecification', mv(idx).Value);       
    
    if  ~isempty(pointHandles) && ~isempty(pointHandles{1}) 
        [isValid pointHandles]= sldvshareprivate('checkSldvSpecificationType', pointHandles, get_param(handle, 'handle'));
        if ~isValid && ~strcmpi(get_param(modelH,'compileForCoverageInProgress'),'on')
           error('slvnv:simcoverage:CustomBlockTypeCheckFailed','There is precision loss due to type mismatch between the signal type and the parameter value types');
        end
        
        this = cv.CustomCov; 
        this.m_modelH  = modelH;
        this.m_isCoverage = isCoverage;
        this.m_isCompileForCoverage = strcmpi(get_param(modelH,'compileForCoverageInProgress'),'on');
        this.m_isAssert = isAssert;    

        this.m_handles = pointHandles;
        this.m_handlesForReport = mv(idx).Value;

        this.m_blkTypeName = get_param(ph,'MaskType');
    end
end
catch MEx
    rethrow(MEx);
end


