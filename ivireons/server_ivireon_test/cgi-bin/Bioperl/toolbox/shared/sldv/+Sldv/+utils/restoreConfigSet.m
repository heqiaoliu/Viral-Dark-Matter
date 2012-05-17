function restoreConfigSet(model, oldConfigSet)

%   Copyright 2009 The MathWorks, Inc.

    currConfigSet = getActiveConfigSet(model);
    if isa(oldConfigSet,'Simulink.ConfigSetRef') || ...
            (currConfigSet ~= oldConfigSet)
        setActiveConfigSet(model, oldConfigSet.Name);
        detachConfigSet(model, currConfigSet.Name);
    end
end

