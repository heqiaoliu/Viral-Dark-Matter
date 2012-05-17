function varargout = cv_display_on_model(cvstruct, metricNames, toMetricNames, informerUddObj, options)
%   Copyright 1990-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.10.2.1 $
    persistent colorTable;
   
try
    % Color table accessible externally for testing

    if isempty(colorTable)
        colorTable.sfRed =[0.9 0 0];
        colorTable.sfGreen = [.3 .7 .3];
        colorTable.sfGray = 0.7*[1 1 1];
        colorTable.lightGray = 0.92*[1 1 1];
        colorTable.slRed = '[0.972549, 0.823529, 0.803922]';
        colorTable.slGreen = '[0.803922, 0.952941, 0.811765]';
        colorTable.slGray = '[0.92, 0.92, 0.92]';
    end
    
    if nargin==0 && nargout==1
        varargout{1} = colorTable;
        return;
    else
        varargout = {};
    end
    
    % System table template
    testCnt = length(cvstruct.tests);
    if testCnt>1
        if options.cumulativeReport
            totalIdx = testCnt;
        else
        totalIdx = testCnt+1;
        end
    else
        totalIdx = 1;
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %      Structural coverage     %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fullCovObjs = [];
    missingCovObjs = [];
    
    if any(strcmp(metricNames,'decision')) || ...
        any(strcmp(metricNames,'condition')) || ...
        any(strcmp(metricNames,'mcdc')) || ...
        ~isempty(toMetricNames)
    
    
        % First cache the coverage highlighting for any stateflow library linked charts 
        % because the highlighting will need to change with user navigation 
        modelH = get_param(cvstruct.model.name,'Handle');
        covColorData = get_param(modelH,'covColorData');
        if isempty(covColorData)
            covColorData = covcolordata_struct;
        end
        [linkInfo,chartIds,removeSys] = compute_sf_cov_display(cvstruct);
        
        if ~isempty(linkInfo)
            covColorData.sfLinkInfo = linkInfo;
            set_param(modelH,'covColorData',covColorData);
        end
       
        cvstruct.system(removeSys) = [];
        
        % Loop through each system and itemize coverage

        for i=1:numel(cvstruct.system);
            sysEntry = cvstruct.system(i);
            [fullCovObjs, missingCovObjs] = compute_sys_cov_display(informerUddObj,fullCovObjs,missingCovObjs,sysEntry, cvstruct,toMetricNames, 0);
        end

        coverage_highlight_diagram(cvstruct,fullCovObjs,missingCovObjs,colorTable);

        % Only highlight the active instances of library charts the others will
        % be highlighted dynamically after the call to open_system()
        activeInstanceH = sf('get',chartIds,'.activeInstance');
        activeInstanceH(activeInstanceH==0)=[]; % Remove 0s
        for instH = activeInstanceH(:)'
            cvrefreshsfinstancecov(instH)
        end
    end
                  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %        Signal ranges         %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if any(strcmp(metricNames,'sigrange'))
        modelH = get_param(cvstruct.model.name,'Handle');
        covdata = cvstruct.allCvData{totalIdx};
        map_signal_ranges(modelH,covdata,informerUddObj);
    end

catch MEx
    rethrow MEx;
end

