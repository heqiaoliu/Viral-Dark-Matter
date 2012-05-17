function TunedLoop = utComputeLoop(this,ModelParameterMgr,LoopIO,Jfull,TunedBlocks,LinData)
% FINDLOOPFACTORS Compute the tuned loop for a
%
%   [TUNEDLOOP] = UTCOMPUTELOOP(MDL,LOOPIO,J,TUNEBLKS) a feedback loop
%   in a Simulink model, MDL, with a single linearization LOOPIO.  The final
%   variable is a handle array of TunedBlocks.
%
%   John W. Glass
%   Copyright 2005-2010 The MathWorks, Inc.
%	$Revision: 1.1.8.14.2.1 $  $Date: 2010/06/24 19:45:24 $

mdl = ModelParameterMgr.Model;
% Get the handle to the feedback loop io
fbLoopIO = LoopIO.FeedbackLoop;
fbLoopIO_port = fbLoopIO.PortNumber;
nCompensators = numel(TunedBlocks);

% Get the handles to any of the loop openings that are currently active
loopopenio = [];
LoopOpenings = LoopIO.LoopOpenings;
BlockSubs = LinData.BlockSubs;
for ct = 1:length(LoopOpenings)
    if strcmp(LoopOpenings(ct).Active,'on')
        loopopenio = [loopopenio,LoopIO.LoopOpenings(ct)];
    end
end

% Factorize the blocks
BlockFactors = utFactorizeTunedBlocks(this,TunedBlocks,Jfull.Mi.BlockRemovalData);
BlockFactors = [BlockFactors(:);LinData.RepBlockFactors];

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  DEPTH FIRST SEARCH ROUTINE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Get the list of blocks to be transversed
% Perform a first pass block reduction
J_fp = minjacobian_firstpass(linutil,Jfull);
Jloop = utSetJacobianIO(this,J_fp,[fbLoopIO,loopopenio]);

% Set the direct feedthrough of each tuned block to be 1 so that they are
% not removed.
if isempty(LinData.RepBlockFactors)
    subblks = get(TunedBlocks,{'Name'});
else
    tuneblks = get(TunedBlocks(:),{'Name'});
    repblks = {LinData.RepBlockFactors.Name};
    subblks = [tuneblks;repblks(:)];
end

for ct = 1:numel(subblks)
    if strcmp(get_param(subblks{ct},'BlockType'),'SubSystem')
        blks = find_system(subblks{ct},'LookUnderMasks','all','FollowLinks','on');
    else
        blks = subblks(ct);
    end
    
    for dt = 1:numel(blks)
        b_handle = get_param(blks{dt},'Handle');
        input_ind = Jloop.Mi.InputInfo(:,1) == b_handle;
        output_ind = Jloop.Mi.OutputInfo(:,1) == b_handle;
        Jloop.D(output_ind,input_ind) = 1;
    end
end

% Compute a second pass at minjacobian here
Jreduced = minjacobian_secondpass(linutil,Jloop);

if isempty(Jreduced.Mi.E)
    % If the block is not in a the linearization it is not in a
    % feedback loop.
    ctrlMsgUtils.error('Slcontrol:controldesign:SignalNotInFeedbackLoop',fbLoopIO.Block,fbLoopIO.PortNumber)
end

% Start with the controller input and get the first set of paths
% First get the block handle
blk = get_param(fbLoopIO.Block,'Handle');

% Find the signal conversion block if the linearization point is on a
% virtual block
if ~any(find(blk==Jreduced.Mi.BlockHandles))
    % The signal conversion block is the block connected to the non-zero G
    % term
    blk = Jreduced.Mi.OutputInfo(find(Jreduced.Mi.G),1); %#ok<FNDSB>
    % Since this block is a signal conversion block, the port for the IO
    % needs to be changed to 1
    fbLoopIO_port = 1;
end
blocks = Jreduced.Mi.BlockHandles;

