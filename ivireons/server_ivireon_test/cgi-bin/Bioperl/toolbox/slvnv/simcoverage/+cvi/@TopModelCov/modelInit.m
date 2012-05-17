
%   Copyright 2008 The MathWorks, Inc.

function modelInit(modelH, hiddenSubSys)
try
  if ~cvi.TopModelCov.checkLicense(modelH)    
      return;
  end
compileForCoverage = strcmpi(get_param(modelH,'compileForCoverageInProgress'),'on');
coveng = cvi.TopModelCov.getInstance(modelH);
%init only if not model reference
% and nor cvsim called
if ~isempty(coveng)  && (~isempty(coveng.covModelRefData) || coveng.isCvCmdCall)
    modelcovId = get_param(modelH, 'CoverageId');
else
    [coveng modelcovId] = cvi.TopModelCov.setup(modelH);
end
if ~compileForCoverage
    if ~cv('Private', 'cv_autoscale_settings', 'isForce', modelH)
        coveng.getResultSettings;
    end

    [testId rootSlHandle] = initTest(coveng, modelcovId, modelH);
    if isempty(rootSlHandle) 
        return;
    end
    if ~isempty(coveng.covModelRefData) && ~coveng.isCvCmdCall
        cvt = cvtest(testId);
        copyMetricsFromModel(cvt, get_param(coveng.topModelH, 'name'));
    end
    initFixptAutoscale(modelH);
else
    rootSlHandle = modelH;
    testId = 0;
end
cv('ModelInit',modelH);
createRoot(modelcovId, rootSlHandle, testId);

cvi.TopModelCov.createSlsfHierarchy(modelH, hiddenSubSys);
coveng.addModelcov(modelH);
setUpTaggingDB(modelH);

catch MEx
    rethrow MEx;
end
%========================================
function setUpTaggingDB( modelH)
if strcmpi(cv('Feature', 'enable coverage filter'), 'off')
    return
end
%covFilterFilename = cv.FilterAssoc.getRule('mTagging');
%if isempty(covFilterFilename)
%    return;
%end
fileName = get_param(modelH, 'CovFilter');
filter = cv.FilterEditor.loadFilter(fileName);

taggingDB = SlvnvTag.TaggingDB(modelH);
taggingDB.addRule(filter );
taggingDB.applyRules(modelH);
allFiltered = taggingDB.getFiltered;

for idx = 1:numel(allFiltered )
   h = Simulink.ID.getHandle(allFiltered{idx});
   covid = get_param(h, 'CoverageId');
   cv('set',  covid, '.isDisabled', 1);
   if cv('get',  covid, '.slBlckType') == 0
       cv('set',  covid, '.allChildrenFiltered', taggingDB.isFiltered(h, true));
   end
end

%========================================
function newRootId = createRoot(modelcovId, rootSlHandle, testId)
coveragePath = '';
if testId ~= 0
  coveragePath = cv('get',testId, '.rootPath');
end
  newRootId = cv('new', 'root', ...
        '.path', coveragePath, ...
        '.topSlHandle', rootSlHandle,...
        '.modelDepth', getBlockDepth(rootSlHandle), ...
        '.modelcov', modelcovId);
    
  cv('set', modelcovId, '.activeRoot', newRootId);

%========================================
function depth = getBlockDepth(handle) 

    bdHandle = bdroot(handle);
    parent = handle;
    depth = 0;

    while(parent ~= bdHandle) 
        parent = get_param(get_param(parent,'parent'), 'handle');
        depth = depth + 1;
    end

%========================================
function [rootSlHandle coveragePath]= getRootSlHandle(coveng, modelH, coveragePath)
    modelName = get_param(modelH,'name');
    rootSlHandle = [];
    if ~isempty(coveragePath)
        fullPath = [modelName '/' coveragePath];
        try
            if strcmp(get_param(get_param(fullPath,'Handle'),'BlockType'),'SubSystem') && ...
                (coveng.topModelH == modelH)
                rootSlHandle = get_param(fullPath,'Handle');
            end
        catch Mex  %#ok<NASGU>
        end
    else
        rootSlHandle = modelH;
    end
    
    if isempty(rootSlHandle)
        warning('SLVNV:simcoverage:cv_init_dialog_test:InvalidPath','Invalid coverage path, ''%s''',coveragePath);
        rootSlHandle = modelH;
        coveragePath = '';
    end
%========================================    
function [testId rootSlHandle] = initTest(coveng, modelcovId, modelH)
    testId = cv('get',modelcovId,'.activeTest');

    if testId == 0

        % First try to resolve the coverage root.  Return early 
        % on failure.
        coveragePath = get_param(modelH,'CovPath');
        if ~isempty(coveragePath) && strcmpi(coveragePath(1), '/') 
            coveragePath(1) = []; % Remove the initial '/'
        end

        [rootSlHandle coveragePath]= getRootSlHandle(coveng, modelH, coveragePath);
        cv('Private', 'model_name_refresh');  % Check for renamed models and update data dictionary
        
        % Create the testdata object    

        test = cvtest(modelH);
        testId = test.id;
        cv('set', 	testId    					    ...
                ,'.type',				    'DLGENABLED_TST' 	...
                ,'.rootPath',				coveragePath );

        activate(test,modelcovId);
    else
        coveragePath = cv('get',testId ,'.rootPath');
         [rootSlHandle coveragePath] = getRootSlHandle(coveng, modelH, coveragePath);
        cv('set',testId ,'.rootPath', coveragePath );
    end
%==========================


function initFixptAutoscale(modelH)
    %Check if fixpt autoscaling any SF models.  If so,
    % set CovAutoscale flag on model and clear log.
    dirtyFlag = get_param(modelH, 'Dirty');
    if sfprivate('is_sf_fixpt_autoscale', modelH) 
        set_param(modelH, 'CovAutoscale', 'on')
        if strcmpi(get_param(modelH, 'MinMaxOverflowArchiveMode'), 'overwrite')
            evalin('base', 'clear global FixPtSimRanges');
        end
    else
        set_param(modelH, 'CovAutoscale', 'off')
    end
    set_param(modelH, 'Dirty', dirtyFlag);
        
        
    