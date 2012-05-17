function [Jmod,lft_tuneblks] = utComputeLFT_IO(this,topmdl,J,TunedBlocks,blockaccountflag)
% UTCOMPUTELFT_IO  Compute the LFT of a system given a set of blocks to
% pull out.
%
 
% Author(s): John W. Glass 20-Jul-2005
% Copyright 2005-2007 The MathWorks, Inc.
% $Revision: 1.1.8.11 $ $Date: 2008/10/31 07:34:49 $

% Perform block reduction
Jreduced = minjacobian_secondpass(linutil,J);

% Extract the upper parts of the LFT
a = Jreduced.A; b = Jreduced.B; c = Jreduced.C; d = Jreduced.D;

% Extract the lower parts of the lft
E = Jreduced.Mi.E;
F = Jreduced.Mi.F;
G = Jreduced.Mi.G;
H = Jreduced.Mi.H;

% Extract the block I/O info
InputInfo = Jreduced.Mi.InputInfo;
BlockInputs = InputInfo(:,1);
BlockInputChannels = InputInfo(:,2);
OutputInfo = Jreduced.Mi.OutputInfo;
BlockOutputs = OutputInfo(:,1);
BlockOutputChannels = OutputInfo(:,2);

% Get the state names
stateBlockPath = Jreduced.stateBlockPath;
stateBlockPathNoMdlRef = stateBlockPath;
for ct = 1:numel(stateBlockPath)
    stateBlockPathNoMdlRef{ct} = getBlockPath(slcontrol.Utilities,stateBlockPath{ct});
end

% Get the model sample rates and block dimensions
Tsx = Jreduced.Tsx;
Tsy = Jreduced.Tsy;

% Find all the normal mode model reference blocks
[mdlrefs,mdlblks] = find_mdlrefs(topmdl);
normalmdlblks = mdlblks(strcmp(get_param(mdlblks,'SimulationMode'),'Normal'));

