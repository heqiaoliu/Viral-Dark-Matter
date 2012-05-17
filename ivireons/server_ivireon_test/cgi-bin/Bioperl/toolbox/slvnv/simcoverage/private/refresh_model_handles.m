function status = refresh_model_handles(modelId,modelName)
%REFRESH_MODEL_HANDLES - Update the model handles when 
% loading data or after a model has been closed and reopened.
%
%   STATUS = REFRESH_MODEL_HANDLES(MODELID,MODELNAME) Find the
%   Simulink handles and Stateflow IDs within MODELNAME that 
%   correspond to the coverage objects contained within MODELID.
%   If successful, STATUS = 1, otherwise STATUS = 0.

%   Bill Aldrich
%   Copyright 1990-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.5.2.1 $  $Date: 2010/07/06 14:42:40 $

    machine_update_list('clear');
    status = 0;
    
    % Loop through each of the root objects
    allRoots = cv('RootsIn',modelId);

    for rootId = allRoots(:)'
        [topCvId,path] = cv('get',rootId,'root.topSlsf','root.path');
        if isempty(path)    
            [s,H] = update_susbsys_handles(modelName,topCvId);
            if s==0, return; end
        else
            [s,H] = update_susbsys_handles([modelName '/' path],topCvId);
            if s==0, return; end
        end
        cv('set',rootId,'root.topSlHandle',H);
    end
    status = 1;

function [status,topH] = update_susbsys_handles(fullPath,cvId)
    status = 0;
    
    % Get the handle for this subsystem and install it
    topH = path2handle(fullPath);
    if topH==0, 
        return; 
    end

    cv('set',cvId,'slsfobj.handle',topH);

    % Find the coverage IDs of children
    children = cv('ChildrenOf',cvId);

    % Determine which of these ID's are leaf nodes
    grandChildren = cv('get',children,'slsfobj.treeNode.child');
    leafNodes = children(grandChildren==0);
    childSystems = children(grandChildren>0);

    % Install the leaf node handles
    for childId = leafNodes(:)'
        name = sl_equiv_name(childId);
        childPath = [fullPath '/' name];
        h = path2handle(childPath);
        if h==0, 
            return; 
        end
        cv('set',childId,'slsfobj.handle',h);
    end

    % Recurse to Simulink children, or call chart update
    for childId = childSystems(:)'
        name = sl_equiv_name(childId);
        childPath = [fullPath '/' name];
        if cv('get',childId,'slsfobj.origin')==1
            s = update_susbsys_handles(childPath,childId);
            if s==0, 
                return; 
            end
        else
            s = update_sf_chart_handles(fullPath,childId);
            if s==0, 
                return; 
            end
        end
    end
    status = 1;


function status = update_sf_chart_handles(slFullPath,cvChartId)
    status = 0;

    h = path2handle(slFullPath);
    [instanceId, ~] = get_sf_block_instance_handle(h);
    modelH = bdroot(h);

    if isempty(instanceId) || instanceId==0,
        return;
    end

    sfChartId = sf('get',instanceId,'instance.chart');
    if isempty(sfChartId) || sfChartId==0,
        return;
    end
    
    machineId = sf('get',sfChartId,'chart.machine');
    if isempty(machineId) || machineId==0,
        return;
    end
    
    % Use the model handle of the base model
    if ~machine_update_list('check',modelH)
        if machine_needs_update(machineId)
            if strcmp(get_param(modelH,'SimulationStatus'),'stopped')
                set_param(modelH,'SimulationCommand','update');
                machine_update_list('add',modelH);
            end
        end
    end

    cv('set',cvChartId,'slsfobj.handle',sfChartId);
    if ~sf('Private', 'is_sf_chart',  sfChartId)
        kernelState = sf('AllSubstatesOf',sfChartId);
        kernelCvState = cv('ChildrenOf',cvChartId);
        cv('set',kernelCvState,'.handle', kernelState);
        status = 1;
    else
        status = refresh_substate_trans_ids(sfChartId,cvChartId);
    end


