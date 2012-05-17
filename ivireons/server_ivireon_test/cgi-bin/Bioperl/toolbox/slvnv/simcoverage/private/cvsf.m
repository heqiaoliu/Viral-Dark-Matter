function varargout = cvsf(method,varargin)
%CVSF Coverage interface to SF debugger
%

%   Bill Aldrich
%   Copyright 1990-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.11.2.1 $  $Date: 2010/07/06 14:42:38 $

    try
        switch(method)
          case 'InitChartInstance'
            chartId = varargin{1};
            slFullPath = varargin{2};
            [cvStateIds,cvTransIds,cvDataInd,cvChartId] = init_chart_instance(chartId,slFullPath);

            varargout{1} = cvStateIds;
            varargout{2} = cvTransIds;
            if nargout == 3  % Temporary bridge to old sf_debuglib call
                varargout{3} = cvChartId;
            else
                varargout{3} = cvDataInd;
                varargout{4} = cvChartId;
            end
          case 'ReloadIds'
            cvChartId = varargin{1};
            reload_old_instance_ids(cvChartId);
          case 'InitScript'
            scriptNum = varargin{1};
            scriptId = varargin{2};
            chartId = varargin{3};

            varargout{1} = cvi.TopModelCov.scriptInit(scriptId, scriptNum, chartId);

          otherwise
            error('SLVNV:simcoverage:cvsf:UnknownMethod','Unknown method, %s, in cvsf',method);
        end
    catch MEx
        display(MEx.stack(1));
        error('SLVNV:simcoverage:cvsf:error','Error in cvsf: %s',MEx.message);
    end
%===============================
 function res = checkMultiInstanceNormalMode(chartId, slFullPath)

    % store the chart data in order to reload id's in 
    % reload_old_instance_ids 
    res = [];
    origModelName = get_param(bdroot(slFullPath),'ModelReferenceNormalModeOriginalModelName');
    if ~isempty(origModelName) && ~strcmpi(bdroot(slFullPath), origModelName)
         ci.modelName = bdroot(slFullPath);
         ci.machineId = sf('get', chartId, '.machine');
         ci.chartId = chartId;
         ci.path = slFullPath ;
         coveng = cvi.TopModelCov.getInstance(origModelName);
         if ~isfield(coveng.multiInstanceNormaModeSfMap, origModelName)
            coveng.multiInstanceNormaModeSfMap.(origModelName) = {ci};
         else
            coveng.multiInstanceNormaModeSfMap.(origModelName){end+1} = ci;
         end
         res = [origModelName slFullPath(findstr(slFullPath, '/'):end)];
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INIT_CHART_INSTANCE
%   Recreate the chart hierarchy in the coverage tool and install the
%   resulting IDs in the debugger instance info.

function [cvStateIds,cvTransIds,cvDataInd,cvChartId] = init_chart_instance(chartId,slFullPath)
    cvStateIds = [];
    cvTransIds = [];
    cvDataInd = [];
    
    origPath = checkMultiInstanceNormalMode(chartId, slFullPath);
    if ~isempty(origPath)
        slFullPath =  origPath;
    end
    slHandle = get_param(slFullPath,'Handle');
    cvChartSubsysId = get_param(slHandle,'CoverageId');
    % same chart might be initialized, e.g. foreach block

    existingCvChartId = cv('find',cv('ChildrenOf',cvChartSubsysId), 'slsfobj.refClass',sf('get','default','chart.isa'));
    
    if ~isempty(existingCvChartId)
         [cvStateIds, cvTransIds] = find_all_stateflow_ids(existingCvChartId);
         cvChartId = existingCvChartId;
         if ~isempty(cvStateIds) || ~isempty(cvTransIds) 
           [cvDataInd, ~, ~] = get_data_ind(chartId);
           return;
         end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Make sure the chart parent
    % subsystem was created
    if (cvChartSubsysId==0)
        cvChartId = 0;
        return;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Special case for non sf chart Stateflow based blocks, i.e. eM/TT blocks
    if ~sf('Private', 'is_sf_chart', chartId)
        cv('set',cvChartSubsysId,'.refClass',-99);  % -99 ==> not SF chart block
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Create the chart ID and set its
    % parent to the subsystem block.
    modelcovId = cv('get',cvChartSubsysId,'.modelcov');
    cvChartId = cv('new','slsfobj',     1, ...
                   '.origin',          'STATEFLOW_OBJ', ...
                   '.modelcov',        modelcovId, ...
                   '.origPath', slFullPath, ....
                   '.refClass',        sf('get','default','chart.isa'));
    cv('BlockAdoptChildren',cvChartSubsysId,cvChartId);
    cv('set',cvChartId,'.handle',chartId);

    [cvStateIds,cvTransIds] = create_sf(chartId, cvChartId, modelcovId);
    cvDataInd  = add_sigrange(chartId, cvChartId);
