function status = isSldvGenHarness(modelH)

%   Copyright 2009 The MathWorks, Inc.

    try
        get_param(modelH,'SldvGeneratedHarnessModel');
        status = true;
    catch Mex %#ok<NASGU>
        status = false;
    end
end

% LocalWords:  Sldv
