function [sys,stateNames,iostruct,J_iter] = utProcessJacobian(this,ModelParameterMgr,J_iter,LinData,iostructfcn)
% UTPROCESSJACOBIAN
 
% Author(s): John W. Glass 19-Aug-2008
%   Copyright 2008-2009 The MathWorks, Inc.
% $Revision: 1.1.8.5.4.1 $ $Date: 2010/07/26 15:40:29 $

model = ModelParameterMgr.Model;

% Get the IO data structure
iostruct = iostructfcn(J_iter);

% Find the blocks with linearization specifications
ExternalSpecifiedBlockSubs = {LinData.BlockSubs.Name};
ExternalSpecifiedBlockSubsh = get_param(ExternalSpecifiedBlockSubs,'Handle');
ExternalSpecifiedBlockSubsh = [ExternalSpecifiedBlockSubsh{:}];
nrep = numel(J_iter.Mi.BlockRemovalData);
% FoldBlock flag determines if a block is folded during the call to utComputeBlockFactors
Replacements = struct('Name',cell(nrep,1),...
                        'Value',[],'FoldBlock',[]);
for ct = 1:nrep
    blk = J_iter.Mi.BlockRemovalData(ct).Block;
    if any(blk == ExternalSpecifiedBlockSubsh)
        SpecStruct = LinData.BlockSubs(blk == ExternalSpecifiedBlockSubsh).Value;
        % For cases where the block linearization is specified externally use the FoldFactor flag.  This
        % flag indicates that LINLFT is being called.
        FoldBlock = LinData.FoldFactors;
    else
        SpecStruct = get_param(blk,'SCDBlockLinearizationSpecification');
        % Always fold in a block linearization that is specified on a block
        FoldBlock = true;
    end
    % Sort the blocks at the input and outputs in the case of bus expansion
    if numel(J_iter.Mi.BlockRemovalData(ct).InputHandles) > 1
        [~,ind] = sort(getfullname(J_iter.Mi.BlockRemovalData(ct).InputHandles));
        J_iter.Mi.BlockRemovalData(ct).InputHandles = J_iter.Mi.BlockRemovalData(ct).InputHandles(ind);
    end
    if numel(J_iter.Mi.BlockRemovalData(ct).OutputHandles) > 1
        [~,ind] = sort(getfullname(J_iter.Mi.BlockRemovalData(ct).OutputHandles));
        J_iter.Mi.BlockRemovalData(ct).OutputHandles = J_iter.Mi.BlockRemovalData(ct).OutputHandles(ind);
    end
    Replacements(ct) = utEvaluateSpecification(linutil,blk,J_iter.Mi.BlockRemovalData(ct),SpecStruct,FoldBlock);
end

% Store the replacement data to be used in the linearization inspector
J_iter.Mi.Replacements = Replacements;

% Find the delay blocks that may need to be replaced
if strcmp(LinData.opt.UseExactDelayModel,'on')
    [Replacements,DelayBlockRemovalData] = findDelayBlockLinearizations(this,J_iter,Replacements);
    J_iter.Mi.BlockRemovalData = [J_iter.Mi.BlockRemovalData;DelayBlockRemovalData];
end

if strcmp(LinData.opt.BlockReduction,'on')
    % Perform a first pass block reduction
    J_fp = minjacobian_firstpass(linutil,J_iter);
    
    % Perform the second pass block reduction
    Jlft = minjacobian_secondpass(linutil,J_fp);
else
    if ~isempty(LinData.BlockSubs)
        ctrlMsgUtils.error('Slcontrol:linearize:BlockReductionOnBlockReplacement')
    end
    Jlft = J_iter;
end

% Compute the sample time of the linearization
Ts = utComputeLinearizationTs(this,Jlft.Tsx,Jlft.Tsy,LinData.opt.SampleTime);