%===========================================    
 function [cvStateIds,cvTransIds] = create_sf(chartId, cvChartId, modelcovId)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Create the State slsfobjs
    stateIds = sf('get',chartId,'chart.states');
    stateIds = sf('find',stateIds,'~state.isNoteBox',1);        % Filter notes
    cvStateIds = [];
    cvTransIds = [];
    if ~isempty(stateIds)
        stateNmbrs = sf('get',stateIds,'.number');
        [~,sortI] = sort(stateNmbrs);
        stateIds = stateIds(sortI);

        cvStateIds = cv('new','slsfobj',length(stateIds), ...
                        '.origin',          'STATEFLOW_OBJ', ...
                        '.modelcov',        modelcovId, ...
                        '.refClass',        sf('get','default','state.isa'));

        % Special case for EML/TT blocks the function name is applied.
        if sf('Private', 'is_eml_chart', chartId)
            % Use eml script function name
            cv('set',cvStateIds(1),'.name',sf('get',chartId,'.eml.name'));
        elseif sf('Private', 'is_truth_table_chart', chartId)
            % Use chart name as truth table name
            cv('set',cvStateIds(1),'.name',sf('get',chartId,'.name'));
        end

        for i=1:length(stateIds)
            cv('set',cvStateIds(i),'.handle',stateIds(i));
            % Set the cv name to the label of Boxes
            if (sf('get',stateIds(i),'.type')==3) % is this a box
                cv('set',cvStateIds(i),'.name',sf('get',stateIds(i),'.labelString'));
            end

            % If this is an EML based chart create a cv.codeblock and cache the script contents
            if sf('Private', 'is_eml_based_fcn', stateIds(i))
                codeBlockId = cv('new','codeblock',     1,'.slsfobj',cvStateIds(i), ...
                                 'codeblock.code',sf('get',stateIds(i),'state.eml.script'));
                cv('CodeBloc','refresh',codeBlockId);
                cv('set',cvStateIds(i),'.code',codeBlockId);
            end
        end
        create_descendent_hierarchy(chartId,cvStateIds,chartId,cvChartId);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Create the Trans slsfobjs
    transIds = sf('Private','chart_real_transitions',chartId);
    transIds = sf('find',transIds,'~transition.dst.id',0);  % Filter dangling transitions
    if ~isempty(transIds)
        transNmbrs = sf('get',transIds,'.number');
        [~,sortI] = sort(transNmbrs);
        transIds = transIds(sortI);

        cvTransIds = cv('new','slsfobj',length(transIds), ...
                        '.origin',          'STATEFLOW_OBJ', ...
                        '.modelcov',        modelcovId, ...
                        '.refClass',        sf('get','default','transition.isa'));
        for i=1:length(transIds)
            cv('set',cvTransIds(i),'.handle',transIds(i));
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Place each trans within the
    % state hierarchy
    for i=1:length(transIds)
        trans = transIds(i);
        sfParent = sf('get',trans,'.linkNode.parent');
        if (sfParent==chartId)
            cv('BlockAdoptChildren',cvChartId,cvTransIds(i));
        else
            cv('BlockAdoptChildren',cvStateIds(sf('get',sfParent,'state.number')+1),cvTransIds(i));
        end
    end
%=============================    
function [cvDataInd sortI dwidths] = get_data_ind(chartId)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Add signalranger to the
    % chart
    [~,dwidths,dnumbers] =  cv_sf_chart_data(chartId);
    cvDataInd = 99999*ones(1,max(dnumbers)+1);
    [sortNumbers,sortI] = sort(dnumbers);
    for i=1:length(sortNumbers)
        cvDataInd(sortNumbers(i)+1) = i-1;
    end

