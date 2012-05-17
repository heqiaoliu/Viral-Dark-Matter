function createSlsfHierarchy(modelH, hiddenSubSys)
try 
%   Copyright 1990-2008 The MathWorks, Inc.
    
    modelCovId = get_param(modelH, 'CoverageId');      
    activeRoot = cv('get', modelCovId, '.activeRoot');
    topSlHandle =  cv('get', activeRoot, '.topSlHandle'); 
    topSlsfId = cv('new','slsfobj', '.handle',  topSlHandle, ...
                                    '.name',        get_param(topSlHandle, 'name'),...
                                    '.origin',      1,... 
                                    '.modelcov',    modelCovId);
    
    check_triggered_model(hiddenSubSys, topSlsfId,  get_param(topSlHandle, 'name'));
    cv('set',activeRoot,'.topSlsf', topSlsfId)
    build_sl_hierarchy(topSlHandle, topSlsfId, modelCovId)
catch MEx
    rethrow(MEx);
end
%==============================================
function check_triggered_model(hiddenSubSys, topSlsfId, name)

    if hiddenSubSys == 0
        return;
    end
    % hiddenSubSys changes handle at each compile, have to refresh all of
    % them
    slsfobjs = cv('find', 'all','slsfobj.name', name);
    cv('set',slsfobjs , '.hiddenSubSysHandle', hiddenSubSys);
    
    set_param(hiddenSubSys, 'CoverageId', topSlsfId);

