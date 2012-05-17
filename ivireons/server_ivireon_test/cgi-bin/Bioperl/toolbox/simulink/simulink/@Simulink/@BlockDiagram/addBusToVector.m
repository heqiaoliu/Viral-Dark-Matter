function [dstBlocks, busToVectorBlocks] = addBusToVector(model, includeLibs, reportOnly)
%ADDBUSTOVECTOR  Add Bus To Vector blocks to convert bus signals used as
% vectors into vector signals
%
%   [DstBlocks, BusToVectorBlocks] = ADDBUSTOVECTOR(model, includeLibs, reportOnly)
%   returns detailed information on buses used as vectors in model and,
%   optionally, the libraries they reference. This command also optionally
%   inserts Bus To Vector blocks as needed in model and in the libraries it
%   references.
%
%   DstBlocks = ADDBUSTOVECTOR(model)returns detailed information on
%   buses used as vectors in model.
%
%   DstBlocks = ADDBUSTOVECTOR(model, includeLibs) optionally includes
%   library blocks in its search.
%
%   [DstBlocks, BusToVectorBlocks] = ADDBUSTOVECTOR(model, includeLibs, reportOnly)
%   optionally adds Bus To Vector blocks to the block diagram where
%   necessary, and returns the newly added blocks in the output parameter
%   BusToVectiorBlocks.
%
%    Inputs:
%
%      model:       model name or handle
%
%                   Before invoking this command, you must save model and
%                   insure that it compiles  without error. Additionally,
%                   the "Mux blocks used to create  bus signals" option in
%                   the Diagnostics->Connectivity->Buses section of the
%                   Configuration Parameters dialog box must be set to
%                   "error". You can use the following MATLAB command to
%                   set this parameter:
%                   set_param(mdlName, 'StrictBusMsg', 'ErrorLevel1');
%
%      includeLibs: [true/false] (default is false)
%                   Include library blocks in the search. If reportOnly is
%                   false, library blocks will also be modified and saved.
%
%      reportOnly:  [true/false] (default is true)
%                   Detect bus signals used as vectors but do not modify
%                   any libraries or models. The number of bus signals used
%                   as vectors will be displayed. The list of added Bus To
%                   Vector blocks are returned by the function.
%
%    Outputs:
%
%      DstBlocks:   An array of structures containing information pretaining
%                   the blocks connected to buses that are treated as
%                   vectors. Each element in the array is a structure
%                   containing the following fields:
%
%                   BlockPath: A string specifying the path to the block
%                   the bus is connected to.
%          
%                   InputPort: An integer specifing the index of the input 
%                   port the bus is connected to.
%
%                   LibPath: If the block is a library block instance,
%                   LibPath contains the path to the library block it is an
%                   instance of. If the block is not a library block
%                   instance, LibPath is empty([]). This field will always
%                   be empty when includeLibs is set to 'false'.
%
%      BusToVectorBlocks: 
%                   A cell array containing the path to all the Bus To
%                   Vector blocks that were added to the system.
%                   BusToVectorBlocks returns empty ([]) when reportOnly is
%                   set to 'true'.
%
%
%   Modifying a library block will affect all instances of the block
%   including those contained in other Simulink models. Run addBusToVector
%   with includeLibs and reportOnly set to true to obtain a list of all
%   destination blocks that will be affected.
%
%   If reportOnly is false, the function will add Bus To Vector blocks to
%   convert each bus signal used as a vector into a vector, and will
%   reconnect the signals in such a way that the destination blocks are fed
%   vector signals converted from the original buses.
%
%   Because it is difficult to undo the changes when reportOnly is false,
%   you should make a backup copy of your model and libraries before
%   using this command.
%
%   For more information, see <a href="matlab: helpview([docroot '/mapfiles/simulink.map'], 'bustovector')">Bus To Vector</a>.

%   Copyright 1990-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $


% do not disp backtraces when reporting warning
wStates = [warning; warning('query','backtrace')];
warning off backtrace;
warning on; %#ok

s = onCleanup(@()warning(wStates));

% Initialize output
busToVectorBlocks = [];
dstBlocks = [];


% Check number of input arguments
if (nargin < 1 || nargin > 3)
    DAStudio.error('Simulink:utility:slAddBusToVectorUsage');
end

% Set the default value for reportOnly and inludeLibs
if nargin <3
    reportOnly = true;
end

if nargin < 2
    includeLibs = false;
end