function coverage_highlight_diagram(cvstruct,fullCovObjs,missingCovObjs,colorTable)

    persistent sfFullCovStyle sfNoCovStyle sfMissingCovStyle;
    
    sfIsa = get_sf_isa;
    
    % Style objects
    if isempty(sfFullCovStyle) || ~sf('ishandle',sfFullCovStyle) || ...
       sf('get',sfFullCovStyle,'.isa') ~= sfIsa.style
        sfFullCovStyle = sf('new','style');
        sf('set', sfFullCovStyle,  ...
                    'style.name',                         'Full coverage', ...
                    'style.blockEdgeColor',         colorTable.sfGreen, ...
                    'style.wireColor',              colorTable.sfGreen, ...
                    'style.fontColor',              colorTable.sfGreen, ...
                    'style.bgColor',                colorTable.lightGray);
    end
    
    if isempty(sfNoCovStyle) || ~sf('ishandle',sfNoCovStyle) || ...
       sf('get',sfNoCovStyle,'.isa') ~= sfIsa.style
        sfNoCovStyle = sf('new','style');
        sf('set', sfNoCovStyle,  ...
                    'style.name',                         'No coverage', ...
                    'style.blockEdgeColor',         colorTable.sfGray, ...
                    'style.wireColor',              colorTable.sfGray, ...
                    'style.fontColor',              colorTable.sfGray, ...
                    'style.bgColor',                colorTable.lightGray);
    end
    
    if isempty(sfMissingCovStyle) || ~sf('ishandle',sfMissingCovStyle) || ...
       sf('get',sfMissingCovStyle,'.isa') ~= sfIsa.style
        sfMissingCovStyle = sf('new','style');
        sf('set', sfMissingCovStyle,  ...
                    'style.name',                         'Missing coverage', ...
                    'style.blockEdgeColor',         colorTable.sfRed, ...
                    'style.wireColor',              colorTable.sfRed, ...
                    'style.fontColor',              colorTable.sfRed, ...
                    'style.bgColor',                colorTable.lightGray);
    end
    
    [slMissing,sfMissing] = convert_to_handle_vect(missingCovObjs);
    [slCovered,sfCovered] = convert_to_handle_vect(fullCovObjs);
    
    sfMissing = collect_sublink_trans(sfMissing);
    sfCovered = collect_sublink_trans(sfCovered);
    
    hasStateflow = ~isempty([sfMissing ; sfCovered]);
    
    % Build a list of all states and transitions
    if hasStateflow
        sfChartIds = sf('get',[sfMissing ; sfCovered],'chart.id');
        sfMachIds = sf('get',sfChartIds,'.machine');
        sfMachIds = unique(sfMachIds);
        allSfStates = [];
        
        for chrt = sfChartIds(:)'
            allSfStates = [allSfStates sf('SubstatesIn', chrt)]; %#ok<AGROW>
        end
        allSfTrans = [];
        for st = allSfStates(:)'
            allSfTrans = [allSfTrans sf('TransitionsOf', st)]; %#ok<AGROW>
        end
        noCovTrans = setdiff(allSfTrans,[sfMissing ; sfCovered]);
        noCovStates = setdiff(allSfStates,[sfMissing ; sfCovered]);
    else
        sfMachIds = [];
    end
        
    modelH = get_param(cvstruct.model.name,'Handle');
    slMissing = setdiff(slMissing,modelH);
    slCovered = setdiff(slCovered,modelH);
    
    % For efficiency only apply screen colors to a system that has
    % at least one block with coverage highlighting
    slSystems = get_param(get_param([slMissing ; slCovered],'Parent'),'Handle');
    if iscell(slSystems)
        slSystems = unique([slSystems{:}]);
    end

    % Cache warning state and suppress further warnings
    [prevWarn, prevWarnId] = lastwarn;
    warnState = warning('query');
    warning('off','all');
    
    % Simulink systems
    if ~isempty(slSystems)
        evalc('cvslhighlight(''apply'',modelH,[],[],[],slSystems,colorTable.slGray);');
    end

    
    % Fully covered blocks
    if ~isempty(slCovered)
        evalc('cvslhighlight(''apply'',modelH,slCovered,''black'',colorTable.slGreen);');
    end
    if ~isempty(sfCovered)
        sf('set',sfCovered,'.altStyle',sfFullCovStyle);
    end
    
    % Blocks that don't have coverage
    if (hasStateflow)
        sf('set',[noCovTrans(:) ; noCovStates(:)],'.altStyle',sfNoCovStyle);
    end
    
    % Partially covered blocks
    if ~isempty(slMissing)
        evalc('cvslhighlight(''apply'',modelH,slMissing,''black'',colorTable.slRed);');
    end
    if ~isempty(sfMissing)
        sf('set',sfMissing,'.altStyle',sfMissingCovStyle);
    end


    % Redraw all the charts
    for mchId = sfMachIds(:)'
        sf('Redraw',mchId);
    end
        
    % Restore the warning state
    warning(warnState);
    lastwarn(prevWarn, prevWarnId);
    
    
