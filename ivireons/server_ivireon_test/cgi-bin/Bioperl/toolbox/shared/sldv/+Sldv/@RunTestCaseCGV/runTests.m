function runTests(obj)

%   Copyright 2010 The MathWorks, Inc.

    obj.prepareInputDataForCGVObj;
    
    obj.setCGVOutputDir;
  
    obj.turnOffAndStoreWarningStatus;
           
    cgvObj = obj.createCGVObj;
    
    cgvSuccess = cgvObj.run; 
    if ~cgvSuccess
        obj.KeepOutputFiles = false;
        msg = xlate(['Unable to execute test vectors using ' ...
                'Code Generation Verification (CGV) API.']);  
        msgId = 'CGVFailed';
        obj.handleMsg('error', msgId, msg);
    else
        obj.CGVObj = cgvObj;
    end
end

% LocalWords:  CGV
