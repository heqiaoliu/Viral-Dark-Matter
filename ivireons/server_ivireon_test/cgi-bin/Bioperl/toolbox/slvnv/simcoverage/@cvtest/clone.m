function outTestObj = clone(inTestObj, varargin)

%   Copyright 2008 The MathWorks, Inc.

    outTestObj  = [];
    if ~isempty(varargin) 
        outTestObj = varargin{1};
    end
    inId = inTestObj.id;
    [modelcov,rootPath] = cv('get', inId, '.modelcov', '.rootPath');
    modelName = cv('get',modelcov,'.name');

    if isempty(outTestObj)
        % Get current test properties
        if isempty(rootPath)
            tstPath = modelName;
        else
            tstPath = [modelName '/' rootPath];
        end

        outTestObj = cvtest(tstPath);
    end
    outId = outTestObj.id;

    cloneProps = {  '.label','.mlSetupCmd','.logicBlkShortcircuit','.forceBlockReductionOff','.mldref_enable', ...
                    '.mldref_excludeTopModel','.mldref_excludedModels','.covExternalEMLEnable'};


    copy_cv_obj_properties(inId, outId, cloneProps);
    property.subs = 'settings';    
    property.type = '.';
    subsasgn(outTestObj, property, subsref(inTestObj, property));



function copy_cv_obj_properties(srcId, destId, propList)

    valList = cell(1,length(propList));

    [valList{:}] = cv('get',srcId,propList{:});

    propVal = cell(1,2*length(propList));
    propVal(1:2:end) = propList;
    propVal(2:2:end) = valList;

    cv('set',destId, propVal{:});