% Get the model name
model = check_input_model_l(model);

% Identify blocks and ports in the model and libraries that are connected
% to a bus that is being trated as a vector.
[unique_buses_as_vectors, dstBlocks] = get_buses_treated_as_vectors_l(model, includeLibs);
if(isempty(unique_buses_as_vectors))
    disp(['###' DAStudio.message('Simulink:utility:slAddBusToVectorNoBusesFound')]);
    return;
end

if ~reportOnly

    % Obtain block list as cell array
    cell_buses_as_vectors_blockPaths = {unique_buses_as_vectors.BlockPath};

    % Get the name of block diagrams that should be modified
    bds         = strtok(cell_buses_as_vectors_blockPaths,'/');
    uniqueBds   = unique(bds);
    uniqueLibs  = setdiff(unique(bds), model);


    % Unlock the libraries if we are modifying them
    for idx = 1:length(uniqueLibs)
        set_param(uniqueLibs{idx},'lock','off');
    end

    % insert the BusToVector blocks
    busToVectorBlocks = cell(length(unique_buses_as_vectors),1);
    insertErrors=[];
    for idx = 1:length(unique_buses_as_vectors)
        try
            tmpBlockPath = getfullname(insert_BusToVector_block_l(unique_buses_as_vectors(idx)));
            busToVectorBlocks{idx} = tmpBlockPath;
        catch me
            newError.OrigBlockPath = unique_buses_as_vectors(idx).OrigBlockPath;
            newError.Inport = unique_buses_as_vectors(idx).InputPort;
            newError.Error = me;
            insertErrors = [insertErrors; newError]; %#ok<AGROW>
        end
    end
    numErrors = length(insertErrors);        

    if(numErrors == 0)
        % Everything went fine
        disp(['### ' DAStudio.message('Simulink:utility:slAddBusToVectorSuccessfullyInserted')]);
        disp(['### ' DAStudio.message('Simulink:utility:slAddBusToVectorEnableStrictBusError')]);
    else
        % There we issues when trying to insert the blocks
        display_insert_warning_l(insertErrors);
        disp(['### ' DAStudio.message('Simulink:utility:slAddBusToVectorNotAllBlocksWereInserted')]);
    end

    % Save the model and libraries. Close them if any library was modified.
    save_and_close_if_has_lib_l(model, uniqueBds, uniqueLibs);

    
end


disp(['### ' DAStudio.message('Simulink:utility:slAddBusToVectorDoneProcessing', model)]);
%endfunction ADDBUSTOVECTOR

% Function check_input_model_l=================================================
%  (1) input must be either a model name or handle to an open model
%  (2) SimulationStatus of model must be stopped, i.e., model is not running
%  (3) Model should not be dirty
function ioMdl = check_input_model_l(ioMdl)

if ~ischar(ioMdl),
    % must be a handle to an open model
    if ~ishandle(ioMdl),
        DAStudio.error('Simulink:utility:slAddBusToVectorUsage');
    end
    ioMdl = get_param(ioMdl,'Name');
end

% Load the model if it is not loaded
load_system(ioMdl);

% Model should not be compiled or it should not be running
simStatus = get_param(ioMdl,'SimulationStatus');
if ~strcmpi(simStatus, 'stopped')
    DAStudio.error('Simulink:utility:slAddBusToVectorBadSimulationStatus', simStatus);
end

% Model should not be dirty
dirtyStr = get_param(ioMdl, 'Dirty');
if strcmpi(dirtyStr,'on')
    DAStudio.error('Simulink:utility:slAddBusToVectorUnsavedChanges');
end

currSetting = get_param(ioMdl, 'StrictBusMsg');
if(~isempty(strmatch(currSetting, {'None','Warning'}, 'exact')))
    DAStudio.error('Simulink:utility:slAddBusToVectorInvalidStrictBusMsg');
end



%endfunction


%function save_and_close_if_has_lib_l =========================================
% Save the models and libraries. If any library is modified, close
% the models and libraries.
%   uniqueBds:   unique list of block diagrams
%   hasLib: the list contains at least a library
function save_and_close_if_has_lib_l(model, uniqueBds, uniqueLibs)

libModified = ~isempty(uniqueLibs);
mdlModified = length(uniqueBds) > length(uniqueLibs);

