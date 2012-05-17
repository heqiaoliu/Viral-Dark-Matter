function [varargout] = cv_autoscale_settings(method,modelH)
%CV_AUTOSCALE_SETTINGS - Cache and apply coverage settings for SF autoscaling

%   Bill Aldrich
%   Copyright 1990-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/05/20 03:29:15 $

	persistent CovSettingsCache;

	switch(lower(method))
	case 'save'
		CovSettingsCache = save_autoscale(CovSettingsCache, modelH);
	case 'restore'
		CovSettingsCache = restore_autoscale(CovSettingsCache, modelH);
	case 'isforce'
		varargout{1} = is_force(CovSettingsCache, modelH);
	otherwise,
		error('SLVNV:simcoverage:cv_autoscale_settings:UnknownMethod','Unknown Method');
	end

function CovSettingsCache = save_autoscale(CovSettingsCache, modelH)

	% Get index of model in global model list
	modelIndex = model_find_index(CovSettingsCache, modelH);

	% Get relevant coverage params and check for conflict
	vnvLicensed       = license('test','SL_Verification_Validation');
	recordCoverage    = strcmp(get_param(modelH, 'RecordCoverage'), 'on');
	covPath           = get_param(modelH, 'CovPath');
	covMetricSettings = get_param(modelH, 'CovMetricSettings');
	rangeCovEnabled   = ~isempty(strfind(covMetricSettings, 'r'));
	forceCov          = ~vnvLicensed || ~recordCoverage;

	% Push an error message to the Nag controller if conflicts
	
	if isempty(modelIndex)
		% Settings don't exist for this model, append record
		CovSettingsCache = [CovSettingsCache struct('handle',       modelH,...
													'forceCov',     forceCov,...
													'enable',       recordCoverage,...
													'metricString', covMetricSettings,...
													'path',         covPath)];
	else
		% Settings exist for this model, update the record
		CovSettingsCache(modelIndex).forceCov     = forceCov;
		CovSettingsCache(modelIndex).enable       = recordCoverage;
		CovSettingsCache(modelIndex).metricString = covMetricSettings;
		CovSettingsCache(modelIndex).path         = covPath;
	end;
	
    oldDirtyFlag=get_param(modelH,'dirty');
	% As the last part of saving settings we force range coverage on
	if (~recordCoverage || ~vnvLicensed)
	    % We are forcing the model to record coverage so we should
	    % only enable range coverage because the other metrics 
	    % require a license of Simulink Verification and Validation
		set_param(modelH, 'RecordCoverage', 'on');
		set_param(modelH, 'CovMetricSettings', 'r');
		set_param(modelH, 'CovPath', path_to_smallest_sf_model_part(modelH));
	else
	    % Coverage was already enabled for the model so we just need to
	    % insure that range coverage is enabled.
    	if ~rangeCovEnabled
    		set_param(modelH, 'CovMetricSettings', [covMetricSettings 'r']);
    	end
    end
    
    set_param(modelH,'dirty',oldDirtyFlag);


function CovSettingsCache = restore_autoscale(CovSettingsCache, modelH)

	% Get index of model in global model list
	modelIndex = model_find_index(CovSettingsCache, modelH);

	% If model not found return early
	if isempty(modelIndex)
		return;
	end;

	% Restore settings to model
    oldDirtyFlag=get_param(modelH,'dirty');
	if CovSettingsCache(modelIndex).enable
		set_param(modelH, 'RecordCoverage', 'on');
	else
		set_param(modelH, 'RecordCoverage', 'off');
	end;
	set_param(modelH, 'CovPath',           CovSettingsCache(modelIndex).path);
	set_param(modelH, 'CovMetricSettings', CovSettingsCache(modelIndex).metricString);
    set_param(modelH,'dirty',oldDirtyFlag);

function result = is_force(CovSettingsCache, modelH)

	% Assume not forced
	result = 0;

	% Get index of model in global model list
	modelIndex = model_find_index(CovSettingsCache, modelH);

	% If model not found return early
	if isempty(modelIndex)
		return;
	end;

	% Determine if coverage forced for this model
	result = CovSettingsCache(modelIndex).forceCov;


function index = model_find_index(CovSettingsCache, modelH)

	if isempty(CovSettingsCache)
		index = [];
		return;
	end;

	allModels = [CovSettingsCache.handle];
	index = find(allModels == modelH);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The functions below are used to identify the deepest subsystem block that
% contains all of the Stateflow blocks that require fixed point logging.  This
% block will be used as the coverage root so that the memory intensive signal
% range logging can be limited to the smallest portion of the model

function path = path_to_smallest_sf_model_part(modelH)
    modelName = get_param(modelH,'Name');
    blks = find_sf_logging_blocks(modelName);
    ancH = deepest_common_ancestor(blks);
    if(ancH==modelH)
        path = '/';
    else
        path = getfullname(ancH);
        mdlNameLength = length(modelName);
        path = path((mdlNameLength+1):end);
    end

function blks = find_sf_logging_blocks(model)
    if ~ischar(model)
        model = get_param(model,'Name');
    end
    
    blks    = [];
	rt      = sfroot;
	machine = rt.find('-isa', 'Stateflow.Machine', '-and', 'Name', model);
	if ~isempty(machine)
	
		% Get Stateflow blocks
		chartsObjs = machine.findDeep('Chart');
		chartIds   = [];
		for i = 1:length(chartsObjs)
			chartIds = [chartIds chartsObjs(i).Id];
		end
		blocks = sf('Private', 'chart2block', chartIds);
	
		% Get compiled fixpt autoscale log setting
		logs = get_param(blocks, 'MinMaxOverflowLogging_Compiled');
	
		% Determine if any block should be logged
		isMinMaxOver = strcmp(logs, 'MinMaxAndOverflow');
		isOverOnly   = strcmp(logs, 'OverflowOnly');
		blks         = blocks(isMinMaxOver | isOverOnly);
	end


function ancH = deepest_common_ancestor(blockList)
    if length(blockList)==1
        ancH = blockList;
        return;
    end
    
    
    ancVect = find_all_ancestors(blockList(1));
    
    for idx = 2:length(blockList)
        ancVect = update_ancestors(ancVect,blockList(idx));
    end
    
    ancH = ancVect(end);    


function ancVect = find_all_ancestors(blkH)
    modelH = bdroot(blkH);
    objH = blkH;
    ancVect = [];
    
    while(objH~=modelH)
        ancVect = [objH ancVect];
        objH = get_param(get_param(objH,'Parent'),'Handle');
    end
    
    ancVect = [modelH ancVect];


function ancVect = update_ancestors(ancVect, blkH)
    modelH = bdroot(blkH);
    objH = blkH;

    while(~any(ancVect==objH) && objH~=modelH)
        objH = get_param(get_param(objH,'Parent'),'Handle');
    end

    idx = find(ancVect==objH);
    if isempty(idx)
        error('SLVNV:simcoverage:cv_autoscale_settings:NoCommonAncestor','Objects do not have a common ancestor');
    end
    
    ancVect = ancVect(1:idx);