% Get the list of outport handles
ph_cell = get_param(blocks,'PortHandles');
ph_struct_array = [ph_cell{:}];
ports = [ph_struct_array.Outport];

% Get the handle to the first output port
blk_obj = get_param(blk,'Object');
phs = blk_obj.PortHandles;
loop_ph = phs.Outport(fbLoopIO_port);

% Start the depth first search using the bi-directional algorithm to find
% the articulation points.
[art_ports,~,dis_ports,~,low_blocks] = ...
    utDFSfactorization(this,ModelParameterMgr,loop_ph,ports,blocks,loopopenio);

% The pointnodes are the articulation points of the port nodes
factornodes = unique(art_ports);

% Get the order of discovery to order the pointnodes
order = zeros(size(factornodes));
for ct = 1:length(factornodes)
    order(ct) = dis_ports(factornodes(ct) == ports);
end
[art_discovery,ix] = sort(order);
factornodes = factornodes(ix);

% Tack the start node to the beginning of the pointnodes
factornodes = [loop_ph,factornodes,loop_ph];
art_discovery = [-1,art_discovery,inf];

% Get the list of blocks that are being tuned in a cell array
tuneblks = {BlockSubs.Name};
if isempty(LinData.RepBlockFactors)
    specifiedblks = {};
else
    specifiedblks = {LinData.RepBlockFactors.Name};
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Remove factorization points that are inside

% Find the tunable blocks that are subsystems
blkfactors = {BlockFactors.Name};
inv_blks_ind = find(strcmp(get_param(blkfactors,'BlockType'),'SubSystem'));

% Now eliminate extraneous internal factorization points inside masked
% subsystems being tuned or replaced.
for ct = length(inv_blks_ind):-1:1
    blk = blkfactors(inv_blks_ind(ct));
    % Find the ports below the subsystem
    ssports = find_system(blk,'LookUnderMasks','on',...
        'FollowLinks','on','FindAll','on','type','port');
    [~,ind] = intersect(factornodes,ssports);
    factornodes(ind) = [];
    art_discovery(ind) = [];
end

% Now eliminate points with output ports of dimension > 1
for ct = length(factornodes):-1:1
    pw = get_param(factornodes(ct),'CompiledPortWidth');
    if pw > 1
        factornodes(ct) = [];
        art_discovery(ct) = [];
    end
end

% Now find the locations of the blocks inside each of the pointnodes.  In
% this case a block is between two articulation points if
% disc(artpt1) <= low(block) <= disc(artpt2)
tunedblock_low = [];

% Find the low for each of the tunable blocks
for ct = length(tuneblks):-1:1
    block = get_param(tuneblks{ct},'Handle');
    block_low = low_blocks(block == blocks);
    if isempty(block_low)
        % If this is a subsystem find a block inside of it to determine its
        % nearest articulation points
        blks = find_system(tuneblks{ct},'LookUnderMasks','on','FollowLinks','on');
        for ct2 = 1:length(blks)
            block_low = low_blocks(get_param(blks{ct2},'Handle') == blocks);
            if ~isempty(block_low)
                break
            end
        end
    end
    if ~isempty(block_low)
        tunedblock_low(ct) = block_low;
    end
end

% Now loop over the pointnodes to determine if there is a block between
% consecutive nodes.
pointnodes = factornodes(1);
currentsource = art_discovery(1);

for ct = 2:(length(factornodes)-1)
    if any(tunedblock_low < art_discovery(ct)) && any(tunedblock_low >= currentsource)
        if currentsource ~= art_discovery(ct-1)
            pointnodes(end+1) = factornodes(ct-1);
        end
        pointnodes(end+1) = factornodes(ct);
        currentsource = art_discovery(ct);
    end
end

% Check to see if there is a block between the last articulation point and
% the end of the loop
if any(tunedblock_low >= art_discovery(end-1)) && (pointnodes(end) ~= factornodes(end-1))
    pointnodes(end+1) = factornodes(end-1);