function out = machine_update_list(method,arg)
    
    persistent syncedList;
    
    switch(method)
    case 'check'
        if isempty(syncedList)
            out = 0;
        else
            out = any(syncedList==arg);
        end
        
    case 'add'
        syncedList = unique([syncedList; arg]);
        out = 1;
        
    case 'clear'
        syncedList = [];
        out = 1;
        
    otherwise
        error('SLVNV:simcoverage:refresh_model_handles:BadInput','Bad input');
    end
        


function status = refresh_substate_trans_ids(sfId,cvId)
    status = 0;

    sfSubstates = sf('AllSubstatesOf',sfId);
    sfSubstates = sf('find',sfSubstates,'~state.isNoteBox',1);	% Filter notes
%    if ~isempty(sfSubstates)
%        substateNums = sf('get',sfSubstates,'.number');
%        [sortNums,I] = sort(substateNums);
%        if any(sortNums(1:(end-1))==sortNums(2:end))
%            disp('Repeated state number!!!')
%            return
%        end
%        sfSubstates = sfSubstates(I);
%    end
    sfTrans = sf('TransitionsOf',sfId);
    transParents = sf('get',sfTrans,'.linkNode.parent');
    sfTrans(transParents~=sfId) = [];
    sfTrans = sf('find',sfTrans,'~transition.dst.id',0);	% Filter dangling transitions
    sfTrans = filter_virtual_trans(sfTrans);
    
    if ~isempty(sfTrans)
        transNums = sf('get',sfTrans,'.number');
        [sortNums,I] = sort(transNums);
        if any(sortNums(1:(end-1))==sortNums(2:end))
            disp('Repeated transition number!!!')
            return
        end
        sfTrans = sfTrans(I);
    end


    cvChildren = cv('ChildrenOf',cvId);
    if ~isempty(cvChildren)
        childSlinSF = cv('find',cvChildren,'slsfobj.origin', 1);
        if ~isempty(childSlinSF )
            childSlinSFPath = getfullname(sf('get', cv('get', cvId, '.handle'), '.simulink.blockHandle'));
            for idx = 1:numel(childSlinSF)
                update_susbsys_handles(childSlinSFPath, childSlinSF(idx));
            end
        end
        childIsa = cv('get',cvChildren,'slsfobj.refClass');
        cvSubstates = cvChildren(childIsa==sf('get','default','state.isa'));
        cvSubtrans = cvChildren(childIsa==sf('get','default','transition.isa'));
    else
        cvSubstates = [];
        cvSubtrans = [];
    end
    
    if length(sfSubstates)~=length(cvSubstates) || length(sfTrans)~=length(cvSubtrans)
        return;
    end

    if ~isempty(sfSubstates)
        % Make sure the names still match
        for i=1:length(sfSubstates)
            if (sf('get',sfSubstates(i),'.type')==3)
                if ~strcmp(sf('get',sfSubstates(i),'.labelString'),cv('get',cvSubstates(i),'.name'))
                    disp('Box name changed!!!')
                    return;
                end
            else
				if ~strcmp(sf('get',sfSubstates(i),'.name'),cv('get',cvSubstates(i),'.name'))
                    disp('State name changed!!!')
                    return;
				end
            end
            cv('set',cvSubstates(i),'slsfobj.handle',sfSubstates(i));
            %atomic subchart migth be under the state
            childCvId = cv('get',cvSubstates(i),'.treeNode.child');
            if cv('get', childCvId, '.refClass') == sf('get', 'default', 'chart.isa')
                slFullPath = getfullname(sf('get', sfSubstates(i), '.simulink.blockHandle'));
                update_sf_chart_handles(slFullPath,childCvId);
            end
        end
    end

    if ~isempty(sfTrans)
        % Make sure the labels are the same
        for i=1:length(sfTrans)
            if ~strcmp(sf('get',sfTrans(i),'.labelString'),cv('get',cvSubtrans(i),'.name'))
                disp('Trans name changed!!!')
                return;
            end
            cv('set',cvSubtrans(i),'slsfobj.handle',sfTrans(i));
        end
    end

    % Recurse for each child state
    for i=1:length(sfSubstates)
        s = refresh_substate_trans_ids(sfSubstates(i),cvSubstates(i));
        if s==0
            return;
        end
    end

    status = 1;

