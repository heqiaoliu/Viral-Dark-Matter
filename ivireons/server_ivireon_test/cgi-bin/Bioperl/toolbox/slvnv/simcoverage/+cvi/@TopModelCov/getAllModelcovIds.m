function allIds = getAllModelcovIds(this)

%   Copyright 2008 The MathWorks, Inc.

    topModelcovId = get_param(this.topModelH, 'CoverageId');
    allIds  = cv('get', topModelcovId, '.refModelcovIds');
end      
