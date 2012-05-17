function changed = safe_set_param(blockH,paramName,paramValue)

%   Copyright 2009 The MathWorks, Inc.

    oldValue = get_param(blockH,paramName);
    changed = false;
    if(~isequal(oldValue,paramValue))
        changed = true;
        set_param(blockH,paramName,paramValue);
    end