function cvDataInd  = add_sigrange(chartId, cvChartId)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Add signalranger to the
    % chart
    [cvDataInd sortI dwidths] = get_data_ind(chartId);
    srId = cv('new','sigranger',            1, ...
              'slsfobj',                              cvChartId);
    cv('set',srId,'.cov.allWidths',         dwidths(sortI)');

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Add the signal ranger to
    % the chart object
    SREnum = cvi.MetricRegistry.getEnum('sigrange');
    cv('MetricInsert',cvChartId,SREnum,srId);
%%====================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CREATE_DESCENDENT_HIERARCHY
%   Recreate the chart hierarchy in the coverage tool and install the
%   resulting IDs in the debugger instance info.

function create_descendent_hierarchy(sfId,stateCvIds,sfChartId,cvChartId)

    sfSubstates = sf('AllSubstatesOf',sfId);
    sfSubstates = sf('find',sfSubstates,'~state.isNoteBox',1);  % Filter notes

    cvChildren = stateCvIds(sf('get',sfSubstates,'state.number')+1);

    if (sfId==sfChartId)
        cvParent = cvChartId;
    else
        cvParent = stateCvIds(sf('get',sfId,'state.number')+1);
    end

    cv('BlockAdoptChildren',cvParent,cvChildren);

    % Call each child recursively
    for child = sfSubstates(:)',
        create_descendent_hierarchy(child,stateCvIds,sfChartId,cvChartId);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RELOAD_OLD_INSTANCE_IDS
%   Find the arrays of cvStateIds and cvTransIds and install these
%   in the debugger portion of the Stateflow S-Function

function reload_old_instance_ids(cvChartId )
    modelcovId = cv('get',cvChartId, '.modelcov');
    modelName = cv('get',modelcovId,'.name');
    sfunName =  [modelName  '_sfun'];
    chartId = cv('get', cvChartId , 'slsfobj.handle');
    [cvStates, cvTrans, ~] = find_all_stateflow_ids(cvChartId);
    coveng = cvi.TopModelCov.getInstance(modelName);
    if isfield(coveng.multiInstanceNormaModeSfMap,modelName)
        for idx = 1:numel(coveng.multiInstanceNormaModeSfMap.(modelName))
            ci = coveng.multiInstanceNormaModeSfMap.(modelName){idx};
            sfunName =  [ci.modelName '_sfun'];
            feval(sfunName,'sf_debug_api','set_instance_cv_ids', ci.machineId, ci.chartId, ci.path, cvStates, cvTrans, cvChartId);    
        end
        coveng.multiInstanceNormaModeSfMap = rmfield(coveng.multiInstanceNormaModeSfMap,modelName);
    end
    % Call the generated S-Function with the new Ids
    path = cv('get',cvChartId,'.origPath');

    machineId = sf('get',chartId,'.machine');
    feval(sfunName,'sf_debug_api','set_instance_cv_ids', machineId, chartId, path, cvStates, cvTrans, cvChartId);
%=================================
function [cvStates, cvTrans, cvChart] = find_all_stateflow_ids(cvChartId)
    sfIsa.state = sf('get','default','state.isa');
    sfIsa.trans = sf('get','default','transition.isa');
    sfIsa.chart = sf('get','default','chart.isa');

    mixedIds = cv('FindDescendantsUntil',cvChartId, sfIsa.chart);

    if ~isempty(mixedIds)
        mixedIsa = cv('get',mixedIds,'.refClass');

        cvStates = mixedIds(mixedIsa==sfIsa.state);
        cvTrans = mixedIds(mixedIsa==sfIsa.trans);
        cvChart = mixedIds(mixedIsa==sfIsa.chart);
        if ~isempty(cvStates)
            % Reorder the states so they match the sequence of sf numbers:
            sfStates = cv('get',cvStates,'.handle');
            stateNmbrs = sf('get',sfStates,'.number');
            [~,sortI] = sort(stateNmbrs);
            cvStates = cvStates(sortI);
        end

        if ~isempty(cvTrans)
            % Reorder the trans so they match the sequence of sf numbers:
            sfTrans = cv('get',cvTrans,'.handle');
            transNmbrs = sf('get',sfTrans,'.number');
            [~,sortI] = sort(transNmbrs);
            cvTrans = cvTrans(sortI);
        end
    else
        cvStates = [];
        cvTrans = [];
        cvChart = [];
    end



