    function res = getDataResult(this)

%   Copyright 2008 The MathWorks, Inc.

        refModelCovObjs = this.getAllModelcovIds;
        res = [];
        if ~isempty(refModelCovObjs) 
            allTestIds = num2cell(cv('get', refModelCovObjs, '.currentTest')');
            if length(allTestIds) == 1
                res = cvdata(allTestIds{:});
            else
                res = cv.cvdatagroup(allTestIds{:});
            end
        end
    end
