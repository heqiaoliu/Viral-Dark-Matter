function varargout = rmidispblock(method,varargin)
% RMIDISPBLOCK - Simulink management function for the System Requirements block.

%  Copyright 2005-2010 The MathWorks, Inc.
%  $Revision: 1.1.6.12 $  $Date: 2010/04/21 22:12:11 $

h = varargin{1};
switch(method)
    case 'updatesys'
        % Called from RMI
        winH  = get_window_handle(h);
        if ~isempty(winH)
            if length(varargin) > 1
                refresh_display(winH, varargin{2});
            else
                refresh_display(winH, true);
            end
        end
        
    case 'updateall'
        modelH = varargin{1};
        
        % This is only for updates related to highlighting or other
        % non-permanent settings, which is why we'll be careful to not mark
        % the model 'dirty'.
        original_state_of_dirty = get_param(modelH, 'dirty');
        
        modelObj = get_param(modelH, 'Object');
        allSysReqBlocks = find(modelObj, 'MaskType', 'System Requirements');
        if ~isempty(allSysReqBlocks)
            for i = 1:length(allSysReqBlocks)
                subsys = allSysReqBlocks(i).Parent;
                rmidispblock('updatesys', subsys, false);
            end
            % Re-check current state so that we do not try to "undirty" a locked liberary
            if strcmp(original_state_of_dirty, 'off') && strcmp(get_param(modelH, 'dirty'), 'on') 
                set_param(modelH, 'dirty', 'off');  
            end
        end

    case 'display'
        % Called from the mask to get the height and width of the window
        p = get_param(h,'Position');
        height = p(4)-p(2); %Height of the main window
        width = p(3)-p(1); %Width of the main window
        varargout{1} = width;
        varargout{2} = height;

    case 'create'   
        % Called when creating a new frame (SystemReq block)
        
        % If locked or inside a library block, then do nothing
        if is_implicit_link(h)
            set_cache(h,[]);
            refresh_display(h);
            return;
        end
        
        % A new SystemReq frame is being created in this diagram ...
        sysH = get_param(h, 'Parent');
        % ... but do not allow more than one SystemReq item
        systemReqBlocks = find_system(sysH, 'SearchDepth', 1, 'id', 'SystemReq');
        if length(systemReqBlocks) > 1 
            % when copying between diagrams
            error_duplicate_block(h);  
        elseif length(systemReqBlocks) == 1 && isempty(get_param(h, 'id'))
            % when inserting a new one from library
            error_duplicate_block(h); 
        else
            initialize_window(h);
            refresh_display(h);
        end

    case 'copyReq'
        % Called when copying a req text block into a new model/system

        % If locked or inside, then do nothing
        if is_locked(h) || is_implicit_link(h)
            return;
        end
        
        % Disallow duplicate items
        if repeated_index(h)
            error_duplicate_block(h);
        else
            % Create a new frame unless already exists in this diagram
            if isempty(find_system(get_param(h, 'Parent'), 'SearchDepth', 1, 'id', 'SystemReq'))
                convert_req_to_win(h);
            end
            refresh_display(h);
        end

    case 'title'
        if is_implicit_link(h)
            out = '<Disabled (inside link)>';
        else
            out = get_param(h,'title');
        end
        varargout{1} = out;

    case {'load','move'}
        refresh_display(h);

    case 'open'
        set_cache(h,[]); % Force to recreate
        refresh_display(h);

    case 'openReq'
        % Called from requirement to view the requirement
        if is_implicit_link(h)
            warndlg('Please refer to the library block for requirements.','View Requirements','modal');
        else
            rmi('view',get_param(h,'Parent'),str2double(get_param(h,'index')));
        end

    case {'close','delete'}
        % Deleting main window or getting ready to save: delete all the
        % requirement blocks. Do not delete 'self' - this is taken care off
        % by the caller.
        if ~is_locked(h) && ~is_link(h)
            if nargin > 2
                % deleting outer block from deleteReq callback.
                set_param(h,'ModelCloseFcn','');
                set_param(h,'PreSaveFcn','');
                set_param(h,'DeleteFcn','');
                delete_block(h);
            else
                delete_req(h, h);
            end
        end
        
    case 'deleteReq'
        % Called from the individual block.
        % We'll delete all Requirements blocks except this one, that will
        % be deleted by the caller.
        mySystem = get_param(h, 'Parent');
        winH = get_window_handle(mySystem);
        if ~isempty(winH) && ~is_locked(winH) && ~is_link(winH)
            % delete everybody else
            delete_req(h, h);
            rmidispblock('delete', winH, h);
            % prepare self for deletion
            set_param(h,'ModelCloseFcn','');
            set_param(h,'PreSaveFcn','');
            set_param(h,'DeleteFcn','');
        end

    case 'label'
        % Determine what the text of the requirement block should be
        index = h;
        parentH = get_param(gcbh,'Parent');
        winH = get_window_handle(parentH);

        if is_link(gcbh)
            varargout{1} = [num2str(index) '. <xxx>'];
            set_cache(winH,[]); % force refresh after disabling link
            return;
        else
            [allLabels, enabled] = rmi('descriptions',parentH);
            
            if index > length(allLabels)
                label = '';
                set_cache(winH,[]); % In a bad state, force to recreate on next callback
            else
                % There is label to display.
                % We will ajust the foreground color for items that are
                % filtered-out, and for active items if requirements are
                % highlighted.
                % 'false' values of 'enabled' means that the requirement is
                % 'filtered-off' based on user settings (User Tag, DOORS
                % Surrogate Item, etc.) 
                if ~enabled(index)
                    set_param(gcbh, 'ForegroundColor', 'gray');
                elseif strcmp(get_param(bdroot, 'ReqHilite'), 'on')
                    set_param(gcbh, 'ForegroundColor', 'orange');
                end

            
                if isempty(allLabels{index})
                    label = [num2str(index) '. <No description entered>'];
                else
                    try
                        label = [num2str(index) '. ' '"' allLabels{index} '"'];
                    catch Mex %#ok<NASGU>
                        label = '';
                        set_cache(winH,[]); % In a bad state, force to recreate on next callback
                    end
                end
            end
            varargout{1} = label;
        end

    otherwise
        error('ReqMgt:rmidispblock', 'Unknown method: %s', method);