end
% Add the last factorization point since we need to account from the last
%  tunedblock to the end of the loop
pointnodes(end+1) = factornodes(end);

% Create the TunedLoop object
TunedLoop = sisodata.TunedLoop;
TunedLoop.Feedback = 1;
TunedFactors = handle(zeros(0,1));
TunedLFT = struct('lower_lft',cell(0,1),'tune_elements',cell(0,1),...
    'inpoint',[],'outpoint',[]);
% Initialize the fixed terms
FixedTerms = ss([],[],[],1);

% Initialize the list of TunedBlocks that are in the interconnection lft
LFTTunedBlocks = handle(zeros(0,1));

% Compute the Jacobian for the given set of ios defining the loop.
Jfull = utSetJacobianIO(this,Jfull,loopopenio);

% Compute the path to each block input and output since this will be used
% multiple times;
BlockInputNames = getfullname(Jfull.Mi.InputInfo(:,1));
BlockOutputNames = getfullname(Jfull.Mi.OutputInfo(:,1));

% Now compute the LFT that are in each segment
for ct = 2:length(pointnodes)
    isTunedSeriesBlock = false;
    isSpecifiedBlock = false;
    for br_ct = 1:numel(Jfull.Mi.BlockRemovalData)
        ph_in = LocalFlattenOutportPortList(get_param(Jfull.Mi.BlockRemovalData(br_ct).InputHandles,'PortHandles'));
        ph_out = LocalFlattenOutportPortList(get_param(Jfull.Mi.BlockRemovalData(br_ct).OutputHandles,'PortHandles'));
        if any(pointnodes(ct-1) == ph_in) && any(pointnodes(ct) == ph_out)
            tune_names = regexprep(getfullname(Jfull.Mi.BlockRemovalData(br_ct).Block),'\n',' ');
            if any(strcmp(tune_names,tuneblks))
                isTunedSeriesBlock = true;
            elseif any(strcmp(tune_names,specifiedblks))
                isSpecifiedBlock = true;
            end            
            break;
        end
    end
    
    if isTunedSeriesBlock
        % Find the TunedBlock that is in series connection
        TunedFactors(end+1) = TunedBlocks(strcmp(tune_names,tuneblks));
    elseif isSpecifiedBlock
        RepBlockFactor = LinData.RepBlockFactors(strcmp(tune_names,specifiedblks));
        if isempty(RepBlockFactor.Factor)
            RepBlockLin = RepBlockFactor.OutputFixed*RepBlockFactor.InputFixed;
        else
            RepBlockLin = RepBlockFactor.OutputFixed*RepBlockFactor.Factor*RepBlockFactor.InputFixed;
        end
        if isa(RepBlockLin,'ss')
            RepBlockLin = utRateConversion(this,RepBlockLin,LinData.opt.SampleTime,LinData.opt);
        else
            RepBlockLin = full(RepBlockLin);
        end
        FixedTerms = FixedTerms*RepBlockLin;
    else
        % Add any IO channels not initially marked that are factorization
        % points
        Jloop = utLFTPnt2Pnt(this,ModelParameterMgr,Jfull,pointnodes(ct-1),...
                               pointnodes(ct),BlockInputNames,BlockOutputNames);
        
        % Compute the LFT Data.
        % If pointnodes(ct) is a block being removed remove it from block
        % factors since it will conflict with the point to point
        % calculation.
        BlockFactorsLoop = BlockFactors;
        TunedBlocksLoop = TunedBlocks;
        nCompensatorsLoop = nCompensators;
        RepBlockFactorsLoop = LinData.RepBlockFactors;
        tuneblksLoop = tuneblks;
        for br_ct = numel(Jloop.Mi.BlockRemovalData):-1:1
            ph_in = LocalFlattenOutportPortList(get_param(Jloop.Mi.BlockRemovalData(br_ct).InputHandles,'PortHandles'));
            if any(pointnodes(ct) == ph_in)
                blk = BlockFactorsLoop(br_ct).Name;
                BlockFactorsLoop(br_ct) = [];
                Jloop.Mi.BlockRemovalData(br_ct) = [];
                ind_comp = strcmp(blk,tuneblksLoop);
                if any(ind_comp)
                    tuneblksLoop(ind_comp) = [];
                    TunedBlocksLoop(ind_comp) = [];
                    nCompensatorsLoop = nCompensatorsLoop - 1;
                end
                if ~isempty(LinData.RepBlockFactors)
                    ind_repfactors = strcmp(blk,{LinData.RepBlockFactors.Name});
                    if any(ind_repfactors)
                        RepBlockFactorsLoop(ind_repfactors) = [];
                    end
                end
                break;
            end
        end
        
        Jlft = utComputeUpperLFT(this,Jloop,BlockFactorsLoop);
        
        % Compute a second pass at minjacobian here
        Jlft = minjacobian_secondpass(linutil,Jlft);
        
        % Compute the state space model
        lower_lft = jacobian2ss(linutil,mdl,Jlft,LinData.opt,LinData.opt.SampleTime);
        
        % Compute the linearization with the user specified blocks folded.
        lower_lft = utFoldBlockFactors(linutil,lower_lft,RepBlockFactorsLoop,LinData.opt);
        
        % Convert uncertain linearizations to state space by selecting the
        % nominal value.
        if isa(lower_lft,'uss')
            lower_lft = lower_lft.NominalValue;
        end
        
        % Find the open loop output points that are at a block input.
        % These indicate that the block is not part of the lft and should
        % be removed.
        As = [lower_lft.A        lower_lft.B(:,2:end);...
            lower_lft.C(2:end,:) lower_lft.D(2:end,2:end)];
        
        Bs = [lower_lft.B(:,1);lower_lft.D(2:end,1)];
        Cs = [lower_lft.C(1,:),lower_lft.D(1,2:end)];
        [~,~,~,~,signalmask] = smreal(As,Bs,Cs,[]);
        notinloopflag = ~signalmask(end-nCompensatorsLoop+1:end);
        tune_names = tuneblksLoop(~notinloopflag);
        
        % Remove the blocks that are not part of the loop
        lower_lft(:,[false; notinloopflag]) = [];
        lower_lft([false; notinloopflag],:) = [];
        lower_lft = sminreal(lower_lft);
        
        % First case is where there are not any tuned blocks
        if isempty(tune_names)
            FixedTerms = FixedTerms*lower_lft(1,1);
        else
            lower_lft = lower_lft([2:end,1],[2:end,1]);
            % Get the TunedBlocks corresponding to this lft
            for ct2 = 1:length(tune_names)
                LFTTunedBlocks(end+1,1) = TunedBlocksLoop(strcmp(tune_names{ct2},tuneblksLoop));
            end
            % Store each of the components of the TunedLFT.  Concatinate later.
            TunedLFT(end+1,1) = struct('lower_lft',lower_lft,...
                'tune_elements',{tune_names},...
                'inpoint',pointnodes(ct-1),...
                'outpoint',pointnodes(ct));
        end
    end
