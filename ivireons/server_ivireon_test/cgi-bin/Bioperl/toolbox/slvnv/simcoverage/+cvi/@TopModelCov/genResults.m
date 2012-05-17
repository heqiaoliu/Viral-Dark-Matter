function genResults(this)

    res = this.getDataResult;
    resultSettings = this.resultSettings;
    refModelCovObjs = this.getAllModelcovIds;
    cvi.TopModelCov.genCovResults(res, resultSettings, refModelCovObjs )
end
