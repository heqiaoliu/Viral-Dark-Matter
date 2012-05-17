function removeConfigSetRef(modelH)

%   Copyright 2009 The MathWorks, Inc.

    srcCS = sldvshareprivate('mdl_get_configset', modelH);
    newCS = attachConfigSetCopy(modelH, srcCS, true);
    setActiveConfigSet(modelH, newCS.Name);   
end