% Either mdlModified or libModified has been modified
if libModified
    disp(['### ' DAStudio.message('Simulink:utility:slAddBusToVectorLibrariesModified')]);

    savedAll = true;
    okToErr = false;
    % Report a warning for each bd if we cannot save it.
    % Note that we are looping through all modified bds which includes
    % the model
    for idx = 1:length(uniqueBds)
        isOk = save_system_l(uniqueBds{idx}, okToErr);
        if isOk
            close_system(uniqueBds{idx});
        else
            savedAll = false;
        end
    end

    % Since the libraries have been modified, we must close the model too
    % Note: if mdlModified = true, it will be saved and closed in the above
    % for loop
    if ~mdlModified
        close_system(model, 0);
    end

    % Report an error, if we were not able to save one of the block diagrams
    if ~savedAll
        DAStudio.error('Simulink:utility:slAddBusToVectorUnableToSaveModelLib');
    end
else
    % mdlModified must be true. Otherwise, there was no buses being treated
    % as vectors. Save the model. Since okToErr is true, no need to check
    % the return status of save_system_l.
    okToErr = true;
    save_system_l(model, okToErr);
end

%endfunction save_and_close_if_has_lib_l

% Function save_system_l ======================================================
% Abstract:
%   Save the block diagram. Report an error or warning if save_system failed.
%
function isOk = save_system_l(model, okToError)
isOk = true;
try
    save_system(model);
catch me
    isOk  = false;

    if okToError
        DAStudio.error('Simulink:utility:slAddBusToVectorUnableToSave', model, me.message);
    else
        DAStudio.warning('Simulink:utility:slAddBusToVectorUnableToSave', model, me.message);
    end
end
%endfunction


% Function get_buses_treated_as_vectors_l =====================================
% Abstract:
%   Compile the model, and return aray of structyres with full path of dst
%   blocks trating bus as a vector, and the index of the port the bus
%   is connected to.
function [unique_buses_as_vectors, buses_as_vectors] = get_buses_treated_as_vectors_l(model, includeLibs)

try
    cmd = [model, '(''init'');'];
    evalc(cmd);

    buses_as_vectors = get_param(model,'BusInputIntoNonBusBlock');

    cmd = [model, '(''term'');'];
    evalc(cmd);

catch me
    DAStudio.error('Simulink:utility:slAddBusToVectorCompilationError', me.message);
end

% Get rid of Selector Blocks and Demux blocks with inconsistent inputs
if ~isempty(buses_as_vectors)
    buses_as_vectors = filter_blocks_l(buses_as_vectors);
end

% Some of the block/port combinations may refer to ports that are directly 
% connected to the inport of a parent port. We would rather work with the 
% top-most block that has the input that ends up at the target block.
buses_as_vectors = get_top_level_block_l(buses_as_vectors);

unique_buses_as_vectors = buses_as_vectors;

if isempty(buses_as_vectors),
    return;
end

disp(['### ' DAStudio.message('Simulink:utility:slAddBusToVectorUpdatingBD', model)]);

% Back up the original path on unique_buses_as_vectorsmsince it will be
% overrridden with the libPath when the block is a ref
for idx = 1:length(unique_buses_as_vectors)
    unique_buses_as_vectors(idx).OrigBlockPath = unique_buses_as_vectors(idx).BlockPath;
end

% Force the addition of a new field to the struct array:
buses_as_vectors(1).LibPath='';

% Separate block list
cell_buses_as_vectors_blockPaths = {buses_as_vectors.BlockPath};
cell_buses_as_vectors_portNums = {buses_as_vectors.InputPort}';    

refBlks = get_param(cell_buses_as_vectors_blockPaths,'ReferenceBlock');

% Reference blocks that are stand-alone (not part of a lib sub-system) can
% be treated as if they were not part of a library, and have a Bus To
% Vector block added to their input.
ParentBlock = get_param(cell_buses_as_vectors_blockPaths, 'Parent');
isBlockDiagram = strcmp(get_param(ParentBlock, 'Type'), 'block_diagram');
ParentRef = get_param(ParentBlock(~isBlockDiagram), 'ReferenceBlock');
RefReplaceMask = isBlockDiagram;
RefReplaceMask(~isBlockDiagram)= strcmp(ParentRef, '');
refBlks(RefReplaceMask)=repmat({''}, sum(RefReplaceMask),1);