if ~isempty(Replacements)
    if strcmp(LinData.opt.BlockReduction,'off')
        ctrlMsgUtils.error('Slcontrol:linearize:BlockReductionOnBlockReplacement')
    end
    
    % Remove replacements that are not connected to any blocks
    for ct = numel(Replacements):-1:1
        PortConnectivity = get_param(Replacements(ct).Name,'PortConnectivity');
        isnotconnected = true;
        for ct_pc = 1:numel(PortConnectivity)
            isnotconnected = isnotconnected && (~(~isempty(PortConnectivity(ct_pc).SrcPort) ||...
                ~isempty(PortConnectivity(ct_pc).DstPort)));
        end
        if isnotconnected
            Replacements(ct) = [];
            J_iter.Mi.BlockRemovalData(ct) = [];
        end
    end
    
    % Factor the block replacements into groupings that can be folded into the
    % lft and that can remain.
    BlockFactors = utComputeBlockFactors(linutil,Ts,Replacements);
    
    % Compute the LFT Data with the blocks factored out
    [J_refactor,BlockFactors] = utComputeUpperLFT(linutil,J_iter,BlockFactors,LinData.FoldFactors);
    
    % Perform a first pass block reduction
    J_fp = minjacobian_firstpass(linutil,J_refactor);
    
    % Perform the second pass block reduction
    Jlft = minjacobian_secondpass(linutil,J_fp);
end

% Compute the sample time of the linearization
Ts = utComputeLinearizationTs(this,Jlft.Tsx,Jlft.Tsy,LinData.opt.SampleTime);

% Compute the upper lft with respect to the factorized blocks
[upper_lft,stateNames] = jacobian2ss(linutil,model,Jlft,LinData.opt,Ts);

if strcmp(LinData.opt.BlockReduction,'on')
    % Store the blocks that were in the path after the block reduction
    for ct = numel(J_iter.Mi.BlocksInPath):-1:1
        BlocksInPath(ct) = any(J_iter.Mi.BlockHandles(ct) == Jlft.Mi.BlockHandles);
    end
    % Store the reduced blocks in path
    J_iter.Mi.BlocksInPath = BlocksInPath;
end

% Fold in the block factors
if ~isempty(Replacements)
    if LinData.FoldFactors
        % Fold in all of the blocks since LINLFT is not being called
        BlockFoldFactors = BlockFactors;
        BlockNoFoldFactors = [];
    else
        % Only fold the externally specified blocks
        BlockFoldFactors = BlockFactors(numel(ExternalSpecifiedBlockSubs)+1:end);
        BlockNoFoldFactors = BlockFactors(1:numel(ExternalSpecifiedBlockSubs));
    end
    if ~isempty(BlockFoldFactors)
        [sys,stateNames] = utFoldBlockFactors(this,upper_lft,BlockFoldFactors,LinData.opt,stateNames);
    else
        sys = upper_lft;
    end
else
    sys = upper_lft;
end

if ~LinData.FoldFactors
    % Remove the block channels that have been folded in during the call to LINLFT
    nBlockIn = 0; nBlockOut = 0;
    BlockInputName = {};
    BlockOutputName = {};
    for ct = 1:numel(BlockNoFoldFactors)
        [nbin,nbout] = size(BlockNoFoldFactors(ct).Factor);
        nBlockIn = nBlockIn + nbin;
        BlockInputName = [BlockInputName,repmat({BlockNoFoldFactors(ct).Name},1,nbin)];
        nBlockOut = nBlockOut + nbout;
        BlockOutputName = [BlockOutputName,repmat({BlockNoFoldFactors(ct).Name},1,nbout)];
    end
    [nout,nin] = size(sys);
    iostruct.InputInd = [iostruct.InputInd,(nin-nBlockIn+1:nin)];
    iostruct.OutputInd = [iostruct.OutputInd,(nout-nBlockOut+1:nout)];
    iostruct.InputName = [iostruct.InputName,BlockInputName];
    iostruct.OutputName = [iostruct.OutputName,BlockOutputName];
end

% Order the IOs and set the names
warnoff = ctrlMsgUtils.SuspendWarnings;
sys = sys(iostruct.OutputInd,iostruct.InputInd);
set(sys,'InputName',iostruct.InputName,'OutputName',iostruct.OutputName);
delete(warnoff);