end

function out = get_title_code
    out = 'text(w/2,h-4,rmidispblock(''title'',gcbh),''horizontalAlignment'',''center'',''verticalAlignment'',''top'')';


function refresh_display(curH, varargin)
% Refresh rmi display block.

    % If the rmi displock is locked or linked, then there is no need to refresh
    if isempty(curH)|| is_locked(curH) || is_link(curH)
        return
    end
    
    if ~isempty(varargin)
        recreate = varargin{1};
    else
        recreate = true;
    end
    
    if strcmp(get_param(curH, 'Name'), 'System Requirements')
        winH = get_window_handle(curH);
    else
        window = get_param(curH, 'Parent');
        winH = get_window_handle(window);
    end
    
    if isempty(winH)
        convert_req_to_win(curH);
        winH = curH;
    end

    % curH is a window handle
    if winH == curH

        % If window size is different or the number of requirements are different
        % then recreate the requirements block
        [oldWinWidth, oldWinHeight] = get_previous_size(winH);
        [newWinWidth, newWinHeight] = rmidispblock('display', winH);
        nCurReqs = length(get_current_reqs(winH));
        nActReqs = rmi('count', get_param(winH,'Parent'));
        
        if ~recreate
            % pure label or highlighting changes
            update_labels(winH)
     
        elseif nActReqs ~= nCurReqs || ...
                newWinHeight ~= oldWinHeight || ...
                newWinWidth ~= oldWinWidth
            % modified number of reqs or border size
            
            % Determine number of requirements that can fit in the window
            fitReq = get_num_requirement_display(winH);

            % No requirements
            if (nActReqs==0)
                noReqCode = 'text(w/2,h/2,''<No Requirements in System>'',''horizontalAlignment'',''center'',''verticalAlignment'',''top'')';
                set_param(winH,'MaskDisplay',sprintf('%s\n%s',get_title_code,noReqCode));

            % Autofit main window and draw ellipses in MaskDisplay
            elseif (fitReq<nActReqs)
                addReqCode = 'text(w/2,15,''\fontsize{20}\ldots'',''texmode'',''on'')';
                set_param(winH,'MaskDisplay',sprintf('%s\n%s', get_title_code, addReqCode));

            % All the requirements fit in the window
            else
                set_param(winH,'MaskDisplay',get_title_code);
            end

            recreate_req(winH, fitReq);
            set_previous_size(winH, newWinHeight, newWinWidth);
        else
            move_req(winH, -1);
        end

    % curH is a requirements block handle
    else

        % Move the main window
        winPos = get_new_window_position(curH);
        set_param(winH,'MoveFcn','');
        set_param(winH,'Position', winPos);
        set_param(winH,'MoveFcn','rmidispblock(''move'',gcbh)');

        curReqIndex = str2double(get_param(curH,'index'));
        move_req(winH, curReqIndex);
    end
    
