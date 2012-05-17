function deriveCGVParams(obj, runtestOpts)

%   Copyright 2010 The MathWorks, Inc.

    if ~islogical(runtestOpts.allowCopyModel) 
        msgId = 'AllowCopyModelTypeVal';                       
        msg = xlate(['Invalid usage of %s. ', ...                           
                   'The allowCopyModel parameter must have ', ...
                   'a logical value.']);                       
        obj.handleMsg('error', msgId, msg, obj.UtilityName);               
    end
    obj.AllowCopyModel = runtestOpts.allowCopyModel;

    if ~ischar(runtestOpts.cgvCompType) || ...
        ~any(strcmp(runtestOpts.cgvCompType,{'topmodel','modelblock'}))
        msgId = 'CgvTypeVal';                       
        msg = xlate(['Invalid usage of %s. ', ...                           
                   'The cgvCompType parameter must be ', ...
                   'either ''topmodel'' or ''modelblock''.']);                       
        obj.handleMsg('error', msgId, msg, obj.UtilityName);               
    end
    obj.CgvType = runtestOpts.cgvCompType;

    if ~ischar(runtestOpts.cgvConn) || ...
        ~any(strcmp(runtestOpts.cgvConn,{'sim','sil','tasking'}))
        msgId = 'CgvModeOfExecutionVal';                       
        msg = xlate(['Invalid usage of %s. ', ...                           
                   'The cgvConn parameter must be ', ...
                   'either ''sim'', ''sil'' or ''tasking''.']);                       
        obj.handleMsg('error', msgId, msg, obj.UtilityName);               
    end
    obj.CgvModeOfExecution = runtestOpts.cgvConn;
end

% LocalWords:  Cgv cgv modelblock sil topmodel
