function addScriptModelcovId(this, modelH, modelcovId)

%   Copyright 2008 The MathWorks, Inc.

    topModelcovId = get_param(this.topModelH, 'CoverageId');
    cv('set', topModelcovId, '.refModelcovIds', unique([cv('get', topModelcovId, '.refModelcovIds'), modelcovId]));
end      