function update_labels(winH)
    parentH = get_param(winH, 'Parent');
    sysPath = getfullname(parentH);
    [~, enabled] = rmi('descriptions', parentH);
    fitReq = get_num_requirement_display(winH);
    rmiHighlighted = strcmp(get_param(bdroot, 'ReqHilite'), 'on');
    for i = 1:fitReq
        childBlock = [sysPath '/SLVnV Internal Requirement Sub Block Name ' num2str(i)];
        if ~enabled(i)
            set_param(childBlock, 'ForegroundColor', 'gray');
        elseif rmiHighlighted
            set_param(childBlock, 'HiliteAncestors', 'off');
            set_param(childBlock, 'ForegroundColor', 'orange');
        else
            set_param(childBlock, 'ForegroundColor', 'blue');
        end
    end
    
function move_req(winH, curReqIndex)
% Move requirements blocks
    reqPos    = get_new_req_position(winH);
    reqHeight = reqPos(4)-reqPos(2);
    reqWidth  = reqPos(3)-reqPos(1);
    reqX1     = reqPos(1);
    reqY1     = reqPos(2);

    % Get all requirements block handles
    curReq = get_current_reqs(winH);

    for i=1:length(curReq)
        origMoveFcn = get_param(curReq(i), 'MoveFcn');
        set_param(curReq(i),'MoveFcn','');

        % Do not move the current requirements block because it has already been moved
        if (i~=curReqIndex)
            set_param(curReq(i),'Position',[reqX1,...
                                            reqY1,...
                                            reqX1+reqWidth,...
                                            reqY1+reqHeight]);
        end

        set_param(curReq(i),'MoveFcn',origMoveFcn);
        reqY1 = reqY1+reqHeight;
    end

function recreate_req(winH, fitReq)
% Recreate all requirements block
    reqPos    = get_new_req_position(winH);
    reqHeight = reqPos(4)-reqPos(2);
    reqWidth  = reqPos(3)-reqPos(1);
    reqX1     = reqPos(1);
    reqY1     = reqPos(2);

    delete_req(winH);

    % If necessary determine number of fitReq
    if nargin == 1
        fitReq = get_num_requirement_display(winH);
    end

    % Create the requirement blocks
    load_system('reqmanage');
    curReq = zeros(1,fitReq);
    sysPath = getfullname(get_param(winH, 'Parent'));
    dfltFont = get_param(0,'DefaultBlockFontName'); % will need this for new blocks
    for i=1:fitReq
        % There may be duplicate blocks when called during deleteReq
        try
            curReq(i) = add_block('reqmanage/System Requirements/Subsystem',...
                [sysPath,'/SLVnV Internal Requirement Sub Block Name ',num2str(i)]);
        catch Mex %#ok<NASGU>
            curReq(i) = add_block('reqmanage/System Requirements/Subsystem',...
                [sysPath,'/SLVnV Internal Requirement Sub Block Name ',num2str(i) ' ']);
        end

        % If the user has modified the preferences for block fonts use this
        % font because it may be required to render characters in the local
        % language.
        if ~strcmp(dfltFont,'Helvetica')
            set_param(curReq(i),'FontName',dfltFont);
        end
        
        set_param(curReq(i),'LinkStatus','none');
        set_param(curReq(i),'MoveFcn','');
        set_param(curReq(i),'Position',[reqX1,...
                                        reqY1,...
                                        reqX1+reqWidth,...
                                        reqY1+reqHeight]);
        set_param(curReq(i),'index',num2str(i));

        initialize_req(curReq(i));
        reqY1 = reqY1+reqHeight;
    end
    set_current_reqs(winH,curReq);
    