% References may be instances of blocks in Simulink libs or of a user's
% lib. We need to tell one from the other. In other words, a block that was
% originally a Simulink lib block may also be in a user lib. get_param(blk,
% 'ReferenceBlock') will point to the Simulink lib block in both cases, and
% we need to treat them differently. We can discriminate between them by
% looking at the parent's ReferenceBlock param.
refBlksIdx = find(~cellfun('isempty', refBlks));
ParentRef = get_param(ParentBlock(refBlksIdx), 'ReferenceBlock');
BName = get_param(cell_buses_as_vectors_blockPaths(refBlksIdx), 'Name');
refBlks(refBlksIdx) = strcat(ParentRef, '/', BName);

refBlksP = strcat(refBlks, ':', cellstr(num2str(cell2mat(cell_buses_as_vectors_portNums))));
badLibIdx = [];
badLibArray=[];
% We now need to find all instances of the library blocks to make sure they
% are accounted for in the list of blocks using buses as vectors. If they
% are not, that means that those references are being used in other
% contexts and therefore cannot be modified (we can't add a Bus To Vector
% block to their inputs).
for i=1:length(refBlksIdx)
    if ~isempty(refBlksP{refBlksIdx(i)})
        libPath  = get_param(refBlks{refBlksIdx(i)}, 'Parent');
        blkName = get_param(refBlks{refBlksIdx(i)}, 'Name');
        libInstances = find_system(model, 'FollowLinks', 'on', 'LookUnderMasks', ...
            'all', 'ReferenceBlock', libPath);
        refInst = strcat(libInstances, '/',  blkName);

        % Find library blocks that are being used in more than one context within the
        % list that we have. Basically we are looking for repetitions in refBlks
        % that have inconsistent port numbers.
        libIdx = strmatch(refBlksP{refBlksIdx(i)}, refBlksP, 'exact');
        if length(libIdx) ~= length(refInst)
            badLib = struct('libIdx', {refBlksIdx(i)}, 'libRefs', {refInst});
            badLibArray = [badLibArray; badLib]; %#ok<AGROW>
        end

        % Mark library instances that I have found so far as having been
        % processed. This way we dont hit the same lib-port combination
        % more than once.
        refBlksP(libIdx)=repmat({''}, length(libIdx),1);                
    end
end

% Warn the user about the ref blocks that we will have to ignore
% because they are used in more than one context.
if ~isempty(badLibArray)
    badLibIdx = [badLibArray.libIdx];
    badLibRefBlks = refBlks(badLibIdx);
    refBlksPrts = strcat(badLibRefBlks, ':', ...
        num2str(cell2mat(cell_buses_as_vectors_portNums(badLibIdx))));
    for iBadLib = 1:length(refBlksPrts)
        
        % Get the list of reference blocks pointed at by this particular
        % library.                       
        msgStr = DAStudio.message('Simulink:utility:slAddBusToVectorErrorInsertingBlockMsg', ...
            refBlksPrts{iBadLib});
        
        for i=1:size(badLibArray(iBadLib).libRefs, 1)
            msgStr = [msgStr sprintf('%s\n', badLibArray(iBadLib).libRefs{i})]; %#ok<AGROW>
        end

        warning('Simulink:utility:slAddBusToVectorErrorInsertingBlock', ...
            '\n%s', msgStr);
    end
end

% Eliminate un-processable blocks from the lists and re-generate the
% processing vars:
buses_as_vectors(badLibIdx)=[];
refBlks(badLibIdx)=[];
cell_buses_as_vectors_portNums(badLibIdx)=[];
unique_buses_as_vectors(badLibIdx)=[];
nFound = length(buses_as_vectors);
if(nFound>0)
% Since the library block may have been used multiple times,
% create a unique list of destination blocks.
% Index of Dst blocks that are in a model (excludes references)
DstBlksInMdlIdx = strmatch('',refBlks,'exact');
if(includeLibs)
        [uniqueBlks, uniqueBlksIdx] = unique(strcat(refBlks, ':', num2str(cell2mat(cell_buses_as_vectors_portNums))));
    allUniqueBlksIdx = union(DstBlksInMdlIdx, uniqueBlksIdx);
    uniqueBlksIdx = allUniqueBlksIdx; % Include libs
    for refBlkIdx = 1:length(refBlks)
        if ~isempty(refBlks{refBlkIdx})
            buses_as_vectors(refBlkIdx).LibPath = refBlks{refBlkIdx};
            unique_buses_as_vectors(refBlkIdx).BlockPath = refBlks{refBlkIdx};
        end
    end
else
    uniqueBlksIdx = DstBlksInMdlIdx;  % Exclude libs
