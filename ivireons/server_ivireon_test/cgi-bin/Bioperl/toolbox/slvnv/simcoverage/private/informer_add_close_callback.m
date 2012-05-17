function informer_add_close_callback(uddInformer,cvmodelId)

% Copyright 2004-2008 The MathWorks, Inc.
    
    modelName = cv('get',cvmodelId,'.name');
    
    
    callBackStr = [uddInformer.preCloseFcn ';' 'cvslhighlight(''revert'',', ...
                    'get_param(''' modelName ''',''handle'')); ', ...
                    'cv(''Private'',''cv_remove_sfhighlight'',', ...
                    num2str(cvmodelId) ');'];
                    
    uddInformer.preCloseFcn = callBackStr;