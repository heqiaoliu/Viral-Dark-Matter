function [isSFError, sfIds, errType, strippedMsg, errorMsg, openFcn,relevantSlHandle,hyperlinkSlHandle] = parse_error_msg( origId, origStr , blkHandle)
%[SFIDS,ERRORTYPE,STRIPPEDMSG,ERRORMSG,OPENFCN] = PARSE_ERROR_MSG(RAWERRORSTR,BLKHANDLE)
%Parses an error message and figures out relavant information if it is constructed by
%construct_error() function. Note that blkHandle input is used only if this is not a SF generated error message
%and it is relevant to an SF chart (i.e., unresolved chart workspace data)
%

%   Vladimir Kolesnikov
%  Copyright 1995-2010 The MathWorks, Inc.
%  $Revision: 1.19.2.19 $  $Date: 2010/04/05 23:02:07 $

% All SF error msgs constructed by construct_error() will have the following format:
% Stateflow <errType> Error (#<id>): <error message>
% sfIds set to 0 notifies an error (non-SF error msg).
% Empty sfIds means that no SF id is connected with the error msg

    sfIds = 0;
    errType = '';
    strippedMsg = '';
    openFcn = '';
    relevantSlHandle = [];
    hyperlinkSlHandle = [];
    chartId = [];
    
    rawStr = clean_error_msg(origStr);
    
    % see if the error msg looks like SF error
    errorMsg = regexpi(rawStr, 'stateflow.*?error\s*[:(].*', 'match','once');
    if isempty(errorMsg)
        [isSFError,rawStr,hyperlinkSlHandle,chartId] = preprocess_sl_error(origId, rawStr,blkHandle);
        if isSFError
            sfIds = chartId;
            if isempty(sfIds)
                sfIds = 0;
            end
        end
    else
        isSFError = 1;
    end
    
    if ~isSFError || isempty(rawStr)
        return;
    end
    
    n = regexpi(rawStr, '(?:-->)?(?<component>truth table|embedded matlab|stateflow)\s+(?<errType>.*?)\s+error\s+.*?(?<idsStr>\(.*?\))?.*?:(?<stripped>.*)', 'names', 'once');
    
    if isempty(n)
        % If pattern not found, figure out component from chartId
        % and keep raw error string.
        n(1).component = get_component_name(chartId);
        n(1).idsStr = '';
        n(1).stripped = rawStr;
        n(1).errType = 'Interface';
    end
        
    sfIds = str2num(regexprep(n.idsStr, '\D*(\d+)\D*', '$1 ')); %#ok<ST2NM>
    
    if isempty(sfIds) && ~isempty(n.idsStr)
        n2 = regexpi(n.idsStr, '(?<chart>chart)?(?<machine>machine)?', 'names', 'once');
        if ~isempty(n2)
            if ~isempty(n2.chart)
                hyperlinkSlHandle = map_blk_to_sf_blk(blkHandle);
                chartId = block2chart(hyperlinkSlHandle);
                n.component = get_component_name(chartId);
            elseif ~isempty(n2.machine)
                hyperlinkSlHandle = bdroot(blkHandle);
            end
        end
    end
    
    sfIds = [chartId,sfIds];
    sfIds(~sf('ishandle', sfIds)) = []; % ignore non-SF handles
    
    strippedMsg = n.stripped;
    errType = n.errType;
    
    switch lower(n.component)
        case 'stateflow'
            compName = 'Stateflow';
        case 'truth table'
            compName = 'Truth Table';
        case 'embedded matlab'
            compName = 'Embedded MATLAB';
        otherwise
            compName = 'Stateflow';
    end
    
    errorMsg = [compName ' ' errType ' Error: ' strippedMsg];
    
    if ~isempty(hyperlinkSlHandle)
        relevantSlHandle = hyperlinkSlHandle;
    else
        relevantSlHandle = get_relevant_sl_handle(sfIds);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sfBlkHandle = map_blk_to_sf_blk(blkHandle)
    sfBlkHandle = [];
    try
        if(strcmp(get_param(blkHandle,'MaskType'),'Stateflow'))
            %% is itself a SF block
            sfBlkHandle = blkHandle;
            return;
        end
    catch ME %#ok<*NASGU>
        return;
    end

    try
        blkParent = get_param(blkHandle,'Parent');
        if(isempty(blkParent)...
                || ~strcmp(get_param(blkParent,'Type'),'block')...
                || ~strcmp(get_param(blkParent,'MaskType'),'Stateflow'))
            %%% not SF hidden block. just return
            return;
        end
        sfBlkHandle= get_param(blkParent,'handle');
    catch ME
        return;
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function relevantSlHandle = get_relevant_sl_handle(ids)
    chartId = 0;
    relevantSlHandle = [];
    
    if isempty(ids)
        return;
    end
    
    machineISA = sf( 'get', 'default', 'machine.isa' );
    chartISA = sf( 'get', 'default', 'chart.isa' );
    
    for i = 1:length(ids)
        thisISA = sf( 'get', ids(i), '.isa' );
        while  thisISA~= chartISA && thisISA ~= machineISA
            ids(i) = sf('ParentOf', ids(i));
            thisISA = sf('get', ids(i), '.isa');
        end
        if thisISA == chartISA
            if chartId
                return;
            end
            chartId = ids(i);
        end
    end
    
    if chartId
        instanceId = sf( 'get', chartId, '.instance' );
        relevantSlHandle = sf( 'get', instanceId, '.simulinkBlock' );
    end


function [isSfError,cookedString,hyperlinkSlHandle,chartId] = preprocess_sl_error(origId, rawString,blkHandle)
    
    %%% now we check if this is an error pertaining to an SF block. In which case
    %%% we might want to process it and own it. One example is unresolved chart
    %%% workspace data where the blkHandle is of the Sfunction underneath SF block.
    %%% other examples will be discovered shortly
    isSfError = 0;
    cookedString = rawString;
    hyperlinkSlHandle = [];
    chartId = [];
    
    if(blkHandle==0.0)
        return;
    end
    
    %% in the following, we are trying to deal with the
    %% SL block pathnames. SL allows block-path names to contain
    %% all sorts of unparsable strings that dont work with get_param()
    %% hence, if SL can't handle this, just bail.
    try
        for i=1:length(blkHandle)
            if isStateflowBlock(blkHandle(i))
                continue
            end
            blkParent = get_param(blkHandle(i),'Parent');
            if ~isempty(blkParent) && isStateflowBlock(blkParent)
                %%% is a SL/SF error
                isSfError = 1;
                break;
            end
        end
        if(~isSfError)
            return;
        end
        hyperlinkSlHandle = get_param(blkParent,'handle');
    catch ME
        return;
    end
    
    if ~isempty(regexp(rawString, 'Stateflow Suppress Error', 'once'))
        % suppress the error
        cookedString = '';
        return;
    end

    % translate IO size mismatch errors
    chartId = sf_block_object_ids(hyperlinkSlHandle);
    rawString = translate_io_mismatch_error(origId,rawString,chartId,blkHandle);
     
    % check for SL errors that we would like to handle   
    errorPrefix = 'Error evaluating parameter';
    if strncmp(rawString,errorPrefix,length(errorPrefix))
        % Handle kanji case too.
        %
        % WISH: revisit this code and make it truly language independent
        % rather than explicitly handling kanji and non-kanji cases.
        % JRT, RH
        lang = get(0,'language');
        if length(lang) >= 2 && strncmpi(lang,'ja',2)   % if this is japanese
            jaSearchString=xlate('Undefined function or variable ''%s''');
            jaSearchString=jaSearchString(end-14:end);
            if ~isempty(findstr(jaSearchString,rawString)),
                n = regexp(rawString, '''(?<symbol>\w+)''', 'names', 'once');
                if ~isempty(n)
                    dataName = n.symbol;
                end
            else
                % doesn't start with our prefix. do nothing
                return;
            end
    
        else  % non-japanese
            n = regexp(rawString, 'Undefined\s+function\s+or\s+variable\s+''(?<symbol>\w+)''', 'names', 'once');
            if isempty(n)
                % doesn't start with our prefix. do nothing
                return;
            end
    
            %%% starts with the prefix we are looking for.
            %%% this must be an undefined chart workspace data error. extract data
            %%% name and then get dataId
            dataName = n.symbol;
        end;
    
        allChartData = sf('DataOf',chartId);
        dataId = sf('find',allChartData,'data.name',dataName);
        %%% at this point we have the ID of the undefined data. construct an error message in the SF standard format
        %%% we return this newly constructed error message back in effect highjacking SL's error message
        %%% and morphing it into ours so that users know exactly what is needed to be done with workspace data.
        throwFlag = -1; %%just constructs and doesn't throw and doesn't touch last err
        errorMsg = sprintf('Error evaluating %s parameter data ''%s'' (#%d) in its parent workspace.',...
                           get_component_name(chartId),dataName,dataId);
        cookedString = construct_error( dataId,'Runtime', errorMsg, throwFlag );
    elseif ~isempty(rawString)
        %%% we know that the error originated on one of the hidden blocks of SF masked block.
        %%% we take ownership of it. this ensures that the hyperlink wont open up SF mask block
        %%% and wreak havoc
     
        throwFlag = -1; %%just constructs and doesn't throw and doesn't touch last err
        cookedString = construct_error(chartId, 'Interface', rawString, throwFlag);
    else
        %%% this error is a red herring!  Suppress it!
        cookedString = '';
    end
    
    isSfError = 1;    

function compName = get_component_name(chartId)
    if is_eml_chart(chartId)
       compName = 'Embedded MATLAB';
    elseif is_truth_table_chart(chartId)
       compName = 'Truth Table';
    else
       compName = 'Stateflow';
    end

function chartId = sf_block_object_ids(blkParentHandle)
    instanceId = sf('find','all','instance.simulinkBlock',blkParentHandle);
    if isempty(instanceId)
        maskType = get_param(blkParentHandle, 'MaskType');
        if strcmp(maskType, 'StateflowAtomicSubchartWrapper')
            chartBlockH = Stateflow.SLUtils.findSystem(blkParentHandle, 'MaskType', 'Stateflow');
            if isempty(chartBlockH)
                % broken link atomic subchart
                chartBlockH = get_param(get_param(blkParentHandle, 'Parent'), 'Handle');
            end
            chartId = sf_block_object_ids(chartBlockH);
        else
            %% this is a library chart. an open_system will automatically load
            %% the library model if necessary and sets the active instance properly
            open_system(blkParentHandle);
            chartId = sf('find','all','chart.activeInstance',blkParentHandle);
        end
    else
        chartId = sf('get',instanceId,'instance.chart');
    end

function yn = isStateflowBlock(blkH)
    yn = strcmpi(get_param(blkH, 'Type'), 'Block') && ...
        strcmpi(get_param(blkH, 'BlockType'), 'Subsystem') && ...
        strcmpi(get_param(blkH, 'MaskType'), 'Stateflow');