end
unique_buses_as_vectors = unique_buses_as_vectors(uniqueBlksIdx);
end

disp(['### ' DAStudio.message('Simulink:utility:slAddBusToVectorReportModifiedNumbers', nFound)]);
% disp(['### ' DAStudio.message('Simulink:utility:slAddBusToVectorReportModifiedUniqueNumbers', length(uniqueBlksIdx))]);

%endfunction


% Function: insert_BusToVector_block_l =====================================
% Abstract:
%    Insert a Bus to Vector block in front of block/port
%    identified in block_info
%
function hB2VBlk = insert_BusToVector_block_l(block_info)

% Get pertinent information.
DstBlock = block_info.BlockPath;
DstPortIdx = block_info.InputPort;

BlockParent = get_param(DstBlock, 'Parent');

hDstBlock = get_param(DstBlock, 'handle');
DstBlockOrient = get_param(hDstBlock, 'Orientation');

DstPortLineHandles = get_param(hDstBlock, 'LineHandles');
DstPortLineH = DstPortLineHandles.Inport(DstPortIdx);
LinePoints = get_param(DstPortLineH, 'Points');

% Apply heuristics for location of inserted block
Girth = 20; MinGirth = 14; Separation = 14;
switch(lower(DstBlockOrient))
    case 'left'
        LastSegmentLen = abs(LinePoints(end, 1)- LinePoints(end-1, 1));
        Girth = max(MinGirth, min(Girth, LastSegmentLen - 2*Separation));
        x1 = LinePoints(end, 1)+ Separation;
        y1 = max(0,  LinePoints(end, 2) - Girth/2);
    case 'right'
        LastSegmentLen = abs(LinePoints(end, 1)- LinePoints(end-1, 1));
        Girth = max(MinGirth, min(Girth, LastSegmentLen - 2*Separation));
        x1 = max(0,  LinePoints(end, 1)-Girth-Separation);
        y1 = max(0,  LinePoints(end, 2)-Girth/2);        
    case 'up'
        LastSegmentLen = abs(LinePoints(end, 2)- LinePoints(end-1,2));
        Girth = max(MinGirth, min(Girth, LastSegmentLen - 2*Separation));
        x1 = max(0,  LinePoints(end, 1)-Girth/2);
        y1 =  LinePoints(end, 2) + Separation;                
    case 'down'
        LastSegmentLen = abs(LinePoints(end, 2)- LinePoints(end-1,2));
        Girth = max(MinGirth, min(Girth, LastSegmentLen - 2*Separation));
        x1 = max(0, LinePoints(end, 1)-Girth/2);
        y1 = max(0, LinePoints(end, 2)- Separation-Girth);        
end

pos = [x1 y1 x1+Girth y1+Girth];        
% Add the block, copying the decoration from the dst block
decorations = get_decoration_params_l(hDstBlock);

hB2VBlk = add_block('built-in/BusToVector', ...
    [BlockParent '/Bus to Vector'], 'MakeNameUnique', 'on', 'Position', ...
    pos, decorations{:});

% Now reconnect the segments:
% First replace the original line with a new one connecting to the b2v
% block instead of the dst Block
hSrcBlk  = get_param(DstPortLineH, 'SrcBlockHandle');
hSrcPrt  = get_param(DstPortLineH, 'SrcPortHandle');
strSrc = sprintf('%s/%d', get_param(hSrcBlk, 'Name'), get_param(hSrcPrt, 'PortNumber'));
strDst = sprintf('%s/%d', get_param(hB2VBlk, 'Name'),1);
hNewB2VInportLine = add_line(BlockParent, strSrc, strDst, 'autorouting','on'); %#ok<NASGU>
delete_line(DstPortLineH);

% Now add a new line connecting the b2v block to the dst block
strSrc = sprintf('%s/%d', get_param(hB2VBlk, 'Name'), 1);
strDst = sprintf('%s/%d', get_param(hDstBlock, 'Name'), DstPortIdx);
hNewDstInportLineHandle = add_line(BlockParent, strSrc, strDst, 'autorouting','on');     %#ok<NASGU>
%endfunction insert_BusToVector_block_l

% Function: get_decoration_params_l ===========================================
% Abstract:
%    Return a cell array containing the parameter/value pairs for a block's
%    decorations (i.e. FontSize, FontWeight, Orientation, etc.)
%    (Copied from slupdate)
function decorations = get_decoration_params_l(block)
decorations = {
    'Orientation',     [];
    'ForegroundColor', [];
    'BackgroundColor', [];
    'DropShadow',      [];
    'NamePlacement',   [];
    'FontName',        [];
    'FontSize',        [];
    'FontWeight',      [];
    'FontAngle',       [];
    'ShowName',        []
    };

