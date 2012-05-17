 function res = getFilterState(this)

%   Copyright 2009-2010 The MathWorks, Inc.

res = {};
keys = this.filterState.keys;
for idx = 1 : numel(keys)
    cv = this.filterState(keys{idx});
    prop = this.propMap(keys{idx});
    desc = '';
    for vidx = 1:numel(cv)
       desc = [desc prop.valueDesc{cv(vidx)} ' ']; %#ok<AGROW>
    end
    res{end+1} = [prop.name ' : ' desc]; %#ok<AGROW>
end