function [slVect,sfIds] = convert_to_handle_vect(idVect)

    slcvIds = cv('find',idVect,'slsfobj.origin',1);
    sfcvIds = cv('find',idVect,'slsfobj.origin',2);
    slVect = cv('get',slcvIds,'slsfobj.handle');
    sfIds = cv('get',sfcvIds,'slsfobj.handle');
  


function allIds = collect_sublink_trans(mixedIds)

    allIds = mixedIds;
    
    transIsa = sf('get','default','trans.isa');
    transIds = sf('find',allIds,'.isa',transIsa);
    
    subLinks = sf('get',transIds,'.firstSubWire');
    subLinks(subLinks==0) = [];
    
    
    while( ~isempty(subLinks))
        allIds = [allIds ; subLinks]; %#ok<AGROW>
        subLinks = sf('get',subLinks,'.subLink.next');
        subLinks(subLinks==0) = [];
    end
        

function out = get_sf_isa

    persistent sfIsa;

    if isempty(sfIsa)
        sfIsa.machine = sf('get','default','machine.isa');
        sfIsa.chart = sf('get','default','chart.isa');
        sfIsa.state = sf('get','default','state.isa');
        sfIsa.transition = sf('get','default','transition.isa');
        sfIsa.junction = sf('get','default','junction.isa');
        sfIsa.style = sf('get','default','style.isa');
    end
    
    out = sfIsa;

function [cvIds, infrmStrs, isFullCov] = compute_sf_sys(informerUddObj, cvstruct, toMetricNames, sysIdx, suppressDisp)

    if nargin<3
        suppressDisp = 0;
    end
        
    sysEntry = cvstruct.system(sysIdx);
    [missingCov, covStr] = install_informer_text(informerUddObj,sysEntry,cvstruct,toMetricNames,suppressDisp);
    cvIds = sysEntry.cvId;
    infrmStrs = {covStr};
    isFullCov = ~missingCov;
  
    is_a_truth_table = 0;
    if cv('get',sysEntry.cvId,'.origin') == 2
        sfId = cv('get',sysEntry.cvId,'.handle');
        if (sf('get',sfId,'.isa')==sf('get','default','state.isa'))
            is_a_truth_table = sf('get',sfId,'.truthTable.isTruthTable');
        end
    end
    
    if ~is_a_truth_table
        for blockI = sysEntry.blockIdx(:)'
            blkEntry = cvstruct.block(blockI);
            [missingCov, covStr] = install_informer_text(informerUddObj,blkEntry,cvstruct,toMetricNames,suppressDisp);
            cvIds = [cvIds blkEntry.cvId]; %#ok<AGROW>
            infrmStrs = [infrmStrs {covStr}]; %#ok<AGROW>
            isFullCov = [isFullCov ~missingCov]; %#ok<AGROW>
        end
    end