%==============================================
function build_sl_hierarchy(rootSysHndl, rootSlsfId, modelId)
% Generate the tree structure of the model and insert
% all block types that require instrumentation

    CoverageBlockTypes = cvi.TopModelCov.getSupportedBlockTypes;
    
    cv('Private', 'model_name_refresh');% Check for renamed models and update data dictionary
    %libaries not on the path give warning in BAT
    warning_state = warning('off'); %#ok<WNOFF>
    allBlocks = find_system(rootSysHndl,'FollowLinks', 'on', ...
                                'LookUnderMasks', 'all', ...
                                'DisableCoverage','off');
    warning(warning_state);
    
   for idx = 1:length(allBlocks)
        set_param(allBlocks(idx),'CoverageId', 0);                            
    end

    
    % Determine if assertion related blocks need coverage
    if (strcmp(cv('Feature','disable assert coverage'),'on'))
        skipAssert = 1;
    else
        skipAssert = 0;
    end

    if (nargin==1)
        modelName = get_param(bdroot(rootSysHndl),'Name');
        modelId = cv('find','all','modelcov.name',modelName);
        rootSlsfId = 0;
        if isempty(modelId), modelId = 0; end
    end
    

    if (rootSlsfId==0)
        rootSlsfId = create_new_slsfobjs(rootSysHndl,modelId);
    else
        % Make sure the root handle is installed in Simulink
        
        if bdroot(rootSysHndl)~=rootSysHndl
          set_param(rootSysHndl,'CoverageId',rootSlsfId);
        end
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Fix input arguments if needed
    if ischar(rootSysHndl)
        rootSysHndl = get_param(subSysHndl,'handle');
    end
    
    if modelId==0
        modelHandle = bdroot(rootSysHndl);
        modelName = get_param(modelHandle,'Name');
        modelId = cv('new','modelcov','.name',modelName,'.handle',modelHandle);
    end
    
    check_sf_debug(get_param(bdroot(rootSysHndl),'Name'));

	% Get all the subsystem blocks
    [subsys_blks, subsys_par] = find_subsystem_hierarchy(rootSysHndl);
    

	% Filter out the assert related blocks if needed
    if (skipAssert)
        assertRelated = strcmp(get_param(subsys_blks,'UsedByAssertionBlockOnly'),'on');
        subsys_blks(assertRelated) = [];
        subsys_par(assertRelated) = [];
    end
	

    [subsys_blks, subsys_par] = filter_custom_objectives(subsys_blks, subsys_par);

	% Create the shadow coverage objects for each subsystem
	subsys_cvIds = create_new_slsfobjs(subsys_blks,modelId);
	subsys_cvIds = [subsys_cvIds(:);rootSlsfId];
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Build the hierarchy of subsystems
	
	% Create a single index for each parent
	sysGroups = find( [-1 ; subsys_par] ~= [subsys_par ; -1]); 
	
	for i=1:(length(sysGroups)-1)
		children = subsys_cvIds( (sysGroups(i)):(sysGroups(i+1)-1) );
		parent = subsys_cvIds([subsys_blks;rootSysHndl]==subsys_par(sysGroups(i)));
        
        % The parent may be empty if coverage has been disabled
        if isempty(parent)
            cleanup_orphans(children);
        else
            cv('BlockAdoptChildren',parent,children); 
        end
	end             
		

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Add all leaf blocks
    leafBlocks = [];
    for type = CoverageBlockTypes,
        %libaries not on the path give warning in BAT
        warning_state = warning('off'); %#ok<WNOFF>
        newBlocks = find_system(rootSysHndl,'FollowLinks', 'on', ...
                                'LookUnderMasks', 'all','BlockType',type{1}, ...
                                'DisableCoverage','off');
        warning(warning_state);
        leafBlocks = [leafBlocks;newBlocks]; %#ok
    end
    
	% Arrange the leaf blocks contiguosly by parent
	leafBlocks_par = get_param(get_param(leafBlocks,'Parent'),'Handle');
	if iscell(leafBlocks_par)
		leafBlocks_par = cat(1,leafBlocks_par{:});		% convert to numeric vector
		[leafBlocks_par,sortI] = sort(leafBlocks_par);
		leafBlocks = leafBlocks(sortI);
	end
	
	% Filter out the assert related blocks if needed
    if (skipAssert)
        assertRelated = strcmp(get_param(leafBlocks,'UsedByAssertionBlockOnly'),'on');
        leafBlocks(assertRelated) = [];
        leafBlocks_par(assertRelated) = [];
    end
	
    
        
	leafBlocks_cvIds = create_new_slsfobjs(leafBlocks,modelId);
	
	leafSysGroups = find( [-1 ; leafBlocks_par] ~= [leafBlocks_par ; -1]); 
    
    %corner case; Lookup-nd might be the only block and it's disable
    %because of it's size
    if ~any(leafBlocks_cvIds == 0)
        for i=1:(length(leafSysGroups)-1)
            children = leafBlocks_cvIds( (leafSysGroups(i)):(leafSysGroups(i+1)-1) );
            parent = subsys_cvIds([subsys_blks;rootSysHndl]==leafBlocks_par(leafSysGroups(i)));

            % The parent may be empty if coverage has been disabled
            if isempty(parent)
                cleanup_orphans(children);
            else
                cv('BlockAdoptChildren',parent,children); 
            end
        end             
    end    
    add_custom_objectives(rootSysHndl, subsys_cvIds, modelId);
    
	% Find all the remaining blocks and create sigranger objects for recording the 
	% range of output values.
    warning_state = warning('off'); %#ok<WNOFF>

	leftOvers = find_system(rootSysHndl,'FollowLinks', 'on', ...
                                'LookUnderMasks', 'all','CoverageId',0, ...
                                'DisableCoverage','off');
    warning(warning_state);

    % Remove merge blocks because their output is virtualized and we don't
    % want 
    % to pollute the report with noise.
    blockTypes = get_param(leftOvers,'BlockType');
    isMerge = strcmp(blockTypes,'Merge');
    leftOvers(isMerge) = [];

    leftOver_par = get_param(get_param(leftOvers,'Parent'),'Handle');
    

    if iscell(leftOver_par)
        leftOver_par = cat(1,leftOver_par{:});		% convert to numeric vector
        [leftOver_par,sortI] = sort(leftOver_par);
        leftOvers = leftOvers(sortI);
    end
    
    [leftOvers, leftOver_par] = filter_custom_objectives(leftOvers, leftOver_par);
    
	leftOverSysGroups = find( [-1 ; leftOver_par] ~= [leftOver_par ; -1]); 
 
    leftOver_cvids = create_new_slsfobjs(leftOvers,modelId);
                                
    for i=1:(length(leftOverSysGroups)-1)
        children = leftOver_cvids( (leftOverSysGroups(i)):(leftOverSysGroups(i+1)-1) );
        parent = subsys_cvIds([subsys_blks;rootSysHndl]==leftOver_par(leftOverSysGroups(i)));

        children(children == 0) = []; 
        % The parent may be empty if coverage has been disabled
        if isempty(parent)
            cleanup_orphans(children);
        else
            cv('BlockAdoptChildren',parent,children); 
        end
    end             

    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [subsys_blks, subsys_par] = filter_custom_objectives(subsys_blks, subsys_par)
    delIdx = [];
    for idx = 1:numel(subsys_blks)
        blkh = subsys_blks(idx);
        parentH = get_param(blkh, 'parent');
        if cvi.TopModelCov.isDVBlock(blkh) || cvi.TopModelCov.isDVBlock(parentH) 
            delIdx = [delIdx idx]; %#ok<AGROW>
        end
    end
    subsys_blks(delIdx) = [];
    subsys_par(delIdx) = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function add_custom_objectives(rootSysHndl, subsys_cvIds, modelId)
    customBlks = [];
    warning_state = warning('off'); %#ok<WNOFF>
    dvBlockTypes = cvi.MetricRegistry.getDVSupportedMaskTypes;
    for idx = 1:numel(dvBlockTypes)
        customBlks  = [customBlks;   find_system(rootSysHndl,'FollowLinks', 'on', ...
                                'LookUnderMasks', 'all', ...
                                'MaskType', dvBlockTypes{idx}) ]; %#ok<AGROW>
    end
    warning(warning_state);
    if isempty(customBlks)
        return;
    end
    if ~isempty(subsys_cvIds)
        allHandles = cv('get', subsys_cvIds, '.handle');
    else
         allHandles = [];
    end
    if ~isempty(customBlks)
        for cs = customBlks(:)'
           parentH = get_param(get_param(cs,'Parent'), 'Handle');
           cvId = create_new_slsfobjs(cs, modelId);
           cv('set',cvId, '.isDisabled', ~strcmpi(get_param(cs,'enabled'),'on'));
           while true
            parentCvId = subsys_cvIds(allHandles == parentH);
            if ~isempty(parentCvId) 
                cv('BlockAdoptChildren',parentCvId, cvId); 
                break;
            end
            newSubSysCvId = create_new_slsfobjs(parentH, modelId);
   
            
            cv('BlockAdoptChildren',newSubSysCvId, cvId); 
            subsys_cvIds = [subsys_cvIds; newSubSysCvId]; %#ok<AGROW>
            allHandles = [allHandles; parentH]; %#ok<AGROW>
            cvId = newSubSysCvId;
            parentH = get_param(get_param(parentH,'Parent'), 'Handle');
           end
           assert(~isempty(cvId));
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CREATE_NEW_SLSFOBJS
%
% Create new slsf objects in cv and resolve basic entries

