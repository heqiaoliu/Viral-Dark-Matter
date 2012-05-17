function pairs = getModelParamValuePairs(modelH)

%   Copyright 2009 The MathWorks, Inc.

    pairs = [];
    if Sldv.HarnessUtils.isSldvGenHarness(modelH)   
        modelParam = get_param(modelH,'SldvGeneratedHarnessModel');
        pattern = '(?<parameter>\w+)=(?<value>(\w*\s*)*)';
        pairs = regexp(modelParam,pattern,'names');
    end
end

% LocalWords:  Sldv
