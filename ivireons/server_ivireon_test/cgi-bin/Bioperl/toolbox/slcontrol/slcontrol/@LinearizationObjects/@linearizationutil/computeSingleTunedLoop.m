function [tunedloop,op_out] = computeSingleTunedLoop(this,mdl,op,loopio,TunedBlocks,loopdata,opt) 
% COMPUTESINGLETUNEDLOOP  Compute a tuned loop given a loop location.
%
 
% Author(s): John W. Glass 17-Aug-2005
%   Copyright 2005-2010 The MathWorks, Inc.
% $Revision: 1.1.8.17.2.1 $ $Date: 2010/07/26 15:40:22 $

% Create the model parameter manager
ModelParameterMgr = linearize.ModelLinearizationParamMgr.getInstance(mdl);
ModelParameterMgr.loadModels;

% Put the TunedZPK object data in struct form
for ct = numel(TunedBlocks):-1:1
    BlockSubs(ct) = struct('Name',TunedBlocks(ct).Name,...
                           'Replacement',1,...
                           'InportPort',TunedBlocks(ct).AuxData.InportPort,...
                           'OutportPort',TunedBlocks(ct).AuxData.OutportPort);
end

% Compute any virtual blocks that need linearization points
UniqueIOSet = [loopio.FeedbackLoop];
AllIOs = utFindJacobianMultIOs(this,[UniqueIOSet;loopio.LoopOpenings(:)]);
LinData = struct('UniqueIOSet',UniqueIOSet,...
    'AllIOs',AllIOs,'opt',opt,'BlockSubs',BlockSubs,'RepBlockFactors',[]);
iospec = linearize.createIOSpecStructure(AllIOs);

if isa(op,'double')
    % Get the snapshot times and create the snapshot object
    evt = LinearizationObjects.ComputeTunedLoopSnapShotEvent(ModelParameterMgr,op);
    evt.linopts = opt;
    evt.loopio = loopio;
    evt.LinData = LinData;
	evt.TunedBlocks = TunedBlocks;
    evt.IOSpec = iospec;

    % Run the snapshot
    try
        Data = evt.runsnapshot;
        % Find the snapshot that is nearest to the snapshot time
        t = get([Data.OperatingPoint],{'Time'});
        [~,ind] = min([t{:}]-op);
        tunedloop = Data(ind).tunedloop;
        op_out = Data(ind).OperatingPoint;
    catch SimSnapshotError
        throwAsCaller(SimSnapshotError);
    end
else
    % Parameter settings we need to set/cache before linearizing
    if numel(op.Inputs)
        useModelu = false;
    else
        useModelu = true;
    end
    [ConfigSetParameters,ModelParams] = createLinearizationParams(this,false,useModelu,AllIOs,op.Time,opt);
    ModelParams.SimulationMode = 'normal';
    ModelParams.SCDLinearizationBlocksToRemove = get(TunedBlocks,{'Name'});
    ModelParameterMgr.LinearizationIO = AllIOs;
    ModelParameterMgr.ModelParameters = ModelParams;
    ModelParameterMgr.ConfigSetParameters = ConfigSetParameters;
    ModelParameterMgr.prepareModels('linearization');
    
    % Now compile the model
    ModelParameterMgr.compile('lincompile');

    % Now push the operating point onto the model
    try
        utPushOperatingPoint(linutil,mdl,op,linoptions)
    catch PushOperatingPointError
        % Terminate the compilation of the model
        ModelParameterMgr.term;
        ModelParameterMgr.restoreModels;
        ModelParameterMgr.closeModels;
        throwAsCaller(PushOperatingPointError)
    end

    % Get the Jacobian to find the blocks in the linearization
    J = getJacobian(linutil,mdl,iospec);

    % Find the compensator factors
    try
        tunedloop = utComputeLoop(this,ModelParameterMgr,loopio,J,TunedBlocks,LinData);
    catch LoopComputationError
        % Terminate the compilation of the model
        ModelParameterMgr.term;
        ModelParameterMgr.restoreModels;
        ModelParameterMgr.closeModels;
        throwAsCaller(LoopComputationError)
    end

    % Terminate the compilation of the model
    ModelParameterMgr.term;
    
    % Restore the block diagram settings
    ModelParameterMgr.restoreModels;
    ModelParameterMgr.closeModels;
    op_out = op;
end

% Find the number of open loops
looptype = get(loopdata.L,{'Feedback'});
nOL = sum([looptype{:}]);
tunedloop.Identifier = sprintf('L%d',nOL+1);
tunedloop.Name = loopio.Name;
tunedloop.Description = loopio.Description;
