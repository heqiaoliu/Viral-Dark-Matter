function sldv_error_push(obj, errMsg, errID)

%   Copyright 2008-2010 The MathWorks, Inc.

    persistent sldvexist

    if isempty(sldvexist)
        sldvexist = license('test','Simulink_Design_Verifier') && exist('slavteng','file')==3;
    end

    if sldvexist
        avtcgirunsupcollect('push', obj, 'sldv', errMsg, errID);
    end

