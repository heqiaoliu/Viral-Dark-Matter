function rmiobjnavigate(modelPath, varargin)
% Expects varargin like this:
% 'GID12345', 'GID23455', 2, 'GID455668', '!other.mdl', 'GID_987766', ...
% 
% where an integer value corresponds to the signal group number in
% sigBuilder pointed by the previous GID string, and a new model name in
% the middle of varargin redirects all GIDs that follow.

% Copyright 2005-2010 The MathWorks, Inc.

    % Strip the no-unhighlight indicator
    if modelPath(1) == '!'
        modelPath = modelPath(2:end);
        clear_actions = false;
    else
        clear_actions = true;
    end

    [mPath,modelName] = fileparts(modelPath);

    % Make sure the model is open
    try
        modelH = get_param(modelName,'Handle');
        open_system(modelH);
    catch Mex %#ok<NASGU>,
        try
            open_system(modelPath);
            modelH = get_param(modelName,'Handle');
        catch Mex %#ok<NASGU>,
            inform(['Could not locate model "' modelPath '"'],'Unresolved requirement item',1);
            return
        end
    end

    % Warn if there is model path mismatch
    if ~isempty(mPath)
        actPath = get_param(modelH,'FileName');
        pathMathches = false;
        if ~isempty(actPath)
            [aPath] = fileparts(actPath);
            pathMathches = strcmp(mPath,aPath);
        else
            aPath = '';
        end
        if ~pathMathches
            inform(['Model path "' aPath '" does not match link path "' mPath '" '],'Requirement path inconsistency',2);
        end
    end

    % Remove all RMI highlighting so that the targeted object(s) can be
    % selectively highlighted
    if strcmp(get_param(modelH, 'ReqHilite'), 'on')
        set_param(modelH,'ReqHilite','off');
    elseif clear_actions
        vnvprivate('action_highlight', 'clear');
    end
    
    % Parse the rest of the argument and locate all listed objects
    argCount = length(varargin);
    i = 1;
    while i <= argCount
        thisArg = varargin{i};
        
        if thisArg(1) == '!' % this is another model - start all over from this point
            rmiobjnavigate(thisArg, varargin{i+1:end}); 
            break;
        else                 % this is object ID
            % look one step ahead in case of signalBuilder group index
            if i == argCount
                locate_object_in_model(modelH, thisArg, 0);
                break;
            else
                nextArg = varargin{i+1};
                if strcmp(class(nextArg), 'double')
                    locate_object_in_model(modelH, thisArg, nextArg);
                    i = i+2;
                else
                    locate_object_in_model(modelH, thisArg, 0);
                    i = i+1;
                end
            end
        end
    end
end
    

function locate_object_in_model(modelH, objId, grpIdx)
    if strncmp(objId, 'GID', 3)
        locate_object_by_gid(modelH, objId, grpIdx);
    else
        inform(['Object ID "' objId '" is not supported.'],'Unsupported object ID',2);
    end
end
    
function locate_object_by_gid(modelH, objGuid, grpIdx)    

    modelName = get_param(modelH,'Name');

    % Lookup the requirements object
    obj = rmisl.guidlookup(modelH,objGuid);
    if isempty(obj)
        inform(['Could not locate id "' objGuid '" in the model "'  modelName '"'],'Unresolved requirement item',1);
        return
    end
    [isSf, objH] = rmi.resolveobj(obj);
    if isempty(objH)
        inform(['Could not resolve object "' objGuid '" in the model "' modelName '"'],'Navigation failed',1);
        return
    end

    if strcmp(get_param(modelH,'LibraryType'),'BlockLibrary')
        modelName = ['Library:' modelName];
    end

    if ~isSf
        if objH == modelH % if this object is a block diagram itself
            if ispc()
                show_window([modelName '$']);
            end
        else
            parent = get_param(objH, 'Parent');
            if ~isempty(parent)
                open_system(parent, 'force');
                vnvprivate('action_highlight', 'reqHere', objH);
                
                if ispc()
                    % Note: there is similar code in rmi.m:navigate2sl() to
                    % bring the window in focus. Any changes here will
                    % probably need to be duplicated there.
                    parentH = get_param(parent,'Handle');
                    parentName = cr2space(get_param(parentH,'Name'));
                    if parentH==modelH
                        show_window([modelName '$']);
                    else
                        grandParentH = get_param(get_param(parentH,'Parent'),'Handle');
                        grandParentName = cr2space(get_param(grandParentH,'Name'));
                        if grandParentH==modelH
                            show_window([grandParentName '/' parentName '$']);
                        else
                            ggParentH = get_param(get_param(grandParentH,'Parent'), 'Handle');
                            if ggParentH==modelH
                                show_window([modelName '/' grandParentName '/' parentName '$']);
                            else
                                show_window([modelName '/.../' grandParentName '/' parentName '$']);
                            end
                        end
                    end
                end
            end

            % Open the signal builder block to the correct tab
            if grpIdx > 0 && rmisl.is_signal_builder_block(objH)
                rmisl.navigateToSigbuilder(objH, grpIdx);
            end
        end
    else
        objIsa = sf('get',objH,'.isa');
        sfisa = rmisf.sfisa;
        switch(objIsa)
        case sfisa.chart
            chartId = objH;
        case sfisa.state
            chartId = sf('get',objH,'.chart');
        case sfisa.transition
            chartId = sf('get',objH,'.chart');
        end
        figH = sf('get',chartId,'.hg.figure');

        % Open the chart if needed
        if isempty(figH) || figH==0
            sf('Open', chartId);
            figH = sf('get',chartId,'.hg.figure');
        end

        chartTitle = get(figH,'Name');
        sf('Open', objH);
        
        % Try to use proper RMI highlighting
        updated_charts = vnvprivate('action_highlight_sf', 'req', objH);
        if ~isempty(updated_charts)
            % try to highlight parent block
            chartBlocks = sf('Private', 'chart2block', updated_charts);
            for block = chartBlocks
                vnvprivate('action_highlight', 'reqInside', block);
            end
        end
        
        if ispc()
            show_window(chartTitle);
        end
    end
end

function inform(msg,title,severity)
    switch(severity)
    case 1,
        errordlg(msg,title)
    case 2,
        warndlg(msg,title)
    end
    if ispc()
        show_window(title);
    end
end

function out = cr2space(in)
    out=in;
    out(out == char(10)) = char(32);
end

function show_window(winTitle)  
    % avoid re-focusing same window over and over
    persistent lastFocused;
    if isempty(lastFocused)
        lastFocused = '__none__';
    end
    
    if nargin == 0
        lastFocused = '__none__';
    else
        if ~strcmp(winTitle, lastFocused)
            reqmgt('winFocus', winTitle);
            lastFocused = winTitle;
        end
    end
end


