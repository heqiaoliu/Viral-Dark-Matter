% Copyright 2006-2009 The MathWorks, Inc.
function [depModel,unresolvedModels,cancelled] = findDependencies(varargin)
% Finds dependencies for the given models
%
% varargin is a single model or a cell array of models, followed
% by a list of name/values pairs, all optional, where the
% following names are allowed:
%    LookUnderMasks: a boolean, true if the search should look under
%                    masks, false otherwise (default false)
%    HideFactoryLibraries:  a boolean, true if factory libraries
%                           should be searched, false otherwise 
%                           (default true)
%    HideLibraries:  a boolean, true if libraries should be shown
%                    false otherwise (default false)
%    FileDependencies:  a boolean, true if file dependencies are
%                       to shown, false otherwise (default true)
%    InstanceView:  a boolean, true if instance view should be used, 
%                   false otherwise (default false)
%    DepMode: a dependency graph model to fill in with the results
%
% This has two major modes of operation: instance mode and non-instance
% mode.  What is returned differs between the two modes.
%
% For non-instance mode, each node represents a block diagram or a library.
% An edge between two nodes represents a use by a block in the block 
% diagram or library corresponding to the source node to the block diagram
% or library corresponding to the destination node.  This is built by a
% simple search in one pass.
%
% For instance mode each node represents a block in a block diagram or
% library.  These blocks are all model reference blocks or library links.
% An edge represents the fact that block corresponding to the source node
% references a block diagram or library that contains the block
% corresponding to the destination node.
%
% For instance mode, this dependency graph is built in two phases.  In the
% first phase, each node corresponding to a model reference block or a
% library link has an edge (called a resolve edge) to a node representing
% the model or subsystem that the source node is referencing.  The
% destination node of a resolve edge has edges to node corresponding to
% blocks in it that make references.  In the second phase, the resolve
% edges are removed and the graph is turned into a tree.
%
% Consider a model "top" with model reference blocks "A" and "B" that
% both reference a model "mid".  Suppose "mid" has a model reference block 
% "C" that references a model "bottom". In the first phase, the following
% edges will be created:
%     top   -> top/A
%     top   -> top/B
%     top/A -> mid (resolve edge)
%     top/B -> mid (resolve edge)
%     mid   -> mid/C
%     mid/C -> bottom (resolve edge)
%
% In the second phase, this will be converted to the following:
%     top   -> mid (for block top/A)
%     top   -> mid (for block top/B)
%     mid (for block top/A) -> bottom (1)
%     mid (for block top/B) -> bottom (2)
% where there are two nodes labeled mid and two nodes
% labeled bottom

    %assigning return values
    depModel = DepViewer.Model;
    cancelled = false;
    unresolvedModels = {};

    if(size(varargin)==0)
        return;
    end
    
    iMdls = varargin{1};
    %if there is only one model, create a cell array
    if ~iscell(iMdls)
        iMdls = {iMdls};
    end

    %return if no model or the empty string is specified.
    if(isempty(iMdls) || eq(length(iMdls),1) && ischar(iMdls{1}) && strcmp(iMdls{1},''))
        return;
    end
                 
    waitbar  = loc_createWaitBar(0);     

    args = varargin(2:end);
    nargs = size(args,2);
    lookUnderMasks = false;
    hideSimulinkBlocksets = true;
    hideLibraries = false;
    fileDependencies = true;
    instanceView = false;

    if 2*floor(nargs/2) ~= nargs
        error('Simulink:DependencyViewer:ArgumentError', 'findDependencies: Expecting even number of optional arguments');
    end % if 
    
    for idx = 1:nargs/2
        arg = args{2*idx-1};

        if strcmpi(arg,'LookUnderMasks') == 1
            [argValue,err] = loc_parseBoolArg(arg, args{2*idx});
            if(err)
                continue; 
            end % if
            lookUnderMasks = argValue;
        end

        if strcmpi(arg,'HideFactoryLibraries') == 1
            [argValue,err] = loc_parseBoolArg(arg, args{2*idx});
            if(err)
                continue; 
            end % if
            hideSimulinkBlocksets = argValue;
        end
        
        if strcmpi(arg,'FileDependencies') == 1
            [argValue,err] = loc_parseBoolArg(arg, args{2*idx});
            if(err)
                continue; 
            end %if
            fileDependencies = argValue;
        end
        
        if strcmpi(arg,'HideLibraries') == 1
            [argValue,err] = loc_parseBoolArg(arg, args{2*idx});
            if(err)
                continue; 
            end %if
            hideLibraries = argValue;
        end
        
        if strcmpi(arg, 'InstanceView') == 1
            [argValue, err] = loc_parseBoolArg(arg, args{2*idx});
            if(err)
                continue; 
            end % if
            instanceView = argValue;
        end
        
        if strcmpi(arg,'DepModel') == 1
            depModel = args{2*idx};
            continue;
        end
    end % for

    if(eq(depModel,0))
        depModel = DepViewer.Model;
    end % if
    
    try
        cancelled = waitbar.wasCanceled();
        if(cancelled)
            return;
        end % if
        
        if(instanceView)
            myMdl = DepViewer.Model;
        else
            myMdl = depModel;
        end % if
        
        [cancelled, roots, unresolvedModels] =...
            loc_findDependencies(myMdl,...
                                 iMdls,...
                                 instanceView,...
                                 hideLibraries,...
                                 fileDependencies,...
                                 lookUnderMasks,...
                                 hideSimulinkBlocksets,...
                                 waitbar);
            
        if(instanceView && (~ cancelled))
            waitbar.setLabelText(sprintf('Creating Instance View'));
            postProcessInstanceView(roots, myMdl, depModel, hideLibraries);
        end % if
    catch myException
        %clearing partial or invalid model state
        depModel = DepViewer.Model; %#ok - mlint
        %uncomment this if we decide to close models that were opened
        %during the search
        %loc_closeModels(processedNodes, iMdls);
        rethrow(myException);
    end