function newIds = create_new_slsfobjs(slHandles,modelId)

    newIds = zeros(size(slHandles));

    for i=1:length(slHandles),
        ch = slHandles(i);
        
        blktypeObjId = get_blktype_id(modelId, ch);
        name = get_param(ch,'Name');    
        newIds(i) = cv('new','slsfobj', '.handle',  ch, ...
                                    '.name',        name,...
                                    '.origin',      1, ...
                                    '.modelcov',    modelId, ...
                                    '.slBlckType', blktypeObjId);
        set_param(ch,'CoverageId',newIds(i));
    end
                                           
%==========================================   

function cleanup_orphans(cvIds)
    slHandles = cv('get',cvIds,'.handle');
    for blockH = slHandles(:)'
        set_param(blockH,'CoverageId',0);
    end
    cv('delete',cvIds);

%==========================================   

function [allNodes, allParents, childCnts] = find_subsystem_hierarchy(root)
    warning_state = warning('off'); %#ok<WNOFF>
	allNodes = find_system(root,'FollowLinks', 'on', ...
                                'SearchDepth', 1, ...
                                'LookUnderMasks', 'all', ...
                                'BlockType','SubSystem', ...
                                'DisableCoverage','off');
    warning(warning_state);                            
    
    allNodes(allNodes==root) = []; % Don't include the root
    
    if isempty(allNodes)
        allParents = [];
        childCnts = [];
        return;
    end
    
    childCnts = length(allNodes);
    allParents = root*ones(length(allNodes),1);
    
    for child = allNodes(:)'
        [newNodes, newParents, newCnts] = find_subsystem_hierarchy(child);
        allNodes = [allNodes ; newNodes]; %#ok
        allParents = [allParents ; newParents]; %#ok
        childCnts = [childCnts ; newCnts]; %#ok
    end
    
    
function check_sf_debug(modelName)
   [~, mexf] = inmem;
   sfIsHere = any(strcmp(mexf,'sf'));
   if sfIsHere        
    sfrt = sfroot;
    machine = sfrt.find('-isa','Stateflow.Machine','name',modelName);
    if ~isempty(machine)
        machineId = machine.Id;
        targets = sf('TargetsOf',machineId);
        sfunTarget = sf('find',targets,'target.name','sfun');
        if ~sf('Private', 'target_code_flags', 'get', sfunTarget,'debug')
          warning('slvnv:simcoverage:stateflow_no_debug', 'Debug option for Simulation Target/Code Generation is turned off. Coverage can not be recorded for any Stateflow charts or Embedded MATLAB blocks in this model.');                 
        end
    end      
   end    
%==========================================   
function objId = get_blktype_id(modelId, slHandle)


blktypeStr = get_param(slHandle,'BlockType');

isDV = cvi.TopModelCov.isDVBlock(slHandle);
if isDV
     blktypeStr = get_param(slHandle,'MaskType');
elseif strcmp(blktypeStr,'S-Function')
    blktypeStr = get_param(slHandle,'FunctionName');
end
objId = [];

blockTypeIds = cv('get', modelId, '.blockTypes');
if ~isempty(blockTypeIds)
    objId = cv('find', blockTypeIds, '.type', blktypeStr);
end

if isempty(objId) 
    if(isDV || isSupported(blktypeStr))
        objId = cv('new','typename', '.type', blktypeStr);
        blockTypeIds(end+1) = objId;
        cv('set', modelId, '.blockTypes', blockTypeIds);
    else
        objId = 0;
    end
end
    

assert(numel(objId) == 1);
%==========================================   

function res = isSupported(blktypeStr)

    blktypes  = cvi.TopModelCov.getSupportedBlockTypes;
    res = ~isempty(blktypeStr) && ~isempty(strmatch(blktypeStr, blktypes));


   