function delete_req(h, doNotDelete)
% Delete all requirements blocks
    if nargin == 1
        doNotDelete = [];
    end

    mySystem = get_param(h, 'Parent');
    winH = get_window_handle(mySystem);
    curReqs = get_current_reqs(winH);

    for i=1:length(curReqs)
        % Do not delete curReqs while in a callback
        if ~isequal(curReqs(i),doNotDelete)
            set_param(curReqs(i),'LinkStatus','none');
            set_param(curReqs(i),'DeleteFcn','');
            set_param(curReqs(i),'MoveFcn','');
            delete_block(curReqs(i));
        end
    end
    set_current_reqs(winH,[]);


function convert_req_to_win(reqH)
% Convert Req Text block into a System Requirement block
    set_param(reqH,'LinkStatus','none');

    % Protect against recursion from delete callback
    set_param(reqH,'MoveFcn','');
    winPos = get_new_window_position(reqH);
    try
        set_param(reqH,'Position',winPos);
    catch Mex %#ok<NASGU>
    end
    
    load_system('reqmanage');
    libH = get_param('reqmanage/System Requirements', 'Handle');

    % Copy over all mask-related parameters in a single set_param
    % (delay calling BlockEvalParams until block is fully set up).
    reqH = get_param(reqH,'Handle');
    objParams = fieldnames(set(reqH));
    setParamArgs = {};

    for i=1:length(objParams)
        thisParam = objParams{i};
        if ~isempty(regexp(thisParam, '^Mask', 'once'))
            setParamArgs{end+1} = thisParam;  %#ok<AGROW>
            setParamArgs{end+1} = get_param(libH, thisParam); %#ok<AGROW>
        end
    end
    set_param(reqH, setParamArgs{:});

    % Set color
    set_param(reqH,'ForegroundColor',get_param(libH,'ForegroundColor'));
    set_param(reqH,'BackgroundColor',get_param(libH,'BackgroundColor'));

    % Initialize callbacks, name, fontsize
    initialize_window(reqH);


function newWinPos = get_new_window_position(reqH)
% Calculate new window position from requirements block
    winH        = get_window_handle(reqH);
    titleHeight = get_title_height(winH);
    reqHeight   = get_requirement_height(winH);
    border      = get_window_border;

    % Get original window height.  If winH is empty, then return default.
    if ~isempty(winH)
        winPos = get_param(winH,'Position');
    else
        load_system('reqmanage');
        winPos = get_param('reqmanage/System Requirements','Position');
    end
    origWinHeight = winPos(4)-winPos(2);

    % Get the current index of the requirement block
    curReqIndex = str2double(get_param(reqH,'index'));

    % Calculate new window position
    reqPos = get_param(reqH,'Position');
    reqWidth = reqPos(3)-reqPos(1);   % Find the new width
    reqX1 = reqPos(1);
    reqY1 = reqPos(2)-(curReqIndex-1)*reqHeight;

    winX1 = reqX1-border;
    winY1 = reqY1-titleHeight;
    newWinPos = [winX1,...
                 winY1,...
                 winX1+reqWidth+2*border,...
                 winY1+origWinHeight];

function newReqPos = get_new_req_position(winH)
% Calculate first requirements block position from window
    titleHeight = get_title_height(winH);
    reqHeight   = get_requirement_height(winH);
    border      = get_window_border;

    % Calculate requirements block width
    winPos   = get_param(winH,'Position');
    winWidth = winPos(3)-winPos(1);
    reqWidth = winWidth-2*border;

    % Calculate the first requirements block position
    reqX1 = winPos(1)+border;
    reqY1 = winPos(2)+titleHeight;
    newReqPos = [reqX1,...
                 reqY1,...
                 reqX1+reqWidth,...
                 reqY1+reqHeight];

function border = get_window_border
% Space between the reqs and the box border
    border = 5;

function reqHeight = get_requirement_height(winH)
% Calculate the requirement block height
    reqHeight = get_title_height(winH);

