
%   Copyright 2008 The MathWorks, Inc.

function modelClose(modelH)
try
modelcovId = get_param(modelH, 'CoverageId');
if  (modelcovId ==0) || ~cv('ishandle', modelcovId);
    return
end

coveng = cvi.TopModelCov.getInstance(modelH);

%might be empty after cvload
if ~isempty(coveng)
    informerUddObj = cleanUp(modelH, coveng.getAllModelcovIds);
else
    informerUddObj = cleanUp(modelH, cv('get', modelcovId, '.refModelcovIds'));
end
if cv('ishandle', modelcovId)
    if isempty(informerUddObj)
        informerUddObj =  cvi.ReportUtils.closeInformer(modelcovId);
    end
    cv('ModelClose',modelcovId);
end
if  ~isempty(informerUddObj)
    cv('Private', 'get_informer', 'erase');
end
catch MEx
    rethrow(MEx);
end

%============ clean up
function informerUddObj = cleanUp(modelH, allModelcovIds)
    informerUddObj = [];
    if ~cv('Private', 'cv_autoscale_settings', 'isForce', modelH);
        for currModelcovId = allModelcovIds(:)'
            informerUddObj = cvi.ReportUtils.closeInformer(currModelcovId);
            if ~isempty(informerUddObj)
                break;
            end
        end
    end
    for currModelcovId = allModelcovIds(:)'
        if cv('ishandle', currModelcovId)
            cv('ModelClose',currModelcovId);
        end
    end

