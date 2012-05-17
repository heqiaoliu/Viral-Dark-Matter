function BlockFactors = utFactorizeTunedBlocks(~,TunedBlocks,BlockRemovalData) 
% UTFACTORIZETUNEDBLOCKS  Factorize tuned blocks into their fixed and
% tunable 'Factor' elements
 
% Author(s): John W. Glass 01-Oct-2008
%   Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.8.2.4.1 $ $Date: 2010/06/24 19:45:26 $

% Get the list of blocks marked as removed in the linearization engine.
RemovedBlocks = [BlockRemovalData.Block];

% Factorize the blocks
for ct = 1:numel(TunedBlocks)
    if strcmp(get_param(TunedBlocks(ct).Name,'BlockType'),'SubSystem')
        % Find the number of input and output channels
        indblk = get_param(TunedBlocks(ct).Name,'Handle') == RemovedBlocks;
        nInputChannels = BlockRemovalData(indblk).nInputs;
        nOutputChannels = BlockRemovalData(indblk).nOutputs;
        
        % Find the index for tuned block control input and output channels
        ph = get_param(TunedBlocks(ct).Name,'PortHandles');
        p = get_param(ph.Inport(TunedBlocks(ct).AuxData.InportPort),'Object');
        blkdst = get_param(p.getGraphicalSrc,'Parent');
        BlockTunedInputChannel = strcmp(blkdst,getfullname(BlockRemovalData(indblk).InputHandles));
        
        p = get_param(ph.Outport(TunedBlocks(ct).AuxData.OutportPort),'Object');
        blkdst = get_param(p.getGraphicalDst,'Parent');
        BlockTunedOutputChannel = strcmp(blkdst,getfullname(BlockRemovalData(indblk).OutputHandles));
    else
        nInputChannels = 1;
        nOutputChannels = 1;
        BlockTunedInputChannel = 1;
        BlockTunedOutputChannel = 1;
    end

    InputFixed = zeros(1,nInputChannels);
    InputFixed(BlockTunedInputChannel) = 1;
    OutputFixed = zeros(nOutputChannels,1);
    OutputFixed(BlockTunedOutputChannel) = 1;
    Factor = ss(1);Factor.Ts = TunedBlocks(ct).Ts;
    BlockFactors(ct) = struct('Name',TunedBlocks(ct).Name,...
                          'InputFixed',ss(InputFixed),'OutputFixed',ss(OutputFixed),...
                          'Factor',Factor,'FoldBlock',true);
end