% Loop over each of the tunable blocks to determine if they are in the
% feedback loop.  Then remove the blocks from the LFT.
lft_tuneblks = {};
keep_input_ind = [];
keep_output_ind = [];
delete_input_ind = [];
delete_output_ind = [];
delete_state_ind = [];
for ct = 1:length(TunedBlocks)
    % Get the block name
    blk = TunedBlocks(ct).Name;
    
    % Determine if the block is a subsystem or bus supported zoh/memory
    blocktype = get_param(blk,'BlockType');
    issubsystem = strcmp(blocktype,'SubSystem');
    isvirtual = strcmp(get_param(blk,'Virtual'),'on');
    issupported_busexpand = isvirtual && (strcmp(blocktype,'ZeroOrderHold') ||...
        strcmp(blocktype,'Memory'));    
    
    if issubsystem || issupported_busexpand
        if isfield(TunedBlocks(ct),'AuxData')
            % Get the block input port
            ssblk_inport = TunedBlocks(ct).AuxData.InportPort;
            % Get the block output port
            ssblk_outport = TunedBlocks(ct).AuxData.OutportPort;
        else
            % Set the block input/output port 
            ssblk_inport = 1;
            ssblk_outport = 1;
        end
        
        % First get the actual source of the subsystem
        ph = get_param(blk,'PortHandles');
        port_h = get_param(ph.Inport(ssblk_inport),'Object');
        ssblk_as = getActualSrcMdlRef(linutil,port_h,topmdl,normalmdlblks);
        % Get the destinations of the source port.
        dst_p = getActualDstMdlRef(linutil,get_param(ssblk_as(1),'object'),...
                                            topmdl,normalmdlblks);
        % Find the destinations that are inside the subsystem
        dst_p_parents = get_param(dst_p(:,1),'Parent');
        if size(dst_p,1) == 1
            dst_p_parents = {dst_p_parents};
        end            
        dstb = regexprep(dst_p_parents,'\n',' ');
       
        % If there are destinations inside the subsystem then the block is in
        % the linearization
        dstb_h = get_param(dstb,'Handle');
        dstb_h = [dstb_h{:}];
        
        for ct2 = numel(dstb):-1:1
            % Get the model name
            mdl = bdroot(dstb{ct2});
            % Get the block parent then walk up the hierarchy to
            % determine if the block is child of the tuned block
            blkparent = regexprep(get_param(dstb{ct2},'Parent'),'\n',' ');
            while ~strcmp(blkparent,blk) && ~strcmp(blkparent,mdl)
                blkparent = regexprep(get_param(blkparent,'Parent'),'\n',' ');
            end
                
            % If the model root is found then it is not a child
            if strcmp(blkparent,mdl) || ~any(dstb_h(ct2) == BlockOutputs(:,1))
                dstb(ct2) = [];
                dstb_h(ct2) = [];
                dst_p(ct2,:) = [];
            end
        end        
        
        if ~isempty(intersect(dstb_h,Jreduced.Mi.BlockHandles))
            % Store this block as a block in the lft
            lft_tuneblks{end+1} = blk;
            
            % Get the IO for the destinations to remove them from the
            % list.
            subsys_dst_input_ind = [];
            subsys_dst_output_ind = [];
            for ct2 = 1:length(dstb)                
                dst_input_ind = find(dstb_h(ct2) == BlockInputs);
                subsys_dst_input_ind = [subsys_dst_input_ind;dst_input_ind];
                dst_output_ind = find(dstb_h(ct2) == BlockOutputs);
                subsys_dst_output_ind = [subsys_dst_output_ind;dst_output_ind];
            end
            
            % Pick a valid destination to keep track of the signal source
            % index.  This will be used later when re-wiring the IO.
            index = getBlockIOIndex(linutil,dst_p(1,:));
            dst_input_ind = find(dstb_h(1) == BlockInputs);
            channel_index = (index == BlockInputChannels(dst_input_ind));
            keep_input_ind = [keep_input_ind;dst_input_ind(channel_index)];

            % Get the output port for the subsystem used in the control
            % design
            outports = find_system(blk,'LookUnderMasks','all','SearchDepth',1,...
                                'FollowLinks','on','BlockType','Outport');
            outport = outports(ssblk_outport);
            
            % Get the actual src to the output of the subsystem
            outport_h = get_param(outport,'Object');
            act_src = outport_h{1}.getActualSrc;
            srcb = get_param(act_src(1),'Parent');
            srcb_h = get_param(srcb,'Handle');
            src_output_ind = find(srcb_h == BlockOutputs);
            src_input_ind = find(srcb_h == BlockInputs);
            
            if ~any(srcb_h==dstb_h)
                subsys_dst_input_ind = [subsys_dst_input_ind;src_input_ind];
                subsys_dst_output_ind = [subsys_dst_output_ind;src_output_ind];
            end
            
            % Keep track of the signal source index.  This will be used 
            % later when re-wiring the IO.
            index = getBlockIOIndex(linutil,act_src);
            src_output_ind = find(srcb_h == BlockOutputs);
            channel_index = (index == BlockOutputChannels(src_output_ind));
            keep_output_ind = [keep_output_ind;src_output_ind(channel_index)];
            
            % Find the states that need to be deleted
            state_ind = [];
            ssblks = find_system(blk,'LookUnderMasks','all','FollowLinks','on');
            for ct2 = 1:numel(ssblks)
                ind = find(strcmp(ssblks{ct2},stateBlockPath));
                if ~isempty(ind)
                    state_ind = [state_ind;ind];
                end
            end
                            
            delete_input_ind = [delete_input_ind;subsys_dst_input_ind];
            delete_output_ind = [delete_output_ind;subsys_dst_output_ind];
            delete_state_ind = [delete_state_ind;state_ind];
        end
    else
        tune_blk_h = get_param(blk,'Handle');
        out_ind = find(tune_blk_h == BlockOutputs);
        in_ind = find(tune_blk_h == BlockInputs);
        if ~isempty(in_ind) && ~isempty(out_ind)
            lft_tuneblks{end+1} = blk;
            keep_input_ind = [keep_input_ind;in_ind];
            keep_output_ind = [keep_output_ind;out_ind];
            delete_input_ind = [delete_input_ind;in_ind];
            delete_output_ind = [delete_output_ind;out_ind];
            delete_state_ind = [delete_state_ind;find(strcmp(blk,stateBlockPathNoMdlRef))];
        end
    end
end    

