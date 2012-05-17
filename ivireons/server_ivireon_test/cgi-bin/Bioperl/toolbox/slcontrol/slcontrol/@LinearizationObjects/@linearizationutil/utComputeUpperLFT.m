function [Jmod, BlockFactors] = utComputeUpperLFT(~,Jfull,BlockFactors,varargin)
% UTCOMPUTELFT_IO  Compute the LFT of a system given a set of blocks to
% pull out.
%
% Remember that the LFT has the compensators in the
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

% Author(s): John W. Glass 20-Jul-2005
%   Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.5.4.1 $ $Date: 2010/07/26 15:40:26 $

% Determine if we need to check the dimensions of the linearization
% factors.  This is needed if we actually need to fold in the linearization
% specifications.
if nargin == 3
    FoldFactors = true;
else
    FoldFactors = varargin{1};
end

InputBlks = Jfull.Mi.InputInfo(:,1);
InputInfo = Jfull.Mi.InputInfo;
OutputBlks = Jfull.Mi.OutputInfo(:,1);
InternalOutputBlks = OutputBlks;
OutputInfo = Jfull.Mi.OutputInfo;
OutputDelay = zeros(size(OutputBlks));
stateName = Jfull.stateName;
stateBlockPath = Jfull.stateBlockPath;
BlockHandles = Jfull.Mi.BlockHandles;
ForwardMark = Jfull.Mi.ForwardMark;
BackwardMark = Jfull.Mi.BackwardMark;
InputPorts = Jfull.Mi.InputPorts;

A = Jfull.A;B = Jfull.B;C = Jfull.C;D = Jfull.D;
E = Jfull.Mi.E;F = Jfull.Mi.F;G = Jfull.Mi.G;H = Jfull.Mi.H;
Tsy = Jfull.Tsy;Tsx = Jfull.Tsx;

