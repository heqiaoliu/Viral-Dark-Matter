function [obj, propName] = refactor_object_and_property(obj, propName)

% Copyright 2005 The MathWorks, Inc.

    split = regexp(propName, '(?<parent>.*)\.(?<sub>.*)', 'names');
    if ~isempty(split)
        obj = eval(['obj.' split.parent]);
        propName = split.sub;
    end
