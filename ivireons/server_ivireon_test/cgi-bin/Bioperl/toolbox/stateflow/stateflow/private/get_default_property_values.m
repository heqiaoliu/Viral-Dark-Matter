function [propVals, currentVal] = get_default_property_values(obj, propName)

% Copyright 2005-2008 The MathWorks, Inc.

    try
        [obj, propName] = refactor_object_and_property(obj, propName);
        if ~isprop(obj,propName)
            propVals = {}; % A bug?
            currentVal = {};
        elseif ismethod(obj,'isReadonlyProperty') && obj.isReadonlyProperty(propName)
            propVals = {};
            currentVal = get(obj, propName);
        else
            propVals = set(obj, propName);
            propVals = propVals';
            currentVal = get(obj, propName);
        end
    catch MException % Need to suppress lasterror for tg473667
         currentVal = {};
         propVals = {};
    end
