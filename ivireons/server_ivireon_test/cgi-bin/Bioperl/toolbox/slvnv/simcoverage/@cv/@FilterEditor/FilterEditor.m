function this = FilterEditor(fileName, modelName)

% Copyright 2009-2010 The MathWorks, Inc.


this = cv.FilterEditor;


if ischar(modelName)
    [~, modelName ]= fileparts(modelName);
    open_system(modelName);
end
this.modelName  = get_param(modelName,'name');

state = cv.FilterEditor.loadFilter(fileName);
this.covFilter = fileName;

this.getFilterProperties
loadState(this, state);

