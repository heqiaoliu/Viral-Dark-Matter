function modelName = getGeneratedModel(modelH)

%   Copyright 2009 The MathWorks, Inc.

    pairs = ...
        Sldv.HarnessUtils.getModelParamValuePairs(modelH);
    modelName = '';
    for idx=1:length(pairs)
        if strcmp(pairs(idx).parameter,'TestUnitModel')
            modelName = pairs(idx).value;
            break;
        end
    end
    assert(~isempty(modelName));

end

