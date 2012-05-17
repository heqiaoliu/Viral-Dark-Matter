%Coverage Engine

%   Copyright 2008 The MathWorks, Inc.

classdef TopModelCov < handle
  properties
    covModelRefData
    scriptDataMap
    scriptNumToCvIdMap
    lastReportingModelH
    oldModelcovIds
    topModelH
    resultSettings
    multiInstanceNormaModeSfMap
  end
  methods
      function this = TopModelCov(modelH)
          this.topModelH = modelH;
      end
    addModelcov(this, modelH)
    addScriptModelcovId(this, modelH, modelcovId)
    allIds = getAllModelcovIds(this)
    res = isLastReporting(this, modelH)
    setLastReporting(this, modelH)
    getResultSettings(this)
    genResults(this)
    res = getDataResult(this)
    checkCumDataConsistency(this)
    res = isCvCmdCall(this)
  end
  methods(Static)
    coveng = getInstance(modelH)
    [coveng modelcovId] = setup(modelH, varargin)
    term(modelcovId);
    setupFromTopModel(modelH, varargin)
    termFromTopModel(topModelH)
    modelInit(modelH, hiddenSubSys)
    cvScriptId = scriptInit(scriptId, scriptNum, chartId)
    modelStart(modelH)
    modelPause(modelH)
    modelTerm(modelH)
    modelClose(modelH)
    genResultsForSigbuilder(modelH, cvd)
    checkUsupportedBlocks(modelH, settingStr)
    res = checkLicense(modelH)
    createSlsfHierarchy(modelCovId, hiddenSubSys)
    blktypes = getSupportedBlockTypes
    res = isDVBlock(blkH)
    genCovResults(res, resultSettings, refModelCovObjs)
    updateResults(resultSettings, testId)
  end
end