function titleHeight = get_title_height(winH)
% Calculates the title height
    pad = 8; % Space between bottom of title and first req
    fontSize = get_window_font_size(winH);
    titleHeight = fontSize + pad;

function fitReq = get_num_requirement_display(winH)
% Calculates the number of requirements for a given window
    winPos        = get_param(winH,'Position');
    reqHeight     = get_requirement_height(winH);
    titleHeight   = get_title_height(winH);
    reqHeightList = winPos(4)-winPos(2)-titleHeight;

    numReq = rmi('count',get_param(winH,'Parent'));
    fitReq = min(numReq,floor(reqHeightList/reqHeight));

function out = get_window_font_size(winH)
% Get window fontsize.  If not specified grab the model default.
    try
        out = get_param(winH,'FontSize');
        sysH = bdroot(winH);
    catch Mex %#ok<NASGU>
        out = -1;
        sysH = bdroot(gcs);
    end
    if isempty(sysH)
        sysH = bdroot(gcs);
    end

    if isempty(out) || (out == -1)
        out = get_param(sysH,'DefaultBlockFontSize');
    end


function error_duplicate_block(h)
% Error dialog for duplicate block
    set_param(h,'LinkStatus','none');
    set_param(h,'DeleteFcn','');
    errH = errordlg('System Requirement block already exists in this model','Insert Block Error','modal');
    set(errH,'UserData',h);
    set(errH,'CloseRequestFcn',@fig_delete_block);
    okH = findall(errH,'Tag','OKButton');
    set(okH,'Callback',@fig_delete_block);

function fig_delete_block(varargin)
% Callback function to delete duplicate block
    try
        blockH = get(gcbf,'UserData');
        if ishandle(blockH)
            delete_block(blockH);
        end
        delete(gcbf);
    catch Mex %#ok<NASGU>
    end


function out = is_locked(h)
    out = strcmpi(get_param(bdroot(h), 'Lock'), 'on');
    if out 
        return;
    end
    out = 0;
    parent =  get_param(h,'parent');
    while (strcmpi(get_param(parent, 'type'),'block'))
        if  strcmpi(get_param(parent, 'blocktype'),'SubSystem') && ...
            strcmpi(get_param(parent, 'Permissions'),'ReadOnly')
            out = 1;
            break;
        end
        parent = get_param(parent, 'parent');
    end


function out = is_link(h)
    out = any(strcmpi(...
        {'implicit', 'resolved'}, ...
        get_param(h, 'LinkStatus')));

function out = is_implicit_link(h)
    out = strcmpi('implicit', get_param(h, 'LinkStatus'));


function out = get_window_handle(h)
    if is_window_handle(h)
        out = h;
        return
    end

    try
        if strcmp(get_param(h,'Type'),'block_diagram') || strcmp(get_param(h,'BlockType'),'SubSystem')
            parentH = get_param(h, 'Handle'); % use self for diagrams and subsystems that are not SystemReq
        else
            parentH = get_param(h, 'Parent');
        end
        sysH = get_param([getfullname(parentH) '/System Requirements'], 'Handle');
        if is_window_handle(sysH)
            out = sysH;
            return
        end
        if is_window_handle(parentH)
            out = parentH;
            return
        end
    catch Mex %#ok<NASGU>
        parentH = [];
    end

    % Could be a system handle or a model handle
    if ishandle(h)
        found = find_system(h, 'SearchDepth', 1, 'id', 'SystemReq');
        if isempty(found) && ~isempty(parentH)
            found = find_system(parentH, 'SearchDepth', 1, 'id', 'SystemReq');
        end
    else
        found = [];
    end

    if ~isempty(found) && iscell(found)
        out = found{1};
    else
        out = found;
    end

function out = is_window_handle(h)
    out = false;
    try
        if strcmpi(get_param(h, 'id'), 'SystemReq')
            out = true;
        end
    catch Mex %#ok<NASGU>
    end


function initialize_window(winH)
    set_param(winH,'LinkStatus','none');
    set_param(winH,'id','SystemReq');
    set_param(winH,'CopyFcn','rmidispblock(''create'',gcbh)');
    set_param(winH,'OpenFcn','rmidispblock(''open'',gcbh)');
    set_param(winH,'PostSaveFcn','rmidispblock(''open'',gcbh)');