end % findDependencies

%% =======================================================================
function [value,err] = loc_parseBoolArg(argName, argValue)
    value = argValue;
    err=false;
    if(strcmp(argValue, 'on')), value=true; return; end
    if(strcmp(argValue, 'off')), value=false; return; end
    if(argValue==1), value=true; return; end
    if(argValue==0), value=false; return; end
    if(argValue==true), value=true; return; end
    if(argValue==false), value=false; return; end
    msgId = [loc_errmsg,'ParseError'];
    msg   = loc_inputWarning(argName, 'boolean');
    warning(msgId, msg); 
    err=true;
end % loc_parseBoolArg


%% =======================================================================
function [cancelled, roots, unresolvedModels] =...
 loc_findDependencies(depModel, models, instanceView, hideLibraries,...
                      fileDependencies, lookUnderMasks, hideSimulinkBlocksets,...
                      waitbar)
    % Initialize return values
    cancelled = false; %#ok
    roots = []; %#ok - mlint
    unresolvedModels = {}; %#ok - mlint
                  
    function [key] = loc_obj2Key(obj)
        if(ishandle(obj))
            str = ['h', num2str(obj)];
        else
            assert(ischar(obj));
            str = obj;
        end % if
        
        key = strrep(str, '.', '_');
    end % loc_obj2Key
        
    function [worklist, roots, unresolvedModels] = loc_newWorklist(models)
        [handles, unresolvedModels] = loc_getRootModelHandles(models);
        worklist = [];
        worklist.nodes    = struct();
        worklist.worklist = num2cell(handles);
            
        roots = [];
        
        for j = 1:length(handles)
            handle = handles(j);
            depNode = loc_createDepNode(handle, depModel, instanceView, hideLibraries, fileDependencies);
            hidden = false;

            toAdd = struct('node', depNode, 'handle', handle, 'hidden', hidden);
            key = loc_obj2Key(handle);
            
            worklist.nodes.(key) = toAdd;
            
            roots = [roots; depNode]; %#ok - mlint
        end % for
    end % loc_newWorklist

    function isEmpty = loc_worklistIsEmpty(worklist)
        isEmpty = isempty(worklist.worklist);
    end % loc_worklistIsEmpty

    function contains = loc_worklistContains(worklist, obj)
        key = loc_obj2Key(obj);
        contains = isfield(worklist.nodes, key);
    end % loc_worklistContains

    function [depnode, hidden] = loc_worklistGetMatching(worklist, obj)
        if(loc_worklistContains(worklist, obj))
            key = loc_obj2Key(obj);
            toReturn = worklist.nodes.(key);
            
            depnode = toReturn.node;
            hidden  = toReturn.hidden;
        else
            depnode = [];
            hidden  = false;
        end % if
 
    end % loc_worklistGetMatching

    function [worklist, obj, depnode] = loc_worklistPop(worklist)
        obj = worklist.worklist{end};
        key = loc_obj2Key(obj);
        
        worklist.worklist = {worklist.worklist{1:(end - 1)}};
        toReturn = worklist.nodes.(key);
        
        depnode = toReturn.node;
    end % loc_worklistPop

    function worklist = loc_worklistPush(worklist, handle, depnode, hidden)
        toAdd = struct('node', depnode, 'handle', handle, 'hidden', hidden);
        key = loc_obj2Key(handle);
            
        worklist.nodes.(key)       = toAdd;
        worklist.worklist{end + 1} = handle;
    end % loc_worklistPush

 
    % Create the worklist, starting with the given set of models
    [worklist, roots, unresolvedModels] = loc_newWorklist(models);        
    
    % Process while the worklist is not empty
    while(~ loc_worklistIsEmpty(worklist))
        % Get an item off the worlist
        [worklist, obj, depNode] = loc_worklistPop(worklist);
        
        % See if we should stop
        cancelled = waitbar.wasCanceled;
        if(cancelled)
            return;
        end % if
        
        % Update the wait bar
        loc_updateWaitBar(waitbar, obj);
        
        % Get the successors for the item being processed
        [successors, resolveLink, unresolved, cancelled] =...
            loc_getSuccessors(obj, instanceView, fileDependencies, lookUnderMasks, hideSimulinkBlocksets, hideLibraries, waitbar);
        unresolvedModels = [unresolvedModels,  unresolved]; %#ok - mlint
        if(cancelled)
            return;
        end % if
        
        for i = 1:length(successors)
            successor = successors{i};
            assert(ischar(successor) || ishandle(successor));
            
            % See if we should stop
            cancelled = waitbar.wasCanceled;
            if(cancelled)
                return;
            end % if            

            % Try to get an already created dependency node for the
            % successor.  Otherwise, create one.
            if(loc_worklistContains(worklist, successor))
                [succDepNode, hidden] = loc_worklistGetMatching(worklist, successor);
            else
                succDepNode = loc_createDepNode(successor, depModel, instanceView, hideLibraries, fileDependencies);
                
                if(succDepNode == 0) % xxx - hack b/c visible doesn't work
                    succDepNode = depNode; 
                    hidden = true;
                else
                    hidden = false;
                end % if
                
                worklist = loc_worklistPush(worklist, successor, succDepNode, hidden);
            end % if

            % Connect the two nodes together
            if(~hidden) % xxx - hack b/c visible doesn't work
                loc_createDependency(depNode, succDepNode, resolveLink, depModel);
            end % if
        end % for
    end % while
    
    cancelled = waitbar.wasCanceled;