function [instStruct,chartIds,removeSys] = compute_sf_cov_display(cvstruct)

    sfIsa = get_sf_isa;
    
    instStruct = [];
    
    % Find all the Stateflow charts in the coverage data
    sysIds = [cvstruct.system.cvId];
    [sysHandles, sysOrigins, sysIsa] = cv('get',sysIds,'.handle','.origin','.refClass');
    isChartSys = (sysOrigins==2 & sysIsa==sfIsa.chart);

    sfChrtIds = sysHandles(isChartSys);
    
    % See if there are duplicate chart ids (these are multi-instantiated library charts)
    [srtIds, sortIdx] = sort(sfChrtIds);
    dupSys = [0 ; srtIds(1:(end-1))==srtIds(2:end)];
    dupSys = dupSys | [dupSys(2:end) ; 0];
    unsortIdx = 1:length(srtIds);
    unsortIdx(sortIdx) = unsortIdx;
    chartIsDup = dupSys(unsortIdx);
    isDupChartSys = false(1,length(sysIds));
    isDupChartSys(isChartSys) = chartIsDup;
    chartIds = sysHandles(isDupChartSys);
    
    dupChartSys = find(isDupChartSys);
    removeSys = dupChartSys;
    
    for dupIdx = dupChartSys
        
        [cvIds, infrmStrs, isFullCov] = compute_sf_sys([],cvstruct, [], dupIdx, 1);
        childSysIdx = descendent_sys_ind(cvstruct, dupIdx);
        removeSys = [removeSys childSysIdx]; %#ok<AGROW>
        for childIdx = childSysIdx
            [ids, strs, fullCov] = compute_sf_sys([],cvstruct, [], childIdx, 1);
            cvIds = [cvIds ids]; %#ok<AGROW>
            infrmStrs = [infrmStrs strs]; %#ok<AGROW>
            isFullCov = [isFullCov fullCov]; %#ok<AGROW>
        end
        
        % Cache the reference block to determine when the library
        % has been manually closed.
        [refBlockH instanceH ] = cvstruct_instance_handle(cvstruct, dupIdx);

        thisElm = struct(   'instanceH',        instanceH, ...
                            'refBlockH',        refBlockH, ...
                            'cvIds',            cvIds, ...
                            'informerStrings',  {infrmStrs}, ...
                            'isFullCoverage',   isFullCov);
                            
        if isempty(instStruct)
            instStruct = thisElm;
        else
            instStruct(end+1) = thisElm; %#ok<AGROW>
        end
    end
    

function childSysIdx = descendent_sys_ind(cvstruct, parentIdx)
    parentDepth = cvstruct.system(parentIdx).depth;
    
    % Use the fact that systems are entered in topological order
    childSysIdx = [];
    childIdx = parentIdx+1;    
    while (childIdx<=length(cvstruct.system) && cvstruct.system(childIdx).depth>parentDepth)
        childSysIdx = [childSysIdx childIdx]; %#ok<AGROW>
        childIdx = childIdx + 1;
    end


function [refBlockH instanceH] = cvstruct_instance_handle(cvstruct, chartSysIdx)
    cvId = cvstruct.system(chartSysIdx).cvId;
    instanceH  =  get_param(cv('get',cvId, '.origPath'), 'handle');
    refBlockH = get_param(get_param(instanceH,'ReferenceBlock'),'Handle');
 
function [fullCovObjs, missingCovObjs] = compute_missing(informerUddObj, fullCovObjs, missingCovObjs, dataEntry, cvstruct, toMetricNames, suppressDisp)
    missingCov = install_informer_text(informerUddObj,dataEntry,cvstruct,toMetricNames,suppressDisp);
    cvId = dataEntry.cvId;    
    if missingCov
        missingCovObjs = [missingCovObjs cvId];  
    else
        fullCovObjs = [fullCovObjs cvId];  
    end

    
function [fullCovObjs, missingCovObjs] = compute_sys_cov_display(informerUddObj, fullCovObjs, missingCovObjs, sysEntry, cvstruct, toMetricNames, suppressDisp)
        
    [fullCovObjs, missingCovObjs] = compute_missing(informerUddObj, fullCovObjs, missingCovObjs, sysEntry, cvstruct, toMetricNames, suppressDisp);    

    for blockI = sysEntry.blockIdx(:)'
        blkEntry = cvstruct.block(blockI);
        [fullCovObjs, missingCovObjs] = compute_missing(informerUddObj, fullCovObjs, missingCovObjs, blkEntry, cvstruct, toMetricNames, suppressDisp);            
    end
    