%    set_param(winH,'UndoDeleteFcn','rmidispblock(''open'',gcbh)'); % causes segV
    set_param(winH,'UndoDeleteFcn','');
    set_param(winH,'LoadFcn','rmidispblock(''load'',gcbh)');
    set_param(winH,'MoveFcn','rmidispblock(''move'',gcbh)');
    set_param(winH,'ModelCloseFcn','rmidispblock(''close'',gcbh)');
    set_param(winH,'PreSaveFcn','rmidispblock(''close'',gcbh)');
    set_param(winH,'DeleteFcn','rmidispblock(''delete'',gcbh)');
    set_param(winH,'Name', 'System Requirements');
    set_cache(winH,[]);

function initialize_req(reqH)
    winH = get_window_handle(reqH);
    fontSize = get_window_font_size(winH);
    set_param(reqH,'LinkStatus','none');
    set_param(reqH,'MoveFcn','rmidispblock(''move'',gcbh);');
    set_param(reqH,'DeleteFcn','rmidispblock(''deleteReq'',gcbh);');
    set_param(reqH,'CopyFcn','rmidispblock(''copyReq'',gcbh)');
    set_param(reqH,'OpenFcn','rmidispblock(''openReq'',gcbh)');
    set_param(reqH,'UndoDeleteFcn','');
    set_param(reqH,'FontSize',fontSize);
    set_param(reqH,'ShowName','off');


function out = get_current_reqs(winH)
% Get current requirements block handles from cache or searching for them
    cache = get_cache(winH);
    curReq = cache.curReq;

    % Check Req handle
    if ~isempty(curReq) && ...
        ( ~any(ishandle(curReq)) || ~strcmpi(getfullname(bdroot(winH)), getfullname(bdroot(curReq(1)))))
        curReq = [];
    end

    % If stale, search for it
    if ~isempty(winH) && isempty(curReq)
        sysH = get_param(winH, 'Parent');
        h = find_system(sysH, 'RegExp', 'on', 'SearchDepth', 1, 'Name', 'Requirement');

        curReq = zeros(1, length(h));
        actNReq = 0;
        for i = 1:length(h)
            if ~isempty(regexp(h{i}, 'SLVnV Internal Requirement Sub Block Name \d', 'once'))
                try
                    get_param(h{i},'index'); % test if we can get index, otherwise block is corrupt
                    actNReq = actNReq + 1;
                    curReq(actNReq) = get_param(h{i}, 'Handle');
                catch Mex %#ok<NASGU>
                    set_param(curReq(i),'DeleteFcn','');
                    delete_block(curReq(i));
                end
            end
        end
        curReq = curReq(1:actNReq);
        set_current_reqs(winH, curReq);
    end
    out = curReq;

function set_current_reqs(winH, curReq)
    cache = get_cache(winH);
    cache.curReq = curReq;
    set_cache(winH, cache);


function [width, height] = get_previous_size(winH)
    cache = get_cache(winH);
    height = cache.prevSize.height;
    width = cache.prevSize.width;

function set_previous_size(winH, height, width)
    cache = get_cache(winH);
    cache.prevSize.height = height;
    cache.prevSize.width = width;
    set_cache(winH, cache);


function out = get_cache(winH)
    if ~isempty(winH)
        cache = get_param(winH, 'UserData');
    else
        cache = [];
    end
    if ~isstruct(cache)
        cache = struct('curReq', [], 'prevSize', []);
        cache.curReq = [];
        cache.prevSize = struct('height', -1, 'width', -1);
    end
    out = cache;

function set_cache(winH, cache)
    if ~is_locked(winH)
        set_param(winH, 'UserData', cache);
    end
    
function repeated = repeated_index(h)
    myValues = get_param(h, 'MaskValues');
    myIndex = str2double(myValues{2});
    reqs = get_current_reqs(h);
    matched = false;
    repeated = false;
    for i = 1:length(reqs)
        values = get_param(reqs(i), 'MaskValues');
        index = str2double(values{2});
        if index == myIndex
            if matched
                repeated = true;
                break;
            else
                matched = true;
            end
        end
    end
    
