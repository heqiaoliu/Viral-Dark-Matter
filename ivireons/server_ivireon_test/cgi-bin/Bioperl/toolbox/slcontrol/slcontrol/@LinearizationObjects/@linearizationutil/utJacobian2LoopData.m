function loopdata = utJacobian2LoopData(this,ModelParameterMgr,J,IOSettings,TunedBlocks,opt) 
% utJacobian2LoopData  Static method to create the loop data information
% from a model.  This assumes that the model has been compiled.
%
 
% Author(s): John W. Glass 18-Aug-2006
%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.8.5.2.1 $ $Date: 2010/06/24 19:45:27 $

mdl = ModelParameterMgr.Model;
LoopIO = IOSettings.LoopIO;

% Logic to get the proper names and dimensions for each IO.
truncatename = strcmp(opt.UseFullBlockNameLabels,'off');
useBus = strcmp(opt.UseBusSignalLabels,'on');

% Put the TunedZPK object data in struct form
for ct = numel(TunedBlocks):-1:1
    BlockSubs(ct) = struct('Name',TunedBlocks(ct).Name,...
                           'Replacement',1,...
                           'InportPort',TunedBlocks(ct).AuxData.InportPort,...
                           'OutportPort',TunedBlocks(ct).AuxData.OutportPort);
end

% Sort the Jacobian BlocksRemovalData to be in the order specified.  This
% is done to handle the ordering returned from model references.
JacobianBlockFactors = [J.Mi.BlockRemovalData.Block];
ind = 1:numel(JacobianBlockFactors);
for ct = 1:numel(TunedBlocks)
    ind(ct) = find(get_param(TunedBlocks(ct).Name,'Handle') == JacobianBlockFactors);
end
J.Mi.BlockRemovalData(ind) = J.Mi.BlockRemovalData;

% Factorize the blocks
BlockFactors = utFactorizeTunedBlocks(this,TunedBlocks,J.Mi.BlockRemovalData);

% Find the tuned block names
ExternalSpecifiedBlockSubs = get(TunedBlocks,{'Name'});
ExternalSpecifiedBlockSubsh = get_param(ExternalSpecifiedBlockSubs,'Handle');
ExternalSpecifiedBlockSubsh = [ExternalSpecifiedBlockSubsh{:}];
nrep = numel(J.Mi.BlockRemovalData)-numel(ExternalSpecifiedBlockSubs);
Replacements = struct('Name',cell(nrep,1),...
                            'Value',[],'FoldBlock',[]);
ct_blockrep = 1;
for ct = 1:numel(J.Mi.BlockRemovalData)
    blk = J.Mi.BlockRemovalData(ct).Block;
    FoldBlock = true;
    if ~any(blk == ExternalSpecifiedBlockSubsh)
        SpecStruct = get_param(blk,'SCDBlockLinearizationSpecification');
        Replacements(ct_blockrep) = utEvaluateSpecification(this,blk,J.Mi.BlockRemovalData(ct),SpecStruct,FoldBlock);
        ct_blockrep = ct_blockrep + 1;
    end    
end

% Find the delay blocks that may need to be replaced
if strcmp(opt.UseExactDelayModel,'on')
    [Replacements,DelayBlockRemovalData] = findDelayBlockLinearizations(this,J,Replacements);
    J.Mi.BlockRemovalData = [J.Mi.BlockRemovalData;DelayBlockRemovalData];
end

if ~isempty(Replacements)
    RepBlockFactors = utComputeBlockFactors(linutil,opt.SampleTime,Replacements);
else
    RepBlockFactors = [];
end

% Find the tuned loops
tunedloop = handle(zeros(0,1));

for ct = 1:length(LoopIO)
    try
        UniqueIOSet = [IOSettings.LoopIO(ct).FeedbackLoop];
        AllIOs = utFindJacobianMultIOs(this,[UniqueIOSet();IOSettings.LoopIO(ct).LoopOpenings(:)]);
        LinData = struct('UniqueIOSet',UniqueIOSet,...
                            'AllIOs',AllIOs,'opt',opt,'BlockSubs',BlockSubs,...
                            'RepBlockFactors',RepBlockFactors);
        tunedloop(end+1,1) = utComputeLoop(this,ModelParameterMgr,LoopIO(ct),J,TunedBlocks,LinData);
        cnt = numel(tunedloop);
        tunedloop(end).Identifier = sprintf('L%d',cnt);
        tunedloop(end).Name = sprintf('Open Loop %d',cnt);
        tunedloop(end).Description = LoopIO(ct).Description;
    catch ComputeLoopException
        % Ignore the error if this signal is not part of a feedback loop
        if ~strcmp(ComputeLoopException.identifier,'Slcontrol:controldesign:SignalNotInFeedbackLoop')
            throwAsCaller(ComputeLoopException)
        end
    end
end

% Compute the plantdata for the closed loop lft
ClosedLoopIO = IOSettings.ClosedLoopIO;
UniqueIOSet = ClosedLoopIO(:);

% Compute the state space model
J = utSetJacobianIO(this,J,ClosedLoopIO);
Jplantdata = utComputeUpperLFT(this,J,[BlockFactors(:);RepBlockFactors(:)]);

% Compute a second pass at minjacobian here
Jplantdata = minjacobian_secondpass(linutil,Jplantdata);
plantdata = jacobian2ss(linutil,mdl,Jplantdata,opt,opt.SampleTime);

% Compute the linearization with the user specified blocks folded.
plantdata = utFoldBlockFactors(linutil,plantdata,RepBlockFactors,opt);
        
if isa(plantdata,'uss')
    plantdata = plantdata.NominalValue;
end

% Compute the iostruct
inports = J.Mi.InputPorts;
outports = J.Mi.OutputPorts;
inname = J.Mi.InputName;
outname = J.Mi.OutputName;
iostruct = getioindices(linutil,ModelParameterMgr,ClosedLoopIO,inports,...
            outports,inname,outname,'iopoints',truncatename,useBus,UniqueIOSet);

% Order the IO channels        
[nout,nin] = size(plantdata);
plantdata = plantdata([iostruct.OutputInd,(numel(iostruct.OutputInd)+1):nout],...
                        [iostruct.InputInd,(numel(iostruct.InputInd)+1):nin]);

% Populate the plant data
Plant = sisodata.LumpedPlant;
P = getPrivateData(plantdata);
Plant.setP(P);
Plant.nLoop = numel(TunedBlocks);

% Create the loopdata object
loopdata = sisodata.loopdata;

% Set a unique name
loopdata.Name = sprintf('%s - %s',mdl,datestr(now));

% Populate the data
loopdata.Plant = Plant;
loopdata.Input = iostruct.InputName;
loopdata.Output = iostruct.OutputName;
loopdata.C = TunedBlocks;
loopdata.addLoop(tunedloop(:));
loopdata.Ts = opt.SampleTime;
