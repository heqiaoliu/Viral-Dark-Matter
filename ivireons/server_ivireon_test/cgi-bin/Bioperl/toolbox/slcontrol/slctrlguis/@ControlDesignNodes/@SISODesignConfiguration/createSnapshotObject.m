function snapshot = createSnapshotObject(this)
% CREATESNAPSHOTOBJECT  Create a snapshot object for simulation snapshots
%
 
% Author(s): John W. Glass 11-Sep-2006
% Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2010/04/30 00:43:57 $

% Get the snapshot times and create the snapshot object
% Create the model parameter manager
ModelParameterMgr = linearize.ModelLinearizationParamMgr.getInstance(this.getModel);
ModelParameterMgr.loadModels;
snapshot = LinearizationObjects.ComputeLoopSnapShotEvent(ModelParameterMgr,1);
snapshot.linopts = getLinearizationOptions(this);

% Loop over the loops to create the io needed for linearization
Loops = this.sisodb.LoopData.L;
for ct = 1:numel(Loops);
    Loop = Loops(ct);
    if Loop.Feedback
        FeedbackLoops = linio(Loop.LoopConfig.OpenLoop.BlockName,...
                              Loop.LoopConfig.OpenLoop.PortNumber,...
                              'outin','on');
        LoopOpenings = handle(NaN(0,1));
        for ct2 = 1:numel(Loop.LoopConfig.LoopOpenings)            
            if Loop.LoopConfig.LoopOpenings(ct2).Status
                OpenLoopStatus = 'on';
            else
                OpenLoopStatus = 'off';
            end
               
            LoopOpenings(ct2) = linio(Loop.LoopConfig.LoopOpenings(ct2).BlockName,...
                                      Loop.LoopConfig.LoopOpenings(ct2).PortNumber,...
                                      'outin');
            LoopOpenings(ct2).Active = OpenLoopStatus;                      
        end
        LoopIO(ct) = struct('FeedbackLoop', FeedbackLoops,...
                            'LoopOpenings', LoopOpenings,...
                            'Name', Loop.Name,...
                            'Description', Loop.Description);
    end
end

% Compute any virtual blocks that need linearization points
TunedBlocks = this.sisodb.LoopData.C;
BlockIO = findVirtualTunedBlockSources(linutil,TunedBlocks);

% Now that we have the IOs, compute the Jacobian for all combinations.
ClosedLoopIO = this.ClosedLoopIO;
fbLoopIO = [LoopIO.FeedbackLoop];
allios = [fbLoopIO(:);ClosedLoopIO(:);BlockIO(:);LoopOpenings(:)];
IOUnique = utFindJacobianMultIOs(linutil,allios);
IOSettings = struct('ClosedLoopIO',ClosedLoopIO,...
                        'BlockIO',BlockIO,'LoopIO',LoopIO,'IOUnique',IOUnique);
snapshot.IOSettings = IOSettings;
snapshot.TunedBlocks = TunedBlocks;

%Close any loaded models
ModelParameterMgr.closeModels