end % loc_findDependencies



%% ======================================================================
% For the given handle, find its successors.  Return the successors as a
% set of handles.
% 
% instanceView   - is instance view being used
% hideLibraries  - are libraries being hidden
% lookUnderMasks - should the search look under masks 
function [successors, resolveLink, unresolvedModels, cancelled] =...
         loc_getSuccessors(handle, instanceView, fileDependencies, lookUnderMasks, hideSimulinkBlockSets, hideLibraries, waitbar)
    resolveLink = false;
    successors = {};
    unresolvedModels = {};
    cancelled = false;

    % Don't need to examine MDLP files
    if(ischar(handle))
        assert(loc_isMDLP(handle));
        return;
    end % if
        
    assert(ishandle(handle));

    % Convert look under masks to a find_system argument
    if(lookUnderMasks)
        lookUnderMasksValue = 'all';
    else
        lookUnderMasksValue = 'none';
    end % if
    

    % For instance view, we are building a graph with extra nodes to avoid
    % searching models more than once.  To do this, we will create a
    % depNode for every model reference block AND every referenced model
    % (similarly, blocks with library links and subsystems in libraries).
    % If are in instance mode AND have a model reference block or a block
    % with a library link, the only successor to this node should be the
    % corresponding top model or subsystem in a library.  
    if(instanceView)
        if(loc_isTopModel(handle))
            % We have a top model, nothing to resolve.
            resolvedHandle = handle;
        else
            % We are in instance view but have not been given a root
            % model.  Resolve what we should be searched
            if(strcmp(get_param(handle, 'BlockType'), 'ModelReference'))
                % Get the referenced model
                resolvedName = loc_getDisplayNames(handle);
            else
                % This is a library block
                libinf = libinfo(handle, 'SearchDepth', 0, 'FollowLinks', 'off', 'LookUnderMasks', lookUnderMasksValue);
                assert(length(libinf) <= 1);
                
                if(isempty(libinf))
                    % Not a library block with a link, no resolution
                    % necessary
                    resolvedName = loc_getBlockPath(handle);
                else
                    libstatus = libinf.LinkStatus;
                    if(strcmp('resolved', libstatus))
                        % A library block with a link, need to resolve
                        resolvedName = libinf(1).ReferenceBlock;
                    elseif(strcmp('unresolved', libstatus))
                        unresolvedModels = {libinf.ReferenceBlock};
                        return;
                    else
                        assert(strcmp('inactive', libstatus));
                        resolvedName = loc_getBlockPath(handle);
                    end % if
                end  %if
            end % if
            
            resolvedHandle = loc_getHandles(resolvedName);
            assert(iscell(resolvedHandle));
            resolvedHandle = resolvedHandle{1};
                        
            assert((ischar(resolvedHandle)) ||...
                   (resolvedHandle ~= 0));

            % If the resolved handle is different, then something was
            % resolved.  Return it as the only successor.
            if(~isequal(handle, resolvedHandle))
                successors = {resolvedHandle};
                resolveLink = true;
                return;
            end % if
        end % if
    else
        % Not in instance mode, nothing to resolve.
        resolvedHandle = handle;
    end % if

    % Use find_system and libinfo to get the successors.  Convert the
    % handle to a name for find_system since we might call get param
    % on the results.  The output format of get_param is more predictible
    % if cell arrays of strings are given to it.
    if((~ fileDependencies) && hideLibraries)
        cancelled = waitbar.wasCanceled;
        if(cancelled)
            return;
        end % if

        mdlRefSuccessors = find_system(loc_getBlockPath(resolvedHandle), 'FollowLinks', 'on', 'LookUnderMasks', lookUnderMasksValue, 'BlockType', 'ModelReference');

        cancelled = waitbar.wasCanceled;
        if(cancelled)
            return;
        end % if

        % Special case:  We want to find unresolved libraries, but don't
        % want to start any searches from them.  Use libinfo to find
        % unresolved libraries, but then don't pass on any libSuccessors.
        libSuccessors = libinfo(resolvedHandle, 'FollowLinks', 'on', 'LookUnderMasks', lookUnderMasksValue);
        libstatus = {libSuccessors.LinkStatus};
        unresolvedLib = libSuccessors(strcmp('unresolved', libstatus));
        unresolvedModels = {unresolvedLib.ReferenceBlock};

        cancelled = waitbar.wasCanceled;
        if(cancelled)
            return;
        end % if
        
        libSuccessors = struct('Block', {}, 'Library', {}, 'ReferenceBlock', {}, 'LinkStatus', {}); 
    else
        cancelled = waitbar.wasCanceled;
        if(cancelled)
            return;
        end % if

        mdlRefSuccessors = find_system(loc_getBlockPath(resolvedHandle), 'FollowLinks', 'off', 'LookUnderMasks', lookUnderMasksValue, 'BlockType', 'ModelReference');

        cancelled = waitbar.wasCanceled;
        if(cancelled)
            return;
        end % if

        libSuccessors = libinfo(resolvedHandle, 'FollowLinks', 'off', 'LookUnderMasks', lookUnderMasksValue);

        cancelled = waitbar.wasCanceled;
        if(cancelled)
            return;
        end % if
    end % if
        
    % Get the list of unresolved models and the names of the models
    % that are referenced by mdlRefSuccessors and libSuccessors
    modelRefs = loc_getDisplayNames(mdlRefSuccessors);

    % Process the libraries
    libstatus = {libSuccessors.LinkStatus};
    resolved   = libSuccessors(strcmp('resolved',   libstatus));
    unresolved = libSuccessors(strcmp('unresolved', libstatus));
        
    unresolvedModels = [unresolvedModels, unresolved.ReferenceBlock];
    resolvedLibs   = {resolved.Library}';
   
    % NOTE! model refs first, libraries second
    referencedModels = [modelRefs; resolvedLibs];
    referencedModelPaths = [mdlRefSuccessors ; {resolved.ReferenceBlock}'];
    
    % See which of the referenced models can be loaded
    handles = loc_getHandles(referencedModels);
    unresolvedModels = [unresolvedModels, referencedModels(cellfun(@(x) isequal(x, 0), handles))];
    
    % Compute the successors
    if(instanceView)
        % We are in instance view, so:
        %  1) all of the mdlRefSuccessors are successors
        %  2) the library successors are the resolved blocks
        
        % NOTE!  model refs first, libraries second to match above
        successors = [mdlRefSuccessors; {resolved.Block}'];
    else
        successors = referencedModels;
    end % if

    % Determine what models to skip
    isLib = [zeros(length(modelRefs), 1); ones(length(resolvedLibs), 1)];

    % Remove unresolved models all arrays
    unresolved = cellfun(@(x) isequal(x, 0), handles);
    isLib(unresolved) = [];
    successors(unresolved) = [];
    referencedModels(unresolved) = [];
    referencedModelPaths(unresolved) = [];
    
    if(~isempty(referencedModels))
        skip = loc_ModelsToSkip(referencedModels, referencedModelPaths, isLib, hideSimulinkBlockSets, lookUnderMasks, fileDependencies);
        successors(skip) = [];
    end % if
    
    % Convert to handles.  Successors will be a set (i.e., each handle
    % will appear at most once).
    handles = loc_getHandles(successors); 
    unresolvedModels = unique([unresolvedModels{:}, successors(cellfun(@(x) isequal(x, 0), handles))]);

    % Make sure the default model reference name is not treated
    % as an unresolved model
    unresolvedModels = setdiff(unresolvedModels, slInternal('getModelRefDefaultModelName'));
    
    handles(cellfun(@(x) isequal(x, 0), handles)) = [];
    successors = handles;
end % loc_getSuccessors


%% ======================================================================
% Return a logical array of models to skip
function skip = loc_ModelsToSkip(models, paths, isLib, hideSimulinkBlockSets, lookUnderMasks, fileDependencies)
    skip = zeros(size(models));

    % Remove all successors whose name is 'simulink'
    skip = skip | strcmp('simulink', models);

    % Skip masks, if requested
    if(~ lookUnderMasks)
        skip = skip | strcmp(get_param(paths, 'Mask'), 'on');
    end % if
    
    % Skip masked model reference blocks that are top level subsystems in
    % libraries only when the model referred to by the model reference
    % block in the library is the same as the one in the model being 
    % searched.  See geck 343178
    if(fileDependencies)
        toCheck = (~isLib) & strcmp(get_param(paths, 'LinkStatus'), 'resolved');
        for i = find(toCheck == 1)
            if(strcmp(get_param(get_param(paths(i), 'ReferenceBlock'), 'ModelName'), ...
                      get_param(paths(i), 'ModelName')))
                skip(i) = true;
            end % if
        end % for
    end % if
    
    if(hideSimulinkBlockSets && ~isempty(models))
        % To skip factory libraries, we simply intersect their paths with
        % matlabroot/toolbox.  Is this too much?
        fullPaths   = cellfun(@which, models, 'UniformOutput', false);
        factoryPath = [matlabroot, filesep, 'toolbox'];
        skip = skip | (isLib & ~cellfun(@isempty, strfind(fullPaths, factoryPath)));
    end % if
    
end % loc_ModelsToSkip


%% =======================================================================
% Create a dependency node for the given handle.  This will create a
% library dep node or a model dep node as appropriate.
%
% depModel     - the dep model
% instanceView - is instance view being used
function depNode = loc_createDepNode(curNodeHndl, depModel, instanceView, hideLibraries, fileDependencies)
    if(loc_isTopModel(curNodeHndl))
        % This is a top level block diagram
        if(ischar(curNodeHndl))
            assert(loc_isMDLP(curNodeHndl));
            depNode = loc_createModelDepNode(curNodeHndl, depModel, instanceView);
        else
            bdtype = get_param(curNodeHndl, 'BlockDiagramType');
            assert(strcmp(bdtype, 'library') || strcmp(bdtype, 'model'));
            if(strcmp(bdtype, 'library'))
               depNode = loc_createLibraryDepNode(curNodeHndl, depModel, instanceView, hideLibraries, fileDependencies);
            else
               depNode = loc_createModelDepNode(curNodeHndl, depModel, instanceView);
            end % if 
        end % if
    else
        % This is a block
        if(strcmp(get_param(curNodeHndl, 'BlockType'), 'ModelReference'))
            % this is a model reference block
            depNode = loc_createModelDepNode(curNodeHndl, depModel, instanceView);
        else
            depNode = loc_createLibraryDepNode(curNodeHndl, depModel, instanceView, hideLibraries, fileDependencies);
        end % if
    end % if
end % loc_createDepNode


%% =======================================================================
function depNode = loc_createModelDepNode(curNodeHndl, depModel, instanceView)
    depNode = depModel.createModelReferenceDepNode();
    depNode.position = [0, 0];
    depNode.size = [50, 20];
    depNode.expanded = true;
   
    name = loc_getBlockName(curNodeHndl);
    path = loc_getBlockPath(curNodeHndl);
    
    if(loc_isTopModel(curNodeHndl))
        isMdlRefBlock = false;
    else
        isMdlRefBlock = strcmp(get_param(curNodeHndl, 'BlockType'), 'ModelReference');
    end % if
        
    if (instanceView)
        if(isMdlRefBlock)
            % This is a model reference block
            refModel = loc_getDisplayNames(curNodeHndl);
            refModel = refModel{1};
            
            depNode.shortname    = refModel;
            depNode.longname     = path;
            depNode.pathToHilite = path;
            depNode.pathToOpen   = refModel;
            depNode.pathOnDisk   = which(refModel);
            
            if slfeature('ModelReferenceNormalMode')
                depNode.configuredSimMode = get_param(curNodeHndl, 'SimulationMode');
            else
                depNode.configuredSimMode = 'Accelerator';
            end % if
        else
            % This is not a model reference block,
            % so it should be a top model
            assert(loc_isTopModel(curNodeHndl));
        
            depNode.shortname    = name;
            depNode.longname     = name;
            depNode.pathToOpen   = name;
            depNode.pathToHilite = '';
            depNode.pathOnDisk   = which(name);
            depNode.configuredSimMode = 'Normal';
            
            % For now, the top model's mode will node change
            % based on its SimulationMode parameter. 
            % mode = get_param(name, 'SimulationMode');
        end % if
    else
        depNode.shortname    = name;
        depNode.longname     = name;
        depNode.pathToOpen   = name;
        depNode.pathToHilite = '';
        depNode.pathOnDisk   = which(name);
    end % if
        
    assert(~ isempty(depNode.shortname));
    assert(~ isempty(depNode.longname));
    assert(~ isempty(depNode.pathToOpen));
    assert(~ isempty(depNode.pathOnDisk));
    assert(~ (instanceView && isempty(depNode.configuredSimMode)));
end % loc_createModelDepNode



%% ======================================================================%
function depNode = loc_createLibraryDepNode(curNodeHndl, depModel, instanceView, fileDependencies, hideLibraries)
    if(fileDependencies && hideLibraries)
        depNode = 0; % xxx - hack b/c visible doesn't work
        return;
    end % if

    depNode = depModel.createLibraryDepNode();
    
    depNode.position = [0, 0];
    depNode.size = [50, 20];
    depNode.expanded = true;
    depNode.isVisible = ~hideLibraries;
    
    name = loc_getBlockName(curNodeHndl);
    path = loc_getBlockPath(curNodeHndl);

    if (instanceView)
        if(loc_isTopModel(curNodeHndl))
            % This is the top model
            depNode.shortname    = name;
            depNode.longname     = name;
            depNode.pathtoOpen   = name;
            depNode.pathToHilite = '';
            depNode.pathOnDisk   = which(name);
        else
            depNode.shortname    = name;
            depNode.longname     = path;
            depNode.pathToHilite = path;
            depNode.pathToOpen   = path;
            
            root = loc_getRootModel(path);
            if(strcmp(get_param(root, 'BlockDiagramType'), 'library') == 1)
                depNode.pathOnDisk = which(root);
            else
                lib = get_param(path, 'ReferenceBlock');
                assert(~ isempty(lib));
                libroot = loc_getRootModel(lib);
                depNode.pathOnDisk = which(libroot);
            end % if
        end % if
    else
        depNode.shortname    = name;
        depNode.longname     = name;
        depNode.pathToOpen   = name;
        depNode.pathToHilite = '';
        depNode.pathOnDisk   = which(name);
    end % if(instanceView)

    assert(~ isempty(depNode.shortname));
    assert(~ isempty(depNode.longname));
    assert(~ isempty(depNode.pathToOpen));
    assert(~ isempty(depNode.pathOnDisk));
end % loc_createLibraryDepNode

%% =======================================================================%
function [] = loc_createDependency(sourceDepNode, destDepNode, resolveLink, depModel)
    if(eq(sourceDepNode, 0) || eq(destDepNode, 0))
        return;
    end % if  

    % Check if the edge exists - xxx hack b/c visible doesn't work
    %
    % The isDirectlyConnectTo check is not necessary, since the ismember
    % test will return true only if the isDirectlyConnectedTo check
    % returns true.  But, the isDirectlyConnectTo check is faster than
    % the ismember check.  So, use isDirectlyConnectTo to try to avoid
    % a slower (but necessary) check.
    if(sourceDepNode.isDirectlyConnectedTo(destDepNode))
        if(ismember(destDepNode, sourceDepNode.getOutNodes()))
            return;
        end % if
    end % if
    
    dep = depModel.createDependency();
    dep.resolveLink = resolveLink;
    
    dep.connect(sourceDepNode, destDepNode);
    
    if(resolveLink)
        % To preserve as much information as possible, the destination
        % of all resolveLinks should be normal mode
        destDepNode.configuredSimMode = 'Normal';
    else
        className = class(destDepNode);
        assert(strcmp(className, 'DepViewer.LibraryDepNode') ||...
               strcmp(className, 'DepViewer.ModelReferenceDepNode'));
        
        if(strcmp(className, 'DepViewer.LibraryDepNode'))
            % Library nodes inherit from their parents
            destDepNode.configuredSimMode = sourceDepNode.configuredSimMode;
        end % if
        
        % Don't need to do anything to model reference nodes
    end % if
end



%% ======================================================================
function topModel = loc_isTopModel(obj)
    if(ischar(obj))
        topModel = loc_isMDLP(obj);
    else
        topModel = strcmp(get_param(obj, 'Type'), 'block_diagram');
    end % if
end % loc_isTopModel


%% ======================================================================
function name = loc_getBlockPath(obj)
    if(ishandle(obj))
        object = get_param(obj, 'Object');
        name = object.getFullName;
        name = strrep(name, sprintf('\n'), ' ');
    else
        assert(ischar(obj));
        name = obj;
    end % if
end % loc_getBlockPath

%% ======================================================================
function name = loc_getBlockName(obj)
    if(ishandle(obj))
        name = get_param(obj, 'Name');
        name = strrep(name, sprintf('\n'), ' ');
    else
        assert(ischar(obj));
        name = obj;
    end % if
end % loc_getBlockPath

%% ======================================================================
function root = loc_getRootModel(path)
    assert(ischar(path));
    indexes = strfind(path, '/');
    if(isempty(indexes))
        root = path;
    else
        root = path(1:(indexes(1) - 1));
    end % if
end % 

%% =======================================================================
% Models is a cell array or a scalar
% 
% Returns a cell array of model handles
function handles = loc_getHandles(models)
    function handle = loc_getHandleForModel(obj)
        try
            if(ischar(obj))
                if(size(obj, 1) == 1)
                    if(loc_isMDLP(obj))
                        if(isempty(which(obj)))
                            handle = 0;
                        else
                            handle = obj;
                        end % if
                    else
                        root = loc_getRootModel(obj);
                        load_system(root);
                        handle = get_param(obj, 'Handle');
                    end % if
                else
                    handle = 0;
                end %if
            elseif((~ isnumeric(obj)) && ishandle(obj))
                % udd handle
                handle = obj.handle;
            elseif(isnumeric(obj))
                if(size(obj) == 1)
                    if(ishandle(obj))
                        handle = obj;
                    else 
                        handle = 0;
                    end % if
                else
                    handle = 0;
                end % if
            else
                handle = 0;
            end % if
        catch myException %#ok - mlint
            handle = 0;
        end
    end % loc_getRootForModel

    if(~ iscell(models))
        models = {models};
    end % if

    handles = cellfun(@loc_getHandleForModel, models, 'UniformOutput', false);
end % loc_getHandles


%% =======================================================================
% Models is a cell array or a scalar
% 
% Returns a cell array of handles for the root of every model passed in
function [handles, unresolvedModels] = loc_getRootModelHandles(models)
    handles = cell2mat(loc_getHandles(models));
    
    unresolvedModels1 = models(handles == 0);
    handles(handles == 0) = [];
    
    paths = cellfun(@loc_getBlockPath, num2cell(handles), 'UniformOutput', false);
    roots = cellfun(@loc_getRootModel, paths, 'UniformOutput', false);
    
    handles = cell2mat(loc_getHandles(roots));

    unresolvedModels = [unresolvedModels1, handles(handles == 0)];
    handles(handles == 0) = [];
    handles = unique(handles);
end % loc_getRootModelNames


%% =======================================================================
function dnames = loc_getDisplayNames(objs)
    function name = loc_resolveName(obj)
        assert(strcmp(get_param(obj, 'BlockType'), 'ModelReference'));
        if(strcmp(get_param(obj, 'ProtectedModel'), 'on'))
            name = get_param(obj, 'ModelFile');
        else
            name = get_param(obj, 'ModelName');
        end % if
    end % loc_resolveName

    if(~ iscell(objs))
        objs = {objs};
    end % if
    
    dnames = cellfun(@loc_resolveName, objs, 'UniformOutput', false);
end % loc_getDisplayName

%%
% Create a new waitbar
function waitbar = loc_createWaitBar(minDur)
    waitbar = DAStudio.WaitBar;
    waitbar.setMinimum(0);
    waitbar.setMaximum(0);
    waitbar.setMinimumDuration(minDur);
    waitbar.setWindowTitle(sprintf('Finding dependencies...'));
    waitbar.show;
end % loc_createwaitbar

%%
% Update the waitbar text
function loc_updateWaitBar(waitbar, handle)
    waitbar.setLabelText(sprintf('Searching %s', loc_getBlockPath(handle))); 
end % loc_updatewaitbar



%%
% Generate an unable to parse input warning
function msg = loc_inputWarning(name, type)
    msg = sprintf('findDependencies: Unable to parse the ''%s'' parameter. Please ensure it is a %s.', name, type);
end

%% 
% Generate an error message ID
function msgIdPref = loc_errmsg()
   msgIdPref = 'Simulink:DependencyViewer:';
end %loc_errmsg 


%% 
% Determine if the each model in the list of models given in ends with MDLP
function is_mdlp = loc_isMDLP(names)
    function isMDLP = loc_endsWithMDL(name)
        [~, ~, ext] = fileparts(name);
        isMDLP      = strcmpi(ext, '.mdlp');
    end % loc_endsWithMDL

    if(~ iscell(names))
        names = {names};
    end % if
    
    is_mdlp = cellfun(@loc_endsWithMDL, names, 'UniformOutput', true);
end %loc_errmsg 