num = size(decorations,1);
for i=1:num,
    decorations{i,2}=get_param(block,decorations{i,1});
end
decorations=reshape(decorations',1,length(decorations(:)));

% end get_decoration_params_l

function display_insert_warning_l(insertErrors)

msg = DAStudio.message('Simulink:utility:slAddBusToVectorErrorInsertingBlock');
for idx = 1:length(insertErrors)
    msg = [msg DAStudio.message('Simulink:utility:slAddBusToVectorErrorInsertingBlockDescription', ...
        insertErrors(idx).OrigBlockPath, insertErrors(idx).Inport, insertErrors(idx).Error.message)]; %#ok<AGROW>
end
warning('Simulink:utility:slAddBusToVectorErrorInsertingBlock', msg);
% end display_insert_warning_l


function buses_as_vectors = filter_blocks_l(buses_as_vectors)

blocks  = {buses_as_vectors.BlockPath};
isSelectorMask = strcmp('Selector', get_param(blocks, 'BlockType'));
isMixedAttrib = logical([buses_as_vectors.MixedAttributes]');

if any(isSelectorMask)

    msg=[];
    bkIdx = find(isSelectorMask);
    for i=1:length(bkIdx)
        msg = [msg sprintf('%s\n', blocks{bkIdx(i)})];%#ok<AGROW> 
    end   
    
    DAStudio.warning('Simulink:utility:slAddBusToVectorIgnoringSelector',  msg);
end

% Mixed attributes should be found only in Selector and Demux blocks.
% Separate the Debux blocks and show warnings
isMixedAttrib(isSelectorMask)=false;
if any(isMixedAttrib)
  
    msg = [];    
    bkIdx = find(isMixedAttrib);
    for i=1:length(bkIdx)
        msg = [msg sprintf('%s\n', blocks{bkIdx(i)})];%#ok<AGROW> 
    end   
    
    DAStudio.warning('Simulink:utility:slAddBusToVectorIgnoringDemux', msg);
end

buses_as_vectors(isSelectorMask | isMixedAttrib) = [];
buses_as_vectors = rmfield(buses_as_vectors, 'MixedAttributes');

% end filter_blocks_l


% Function: get_top_level_block_l ===========================================
% Abstract:
%    Find the top-level block having an unsupported bus as input.
%    If the input to this block is connected to an inport, then refer to
%    the parent block as the block to which the bus is connected. Repeat
%    this until either a block diagram is found, or the input to the block
%    is not an inport.
function buses_as_vectors = get_top_level_block_l(buses_as_vectors)

for iBlockPort = 1:numel(buses_as_vectors)
    % Get pertinent information.
    hDstBlock = get_param(buses_as_vectors(iBlockPort).BlockPath, 'Handle');
    DstPortIdx = buses_as_vectors(iBlockPort).InputPort;
    
    [hTopBlock, TopPortIdx] = get_top_block_and_port_l(hDstBlock, DstPortIdx);
    
    buses_as_vectors(iBlockPort).BlockPath = getfullname(hTopBlock);
    buses_as_vectors(iBlockPort).InputPort = TopPortIdx;
end
% end of get_top_level_block_l


function [hTopBlock, TopPortIdx] = get_top_block_and_port_l(hTopBlock, TopPortIdx)
          
DstPortLineHandles = get_param(hTopBlock, 'LineHandles');

if(~isempty( DstPortLineHandles.Inport) && DstPortLineHandles.Inport(TopPortIdx) ~= -1)
    hTopPortLine = DstPortLineHandles.Inport(TopPortIdx);

    hSrcBlock = get_param(hTopPortLine, 'SrcBlockHandle');

    if(~isempty(hSrcBlock) && strcmpi(get_param(hSrcBlock, 'BlockType'), 'Inport'))
        Parent = get_param(hSrcBlock, 'Parent');
        if(~strcmpi(get_param(Parent, 'type'), 'block_diagram'))
            hParent = get_param(Parent, 'Handle');
            [hTopBlock, TopPortIdx] = get_top_block_and_port_l(hParent, str2double(get_param(hSrcBlock, 'Port')));
        end
    end
end

% end get_top_block_and_port_l

