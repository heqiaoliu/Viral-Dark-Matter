function loadState(this, state)

% Copyright 2009-2010 The MathWorks, Inc.

this.filterState = containers.Map('KeyType', 'int32', 'ValueType', 'any');
fns = fields(state);
for idx = 1 : numel(fns)
    addState(this, fns{idx}, state.(fns{idx}));
end

%==================
function addState(this, propname, value)

for idx = 1 : numel(this.propMap)
    if strcmpi(this.propMap(idx).name, propname)
       [res, il] =intersect(this.propMap(idx).value, value);
       if ~isempty(res)
           this.filterState(idx) = il;
           return;
       end
    end
end

%==================
function currFile = getFile(val)
currFile = '';

if ~isempty(val)
    val = which(val);
    [ currDir, currFile, ext]  = fileparts(val);
    if ~isempty(currDir)
        addpath(currDir);
    end
    currFile =  [currFile ext];

end