function h = path2handle(str)

    try
        h = get_param(str,'Handle');
    catch Mex %#ok<NASGU>
        h = 0;
    end

function name = sl_equiv_name(cvId)
        name = cv('get',cvId,'.name');
        name = strrep(name,'/','//');
        
% function sync_machine_sim_target(machineId)
%     sf('Private','compute_session_independent_debugger_numbers',machineId);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%    Functions copied from toolbox/stateflow/stateflow/slsf.m        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [instanceId, isLink] = get_sf_block_instance_handle(blockH)
%
%
%
if ~ishandle(blockH), 
   error_msg('Invalid block handle passed to slsf()');
   instanceId = 0;
	return;   
end;

	if is_an_sflink(blockH), 
	    isLink = 1;
		refBlock = get_param(blockH, 'ReferenceBlock');
		ind = find('/'==refBlock);
		instanceName = refBlock((ind(1)+1):end);

		% force library to be open, otherwise the refBlock
                % may not be valid!
		load_system(refBlock(1:(ind(1)-1)));
		
		%
		% Make sure the instance for the reference block has been loaded.
		%	
		ud = get_param(refBlock, 'userdata');	
		if isempty(ud) || ~isnumeric(ud) || ~sf('ishandle',ud) || isempty(sf('find', 'all', 'instance.name', instanceName)),
			modelName = get_root_name_from_block_path(refBlock);
			sf_load_model(modelName);
			%
			% If it's locked, it probably hasn't been loaded, unlock it
			% and lock it to insure that it has.
			%
			if strcmpi(get_param(modelName, 'lock'),'on')
				set_param(modelName, 'lock','off');
				set_param(modelName, 'lock','on');
			end;
		end;

		instanceId = get_param(refBlock, 'userdata'); 
    else 
		instanceId = get_param(blockH, 'userdata');
	    isLink = 0;
	end;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function isLink = is_an_sflink(blockH)
%
% Determine if a block is a link
%
if isempty(get_param(blockH, 'ReferenceBlock')),
   isLink = 0;
else
   isLink = 1;
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rootName = get_root_name_from_block_path(blkpath)
%
%
%
	ind = find(blkpath=='/', 'first');
	rootName = blkpath(1:(ind(1)-1));


% This function copied from 
% toolbox/stateflow/stateflow/private/sf_load_model.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sf_load_model(modelName)
%
% Silently loads a Simulink model given its name.
%
try
	eval([modelName,'([],[],[],''load'');']);
catch Mex %#ok<NASGU>
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Determine if a machine requires an update by checking if
% any object has a number >0.   
%
function out = machine_needs_update(machineId)
    out = true;

    charts = sf('get',machineId,'.charts');
    chartId = charts(1);
    
    data1 = sf('find','all','data.machine',machineId,'data.number',1);
    if ~isempty(data1)
        out = false;
        return;
    end
    
    event1 = sf('find','all','event.machine',machineId,'event.number',1);
    if ~isempty(event1)
        out = false;
        return;
    end
    
    trans1 = sf('find','all','trans.chart',chartId,'trans.number',1);
    if ~isempty(trans1)
        out = false;
        return;
    end

    state1 = sf('find','all','state.chart',chartId,'state.number',1);
    if ~isempty(state1)
        out = false;
        return;
    end
    
function transIds = filter_virtual_trans(ids)
    simtrans = sf('find',ids,'transition.type','SIMPLE');
    supertrans = sf('find',ids,'transition.type','SUPER');
    transIds = [simtrans,supertrans]';    

    
    
    
    