for blk_ct = 1:numel(BlockFactors)
    blk = BlockFactors(blk_ct).Name;
    
    % Find the blocks that represent the block being replaced
    Erows = [];Ecols = [];
    block = BlockFactors(blk_ct).Name;
    blk_h = get_param(block,'Handle');
    InputHandles = Jfull.Mi.BlockRemovalData(blk_ct).InputHandles;
    % Get a unique list of input handles in the original sorted order
    [~,m,~] = unique(InputHandles,'first');
    uInputHandles = InputHandles(sort(m));
    for input_ct = 1:numel(uInputHandles)
        Erows = [Erows;find(uInputHandles(input_ct) == InputBlks)];
    end
    
    OutputHandles = Jfull.Mi.BlockRemovalData(blk_ct).OutputHandles;
    % Get a unique list of output handles in the original sorted order
    [~,m,~] = unique(OutputHandles,'first');
    uOutputHandles = OutputHandles(sort(m));
    for output_ct = 1:numel(uOutputHandles)
        Ecols = [Ecols;find(uOutputHandles(output_ct) == OutputBlks)];
    end
    
    % Concat the block data
    if ~BlockFactors(blk_ct).FoldBlock
        ni = numel(Erows);no = numel(Ecols);
        BlockFactors(blk_ct).InputFixed = eye(ni,ni);
        BlockFactors(blk_ct).OutputFixed = eye(no,no);
        BlockFactors(blk_ct).Factor = zeros(no,ni);
    end

    InputFixed = BlockFactors(blk_ct).InputFixed;
    OutputFixed = BlockFactors(blk_ct).OutputFixed;
    isfactor = ~isempty(BlockFactors(blk_ct).Factor);
    
    if isa(InputFixed,'double') || isa(OutputFixed,'double')
        Di = InputFixed;Do = OutputFixed;
        if ~issparse(Di)
            Di = sparse(Di);
            Do = sparse(Do);
        end
        TsInput = 0;
        NewOutputDelay = zeros(size(Di,1)+size(Do,1),1);
        B = blkdiag(B,sparse(0,size(Di,2)),sparse(0,size(Do,2)));
        C = blkdiag(C,sparse(size(Di,1),0),sparse(size(Do,1),0));
    else
        [Ai,Bi,Ci,Di,TsInput] = ssdata(InputFixed);
        [Ao,Bo,Co,Do] = ssdata(OutputFixed);
        A = blkdiag(A,sparse(Ai),sparse(Ao));
        B = blkdiag(B,sparse(Bi),sparse(Bo));
        C = blkdiag(C,sparse(Ci),sparse(Co));
        Di = sparse(Di); Do = sparse(Do);
        nxInput = size(Ai,1); nxOutput = size(Ao,1);
        Tsx = [Tsx;TsInput*ones(nxInput+nxOutput,1)];
        stateName = [stateName;[InputFixed.StateName;OutputFixed.StateName]];
        stateBlockPath = [stateBlockPath;repmat({BlockFactors(blk_ct).Name},nxInput+nxOutput,1)];
        NewOutputDelay = [InputFixed.OutputDelay;OutputFixed.OutputDelay];
    end
    D = blkdiag(D,Di,Do);
    [niy,niu] = size(Di); [noy,nou] = size(Do);

    NewInternalOutputBlks = blk_h*[zeros(niy,1);ones(noy,1)];
    
    % Add the substitutions
    BlockHandles(end+1) = blk_h;
    ForwardMark(end+1) = true;
    BackwardMark(end+1) = true;
    
    if (numel(Erows) ~= niu || (numel(Ecols) ~= noy)) && FoldFactors
        nrows = size(OutputFixed,1);ncols = size(InputFixed,2);
        errin = {blk,nrows,ncols,numel(Erows),numel(Ecols)};
        if (Jfull.Mi.BlockRemovalData(blk_ct).nInputs == 0) && ...
                (Jfull.Mi.BlockRemovalData(blk_ct).nOutputs == 0)
            ctrlMsgUtils.error('Slcontrol:linearize:ReplacedBlockNotConnected',block)
        else
            ctrlMsgUtils.error('Slcontrol:linearize:BlockSubDimAreIncorrect',errin{:})
        end
    end
    
    % Adjust the interconnection terms
    Etmp = E(Erows,:); E(Erows,:) = 0; InputBlks(Erows) = 0;
    E = [E;Etmp;sparse(nou,size(E,2))];
    Ftmp = F(Erows,:); F(Erows,:) = 0;
    F = [F;Ftmp;sparse(nou,size(F,2))];
    Etmp = E(:,Ecols); E(:,Ecols) = 0; OutputBlks(Ecols) = 0;InternalOutputBlks(Ecols) = 0;
    E = [E,[sparse(size(E,1)-nou,niy);~isfactor*speye(nou,niy)],Etmp];
    Gtmp = G(:,Ecols); G(:,Ecols) = 0;
    G = [G,sparse(size(G,1),niy),Gtmp];
    
    % Zero out connections to the old blocks.  The block reduction will
    % remove everything in between.
    D(:,Erows) = 0;B(:,Erows) = 0;
    D(Ecols,:) = 0;C(Ecols,:) = 0;
    
    % Add IO Channels for block factors
    if isfactor
        [ny_tmp,nu_tmp] = size(E);
        F = [F,[sparse(ny_tmp-nou,nou);speye(nou,nou)]];
        ph = get_param(blk,'PortHandles');
        for ct_outports = 1:numel(ph.Outport)
            portwidth = prod(get_param(ph.Outport(ct_outports),'CompiledPortWidth'));
            InputPorts = [InputPorts;ph.Outport(ct_outports)*ones(portwidth,1)];
        end
        G = [G;[sparse(niy,nu_tmp-niy-noy),speye(niy,niy),sparse(niy,noy)]];
        [nz,nw] = size(H);
        H = [H,sparse(nz,nou)];
        H = [H;sparse(niy,nw+nou)];
    end
    
    OutputDelay = [OutputDelay;NewOutputDelay];
    NewInputBlks = blk_h*[ones(niu,1);ones(nou,1)];
    InputBlks = [InputBlks;NewInputBlks];
    InputInfo = [InputInfo;[NewInputBlks,(1:(numel(NewInputBlks)))']];
    NewOutputBlks = blk_h*[ones(niy,1);ones(noy,1)];
    InternalOutputBlks = [InternalOutputBlks;NewInternalOutputBlks];
    OutputBlks = [OutputBlks;NewOutputBlks];
    OutputInfo = [OutputInfo;[NewOutputBlks,(1:(numel(NewOutputBlks)))']];
    Tsy = [Tsy;TsInput*ones(niy+noy,1);];
end

Jmod = Jfull;
Jmod.A = A; Jmod.B = B; Jmod.C = C; Jmod.D = D;Jmod.Tsy = Tsy;Jmod.Tsx = Tsx;
Jmod.Mi.E = E; Jmod.Mi.F = F; Jmod.Mi.G = G; Jmod.Mi.H = H;
Jmod.Mi.InputInfo = InputInfo;Jmod.Mi.OutputInfo = OutputInfo;
Jmod.Mi.OutputDelay = OutputDelay;
Jmod.stateName = stateName;
Jmod.stateBlockPath = stateBlockPath;
Jmod.Mi.BlockHandles = BlockHandles;
Jmod.Mi.ForwardMark = ForwardMark;
Jmod.Mi.BackwardMark = BackwardMark;
