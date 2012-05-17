function deriveNonCGVParams(obj, runtestOpts)

%   Copyright 2010 The MathWorks, Inc.

    simData = Sldv.DataUtils.getSimData(obj.SldvData);
    if ~isempty(runtestOpts.testIdx) 
        msg = xlate(['Invalid usage of %s. ', ...                           
                       'The testIdx parameter must specify a single index or ', ...                           
                       'array indexes whose value''s must be less than or ', ...
                       'equal to the number of test cases in the sldvData structure.']);                       
        if ~strcmp(class(runtestOpts.testIdx),'double')
            msgId = 'TcIdxVal';                        
            obj.handleMsg('error', msgId, msg, obj.UtilityName);   
        end        
        if any(runtestOpts.testIdx<1) || any(runtestOpts.testIdx>length(simData))
            msgId = 'TcIdxVal';                        
            obj.handleMsg('error', msgId, msg, obj.UtilityName);   
        end
    else
        runtestOpts.testIdx = 1:length(simData);
    end    
    obj.TcIdx = runtestOpts.testIdx;            
        
    if ~ischar(runtestOpts.outputFormat) || ...
            ~any(strcmp(runtestOpts.outputFormat,{'TimeSeries','StructureWithTime'}))
        msgId = 'OutputFormatVal';                       
        msg = xlate(['Invalid usage of %s. ', ...                           
                   'The outputFormat parameter must be ', ...
                   'either ''TimeSeries'' or ''StructureWithTime''.']);                       
        obj.handleMsg('error', msgId, msg, obj.UtilityName);               
    end
    obj.OutputFormat = runtestOpts.outputFormat;
end