end

% Compute the interconnection of each of the tuned terms
%       -------         ------
%       |C1   |      -->| C3 |----
%    -->|   C2|---   |  ------   |
%    |  -------  |   |           |
%    |  -------  |   |  -------  |  --------------
%    ---|Lower|<--   ---|Lower|<--  | Fixed Terms|
% In -->|LFT 1|-------->|LFT 2|---->|            |---> Out
%       -------         -------     --------------
%
% to be
%
%         ------------
%   In -->|  Lower   |---> Out
%      ---|  LFT     |<--
%      |  ------------  |
%      |                |
%      |  ------------  |
%      |  | C1       |  |
%      -->|    C2    |---
%         |       C3 |
%         ------------
%
if ~isempty(TunedLFT)
    % First append the elements in TunedLFT
    sys_append = TunedLFT(1).lower_lft;
    % The variables are:
    %   inter_ind - is an index into sys_append that represents the
    %               connections between sections.
    %   input_ind - the index into sys_append for the input signal
    inter_ind = zeros(length(TunedLFT)-1,1);
    inter_ind(1,:) = size(sys_append.d,1);
    for ct = 2:length(TunedLFT);
        sys_append = append(sys_append,TunedLFT(ct).lower_lft);
        inter_ind(ct) = size(sys_append.d,1);
    end
    
    % Now connect the systems together
    Q = [inter_ind(2:end),inter_ind(1:end-1)];
    % Connect the blocks
    sys_connect = connect(sys_append,Q);
    % Now find the IO points that we care about
    maybein = 1:size(sys_append.d,2);
    notin = inter_ind(1:end);
    in = [inter_ind(1),setdiff(maybein,notin)];
    maybeout = 1:size(sys_append.d,2);
    notout = inter_ind(1:end-1);
    out = setdiff(maybeout,notout);
    outend = out(end);
    out(end)=[];
    out = [outend,out];
    sys_connect_r = sys_connect(out,in);
    
    % Lastly connect the fixed terms
    ICsize = size(sys_connect_r);
    Dsize = eye(ICsize-1);
    aFixedTerms = append(FixedTerms,Dsize);
    IC = getPrivateData(sys_connect_r*aFixedTerms);