% Remove the tunable blocks
if ~isempty(lft_tuneblks)
    a(:,delete_state_ind) = []; a(delete_state_ind,:) = [];
    b(delete_state_ind,:) = []; b(:,delete_input_ind) = [];
    c(:,delete_state_ind) = []; c(delete_output_ind,:) = [];
    d(:,delete_input_ind) = []; d(delete_output_ind,:) = [];
    % Re-order E,F,G matrices so that the tunable element IO is moved to
    % be last
    Etmp = E(keep_input_ind,:); E(delete_input_ind,:) = []; E = [E;Etmp];
    Etmp = E(:,keep_output_ind); E(:,delete_output_ind) = []; E = [E,Etmp];
    Ftmp = F(keep_input_ind,:); F(delete_input_ind,:) = []; F = [F;Ftmp];
    Gtmp = G(:,keep_output_ind); G(:,delete_output_ind) = []; G = [G,Gtmp];
    % Block Input Info    
    BlockInputs(delete_input_ind) = [];
    BlockInputChannels(delete_input_ind) = [];
    % Block Output Info
    BlockOutputs(delete_output_ind) = [];
    BlockOutputChannels(delete_output_ind) = [];
    % State Info
    stateBlockPath(delete_state_ind) = [];
    % Sample Time Info    
    Tsy(delete_output_ind) = [];
    if ~isempty(delete_state_ind)
        Tsx(delete_state_ind) = [];
    end
end

% Now cut apart the E matrix into pieces for F,G,H
[nbin,nbout] = size(E);

% Find the number of channels 
nblk_channel = numel(keep_input_ind);
Fnew = E(1:(nbin-nblk_channel),(nbout-nblk_channel+1):nbout);
Gnew = E((nbin-nblk_channel+1):nbin,1:(nbout-nblk_channel));
Hnew_E = E((nbin-nblk_channel+1):nbin,(nbout-nblk_channel+1):nbout);
Hnew_F = F((nbin-nblk_channel+1):nbin,:);
Hnew_G = G(:,(nbout-nblk_channel+1):nbout);
E = E(1:(nbin-nblk_channel),1:(nbout-nblk_channel));
F = [Fnew,F(1:(nbin-nblk_channel),:)];
G = [Gnew;G(:,1:(nbout-nblk_channel))];
H = [Hnew_E,Hnew_F;...
     Hnew_G,H];
 
% Now check for blocks that are not part of the closed loop lft and add
%  the appropriate IO.  Remember that the LFT has the compensators in the
%  bottom.
%         ------------  
%   In -->|  Upper   |---> Out
%      ---|  LFT     |<--
%      |  ------------  |
%      |  ------        |
%      |->| C3 |--------|
%      |  ------        |
%      |     ------     |
%      |---->| C2 |---->|
%      |     ------     |
%      |        ------  |
%      |------->| C1 |->|  
%               ------  
if blockaccountflag
    nc = numel(TunedBlocks);
    for ct = 1:nc
        blk = TunedBlocks(ct).Name;
        if ~any(strcmp(blk,lft_tuneblks))
            binputind = ct;
            boutputind = ct;
            % Add a column to the F and H matrices
            F = [F(:,1:binputind-1),zeros(size(F,1),1),F(:,binputind:end)];
            H = [H(:,1:binputind-1),zeros(size(H,1),1),H(:,binputind:end)];
            % Add a row to the G and H matrices
            G = [G(1:boutputind-1,:);zeros(1,size(G,2));G(boutputind:end,:)];
            H = [H(1:boutputind-1,:);zeros(1,size(H,2));H(boutputind:end,:)];
        end
    end
    % The tuned blocks are all the blocks
    if isa(TunedBlocks,'struct')
        lft_tuneblks = {TunedBlocks.Name};
    else
        lft_tuneblks = get(TunedBlocks,{'Name'});
    end
end

% Reconstruct the Jacobian data
Jmod = Jreduced;
Jmod.A = a; Jmod.B = b; Jmod.C=c; Jmod.D=d;
Jmod.Tsx = Tsx; Jmod.Tsy = Tsy; Jmod.stateBlockPath = stateBlockPath;
Jmod.Mi.E = E; Jmod.Mi.F = F; Jmod.Mi.G = G; Jmod.Mi.H = H;
Jmod.Mi.InputInfo = [BlockInputs,BlockInputChannels]; 
Jmod.Mi.OutputInfo = [BlockOutputs,BlockOutputChannels];

