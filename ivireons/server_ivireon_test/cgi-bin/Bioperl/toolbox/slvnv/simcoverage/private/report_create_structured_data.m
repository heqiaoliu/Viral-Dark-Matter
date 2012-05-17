function [cvstruct,sysCvIds] = report_create_structured_data(allTests, testIds, metricNames, toMetricNames, options, waitbarH, onlyTopSystem)   

% Copyright 2003-2008 The MathWorks, Inc.
    global gdecision;
    if nargin < 7
        onlyTopSystem = false;
    end

    if nargin < 6
        waitbarH = [];
    end
	
    if nargin < 5
        %unfortunately tstateflow lvlOne_ttblock is using it and has to
        %pass empty options
        options = cvi.ReportUtils.parseOptionString([],'');
        options.cumulativeReport = false;
    end
    if nargin < 4
        %unfortunately tstateflow lvlOne_ttblock is using it and has to
        %pass empty options
        toMetricNames = [];
    end

    modelcovId = cv('get',allTests{1}.rootId,'.modelcov');
    [~, modelName] = cv('get',modelcovId,'.handle','.name');

    cvi.ReportData.updateDataIdx(allTests{1});
    cvstruct.root.cvId = allTests{1}.rootId;
    cvstruct.tests = testIds;
    cvstruct.allCvData = allTests;
    cvstruct.model.name = modelName;
    cvstruct.model.cvId = modelcovId;
    cvstruct.system = [];
    cvId = cv('get',allTests{1}.rootId,'.topSlsf');

    % Return early if there is nothing to report
    if isempty(metricNames) && isempty(toMetricNames)
        sysCvIds = [];
        return;
    end

	% Cyclomatic complexity metric index
	allmetrics = cvi.MetricRegistry.getDDEnumVals;
	cycloEnum = allmetrics.MTRC_CYCLCOMPLEX;
	
    % Order the set of coverage IDs
    [sysCvIds,blockCvIds,depths] = cv('DfsOrder',cvId,'ignore',allmetrics.MTRC_SIGRANGE);
    
    % Return early if there is nothing to report
    if isempty(sysCvIds)
        sysCvIds = [];
        return;
    end
    
    reportData = cvi.ReportData.getInstance;
        % Setup metrics global data

    for i = 1:length(metricNames)
        if ~(strcmpi(metricNames{i},'sigrange') ||  ...
            strcmpi(metricNames{i},'sigsize'))
            feval(['report_' lower(metricNames{i}) '_setup'], allTests{:});
        end
    end
    
    if ~isempty(toMetricNames)
         reportData.addTestobjectiveData(toMetricNames, allTests{:});
    end

    
    if (onlyTopSystem)
        sysCvIds = sysCvIds(1);
        depths = depths(1);
        blockCvIds = [];
    end
    sysCnt = length(sysCvIds);
    blockCnt = length(blockCvIds);

    
    % Variables for the waitbar display
    waitInc = sysCnt+blockCnt;
    waitVal = 0;
    
    % Preallocate the info structure
    metricCnt = length(metricNames);
    metricSysPreAlloc(1:2:(2*metricCnt-1)) = metricNames;
    metricBlkPreAlloc = metricSysPreAlloc;
    
    for i=1:metricCnt
        metricSysPreAlloc{2*i} = cell(1,sysCnt);
        metricBlkPreAlloc{2*i} = cell(1,blockCnt);
    end
    
    cvstruct.system = struct( ...
                        'name',             cell(1,sysCnt), ...
                        'sysNum',           num2cell(1:sysCnt), ...
                        'cvId',             num2cell(sysCvIds), ...
                        'depth',            num2cell(depths), ...
                        'complexity',       cell(1,sysCnt), ...
                        'sysCvId',          cell(1,sysCnt), ...
                        'subsystemCvId',    cell(1,sysCnt), ...
                        'blockIdx',         cell(1,sysCnt), ...
                        'flags',            cell(1,sysCnt), ...
                        metricSysPreAlloc{:});
                        

    if (blockCnt>0)
        cvstruct.block = struct( ...
                            'name',             cell(1,blockCnt), ...
                            'index',            num2cell(1:blockCnt), ...
                            'cvId',             num2cell(blockCvIds), ...
                            'complexity',       cell(1,blockCnt), ...
                            'sysCvId',          cell(1,blockCnt), ...
                            'flags',            cell(1,blockCnt), ...
                            metricBlkPreAlloc{:});
    end
    
    
    % Each coverage metric will have a list of objects that detail the exact coverage
    % information.  The arrays for storing these objects will be dynamically created
    metricObjs = cell(1,length(metricNames));
    metricObjsCnt = num2cell(zeros(1,length(metricNames)));
    toMetricObjs = cell(1,length(toMetricNames));
    toMetricObjsCnt = num2cell(zeros(1,length(toMetricNames)));
        
    % ===================================================================================
    % Loop to update the system information
    % ===================================================================================

    removeSystems = zeros(1,sysCnt);

    for i=1:sysCnt
        cvId = sysCvIds(i);
        [name,origin,parent] = cv('get',cvId, ...
                                    '.name', ...
                                    '.origin', ...
                                    '.treeNode.parent');
                                                                        
        [cmplx_ismodule,cmplx_shallow,cmplx_deep,var_cmplx_shallowIdx,var_cmplx_deepIdx,hasVariableSize] = cv('MetricGet',cvId,cycloEnum, ...
                                '.dataIdx.deep','.dataCnt.shallow','.dataCnt.deep','.dataCnt.varShallowIdx', '.dataCnt.varDeepIdx','.hasVariableSize');    
        
        if isempty(cmplx_ismodule)
            cmplx_ismodule = 0;
            cmplx_shallow = 0;
            cmplx_deep = 0;
        end 
        
        var_cmplx_deep = 0;
        var_cmplx_shallow = 0;
        if hasVariableSize
            if (var_cmplx_deepIdx  >= 0)
                var_cmplx_deep = gdecision(var_cmplx_deepIdx + 1, end);
            end
            if (var_cmplx_shallowIdx >= 0)
                var_cmplx_shallow = gdecision(var_cmplx_shallowIdx + 1, end);
            end
        end

                                                                      
        children = cv('ChildrenOf',cvId,'ignore',allmetrics.MTRC_SIGRANGE);
        children = children(children~=cvId);
        isLeaf = (cv('get',children,'.treeNode.child') == 0);
        
        cvstruct.system(i).subsystemCvId = children(~isLeaf);
        blockIds = children(isLeaf);
       
        cvstruct.system(i).complexity = struct( 'isModule', cmplx_ismodule, ...
                                                'shallow', cmplx_shallow, ...
                                                'deep', cmplx_deep,...
                                                'varShallow', var_cmplx_shallow, ...
                                                'varDeep', var_cmplx_deep);

                                                
        if (origin==2)
           cvstruct.system(i).name = ['SF: ' name];
        else
           cvstruct.system(i).name = name;
        end
        cvstruct.system(i).sysCvId = parent;
        if ~onlyTopSystem && ~isempty(blockIds)
            blkCnt = length(blockIds);
            firstChildIdx = find(blockIds(1)==blockCvIds);
            cvstruct.system(i).blockIdx = (1:blkCnt)+firstChildIdx-1;
        end
        
        %%%%%%%%%%%%%%%%%%%%%
        % Analyze metrics for
        % this system
        flags.fullCoverage = -1;
        flags.noCoverage = -1;
        flags.leafUncov = 0;
        
        noData = 1;
        for j=1:length(metricNames)
            thisMetric =  metricNames{j};
            [data,thisMetricFlags,objs] = feval(['report_' lower(thisMetric) '_system'],cvstruct.system(i),metricObjsCnt{j});
            
            cvstruct.system(i).(thisMetric)= data;
            metricObjs{j} = [metricObjs{j} objs];
            metricObjsCnt{j} = metricObjsCnt{j} + length(objs);
            [noData flags] = buildFlags(noData, flags, thisMetricFlags);

        end
        for j=1:numel(toMetricNames)
            thisMetric =  toMetricNames{j};
            [data,thisMetricFlags,objs] = reportData.getSystemTestobjective(cvstruct.system(i),toMetricObjsCnt{j}, thisMetric);
            cvstruct.system(i).(thisMetric)= data;
            toMetricObjs{j} = [toMetricObjs{j} objs];
            toMetricObjsCnt{j} = toMetricObjsCnt{j} + length(objs);
            [noData flags] = buildFlags(noData, flags, thisMetricFlags);
        end
        
        cvstruct.system(i).flags = flags;
        removeSystems(i) = noData;
        if (~isempty(waitbarH))
            waitVal = waitVal+1;
            waitbar(waitVal/waitInc,waitbarH);
        end
    end
  
    % ===================================================================================
    % Loop to update the block information
    % ===================================================================================

    removeBlocks = zeros(1,blockCnt);
    for i=1:blockCnt
        cvId = blockCvIds(i);
        [name,origin,parent, isDisabled] = cv('get',cvId,'.name','.origin','.treeNode.parent','.isDisabled');
        
        if ~isDisabled

            [cmplx_ismodule,cmplx_shallow,cmplx_deep,var_cmplx_shallowIdx,var_cmplx_deepIdx,hasVariableSize] = cv('MetricGet',cvId,cycloEnum, ...
                                    '.dataIdx.deep','.dataCnt.shallow','.dataCnt.deep','.dataCnt.varShallowIdx','.dataCnt.varDeepIdx','.hasVariableSize');     

            if isempty(cmplx_ismodule)
                cmplx_ismodule = 0;
                cmplx_shallow = 0;
                cmplx_deep = 0;
            end 


            var_cmplx_deep = 0;
            var_cmplx_shallow = 0;
            if hasVariableSize
                if (var_cmplx_deepIdx  >= 0)
                    var_cmplx_deep = gdecision(var_cmplx_deepIdx + 1, end);
                end
                if (var_cmplx_shallowIdx >= 0)
                    var_cmplx_shallow = gdecision(var_cmplx_shallowIdx + 1, end);
                end
            end



            if (origin==2)
               cvstruct.block(i).name = ['SF: ' name];
            else
               cvstruct.block(i).name = name;
            end
            cvstruct.block(i).sysCvId = parent;
            cvstruct.block(i).complexity = struct( 'isModule', cmplx_ismodule, ...
                                                    'shallow', cmplx_shallow, ...
                                                    'deep', cmplx_deep,...
                                                    'varShallow', var_cmplx_shallow, ...
                                                    'varDeep', var_cmplx_deep);


            %%%%%%%%%%%%%%%%%%%%%
            % Analyze metrics for
            % this block

            noData = 1;
            flags.fullCoverage = -1;
            flags.noCoverage = -1;
            flags.leafUncov = 0;

            for j = 1:length(metricNames)
                thisMetric =  metricNames{j};
                [data,thisMetricFlags,objs] = feval(['report_' lower(thisMetric) '_block'],cvstruct.block(i),metricObjsCnt{j});
                cvstruct.block(i).(thisMetric) = data;
                metricObjs{j} = [metricObjs{j} objs];
                metricObjsCnt{j} = metricObjsCnt{j} + length(objs);
                [noData flags] = buildFlags(noData, flags, thisMetricFlags);
            end
            for metricsIdx = 1:length(toMetricNames)
                thisMetric =  toMetricNames{metricsIdx};
                [data,thisMetricFlags,objs] = reportData.getBlockTestobjective(cvstruct.block(i),toMetricObjsCnt{metricsIdx}, thisMetric);
                toMetricObjs{metricsIdx} = [toMetricObjs{metricsIdx} objs];
                toMetricObjsCnt{metricsIdx} = toMetricObjsCnt{metricsIdx} + length(objs);
                cvstruct.block(i).(thisMetric) = data;
                [noData flags] = buildFlags(noData, flags, thisMetricFlags);
            end

            removeBlocks(i) = noData;
            cvstruct.block(i).flags = flags;            
        else
            removeBlocks(i) = 1;
        end
        
        if (~isempty(waitbarH))
            waitVal = waitVal+1;
            waitbar(waitVal/waitInc,waitbarH)
        end
    end
    if ~isempty(removeBlocks)
    	removeBlocks = logical(removeBlocks);
        cvstruct.block(removeBlocks) = [];
        ol2new = (1:length(removeBlocks)) - cumsum(removeBlocks);
        
        % Remap the system blockIdx
        for i=1:sysCnt
            removeIdx = removeBlocks(cvstruct.system(i).blockIdx);
            cvstruct.system(i).blockIdx(removeIdx) = [];
            cvstruct.system(i).blockIdx = ol2new(cvstruct.system(i).blockIdx);
        end
    end
    
    % ===================================================================================
    % Update the metric specific info
    % ===================================================================================
    for j=1:length(metricNames)
        thisMetric =  metricNames{j};
		if ~isempty(metricObjs{j})
           	cvstruct = feval(['report_' lower(thisMetric) '_info'],cvstruct,metricObjs{j}, options);
		end
    end
        
    for j=1:length(toMetricNames)
        thisMetric =  toMetricNames{j};
		if ~isempty(toMetricObjs{j})
             cvstruct  = reportData.getTestobjectiveInfo(cvstruct,toMetricObjs{j},thisMetric);
		end
    end


    % ===================================================================================
    % Prune the uneeded systems
    % ===================================================================================
    if options.elimFullCov
        fullcovSys = find_full_coverage_systems(removeSystems, cvstruct);
        removeSystems = logical(removeSystems | fullcovSys);
    else
        removeSystems = logical(removeSystems);
    end
	
    [removeSystems,cvstruct] = fix_sf_based_block_hierarchy(removeSystems,cvstruct);

    cvstruct.system(removeSystems) = [];
	keepSysCvIds = sysCvIds(~removeSystems);
	
	% Remap indices and remove zeros
    for i=1:length(cvstruct.system)
    	cvstruct.system(i).subsystemCvId = intersection(cvstruct.system(i).subsystemCvId,keepSysCvIds);
    end