else
    IC = getPrivateData(FixedTerms);
end

% Populate the TuneLoop object
TunedLoop.setTunedLFT(IC,LFTTunedBlocks);
TunedLoop.TunedFactors = TunedFactors;
TunedLoop.Ts = LinData.opt.SampleTime;

% Store the stripped down list of blocks that are in the path
% Create an empty block list
BlockHandles = Jreduced.Mi.BlockHandles;
BlockNameList = cell(size(BlockHandles));

% Find the hidden buffers and remove carriage return
HiddenBuffers = [];
for ct = 1:length(BlockNameList)
    try
        BlockNameList{ct} = regexprep(getfullname(BlockHandles(ct)),'\n',' ');
    catch Ex
        HiddenBuffers = [HiddenBuffers;ct];
    end
end

% Remove references to hidden buffers
BlockNameList(HiddenBuffers) = [];
BlocksInPathByName = BlockNameList;

% Store the loop configuration data
OpenLoopStruct = struct('BlockName',fbLoopIO.Block,...
    'PortNumber',fbLoopIO.PortNumber);

TunedLoop.LoopConfig = struct('OpenLoop',OpenLoopStruct,...
    'LoopOpenings',[],...
    'BlocksInPathByName',{BlocksInPathByName});

if isempty(LoopOpenings) && ~isempty(LFTTunedBlocks)
    for ct = numel(LFTTunedBlocks):-1:1
        ind = strcmp(LFTTunedBlocks(ct).Name,tuneblks);
        LoopOpeningStruct(ct) = struct('BlockName',TunedBlocks(ind).Name,...
            'PortNumber',TunedBlocks(ind).AuxData.OutportPort,...
            'Status', false);
    end
    TunedLoop.LoopConfig.LoopOpenings = LoopOpeningStruct;
elseif ~isempty(LoopOpenings)
    for ct = numel(LoopOpenings):-1:1
        Status = strcmp(LoopOpenings(ct).Active,'on');
        LoopOpeningStruct(ct) = struct('BlockName',LoopOpenings(ct).Block,...
            'PortNumber',LoopOpenings(ct).PortNumber,...
            'Status', Status);
    end
    TunedLoop.LoopConfig.LoopOpenings = LoopOpeningStruct;
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ph = LocalFlattenOutportPortList(ph_struct)

if isa(ph_struct,'cell')
    ph = [];
    for port_ct = 1:numel(ph_struct)
        ph = [ph,ph_struct{port_ct}.Outport];
    end
else
    ph = ph_struct.Outport;
end