%=========================

function [noData flags] = buildFlags(noData, flags, thisMetricFlags)

    % Update the flag values based on this metric
    if ~isempty(thisMetricFlags)
        noData = 0;
        if(isfield(thisMetricFlags,'fullCoverage')) 
            if (thisMetricFlags.fullCoverage)
                if (flags.fullCoverage == -1)
                    flags.fullCoverage = 1;
                    flags.noCoverage = 0;
                end
            else
                flags.fullCoverage = 0;
            end
        end

        if (isfield(thisMetricFlags,'noCoverage'))
             if (thisMetricFlags.noCoverage)
                if (flags.noCoverage == -1)
                    flags.noCoverage = 1;
                    flags.fullCoverage = 0;
                end
             else
                flags.noCoverage = 0;
             end 
        end

        if (isfield(thisMetricFlags,'leafUncov') && ...
             thisMetricFlags.leafUncov)
             flags.leafUncov = 1;
        end
    end

    
%===================
function [removeSystems,cvstruct] = fix_sf_based_block_hierarchy(removeSystems,cvstruct)
% For eML, truth table blocks, do not report the wrapper "chart" coverage

    cfChartIsa = sf('get','default','chart.isa');
    
    for sysIdx = 1:length(cvstruct.system)
        if ~removeSystems(sysIdx)
            [origin,sfId,sfIsa] = cv('get',cvstruct.system(sysIdx).cvId,'.origin','.handle','.refClass');
            if (origin==2 && sfIsa==cfChartIsa) % Stateflow chart object
                if ~sf('Private', 'is_sf_chart', sfId) % Not classic sf chart. i.e. eM/TT blocks
                    kernelFcnBlockIdx = cvstruct.system(sysIdx).blockIdx;
                    parentSysIdx = sysIdx - 1;

                    cvstruct.system(parentSysIdx).blockIdx = kernelFcnBlockIdx;
                    removeSystems(sysIdx) = 1;
                end
            end
        end
    end
    
function out = intersection(s1,s2)
    r = sort([s1(:);s2(:)]);
    I = (r(1:(end-1))==r(2:end));
    out = r(I);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIND_FULL_COVERAGE_SYSTEMS - Eliminate systems 
% that were fully covered

function removeSystems = find_full_coverage_systems(removeSystems, cvstruct)
   sysCnt = length(cvstruct.system);
    for i=1:sysCnt
        if (cvstruct.system(i).flags.fullCoverage==1)
            removeSystems(i) = 1;
        end
    end




