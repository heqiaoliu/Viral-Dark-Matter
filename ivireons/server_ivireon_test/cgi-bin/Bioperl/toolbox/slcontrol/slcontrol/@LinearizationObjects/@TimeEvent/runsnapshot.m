function Data = runsnapshot(this)
% RUNSNAPSHOT  Method to gather snapshots

%  Author(s): John Glass
%   Copyright 2004-2010 The MathWorks, Inc.
% $Revision: 1.1.8.8.2.1 $ $Date: 2010/07/06 14:42:20 $

% Get the singleton storage object
model = this.ModelParameterMgr.Model;
snapshot_storage = LinearizationObjects.TimeEventStorage;

% Call the init function
initdata = initmodel(this);

% Store the time event object
snapshot_storage.TimeEventObj = this;

% Clear the old operating conditions and linearizations
snapshot_storage.Data = [];

% Store the snapshot times
snapshottimes = this.SnapShotTimes;

% Find start time of the simulation to compare against snapshot times.
Tstart = slResolve(get_param(model,'StartTime'),model);

if any(isinf(this.SnapShotTimes)) || any(this.SnapShotTimes < Tstart) || ...
    any(~isreal(this.SnapShotTimes)) || any(isnan(this.SnapShotTimes)) || ...
    any(this.SnapShotTimes < 0)
    % Call the clean up
    cleanupmodel(this,initdata);
    ctrlMsgUtils.error('Slcontrol:linutil:InvalidSnapshotTimes'); 
end

% Handle the case where a user specifies t = 0.  Don't need to
% simulate to get this answer.
if (any(this.SnapshotTimes == 0))
    Data = getzerotimedata(this);
    this.SnapShotTimes(this.SnapShotTimes == 0) = [];
else
    Data = [];
end



% Get the final time
Tfinal = max(this.SnapShotTimes);

if Tfinal > 0
    % Add the max step size to the snapshot time to ensure that the last
    % snapshot event occurs.
    ConfigSet = getActiveConfigSet(model);
    MaxStepSizestr = ConfigSet.Components(1).MaxStep;
    try
        MaxStepSize = eval(MaxStepSizestr);
    catch Ex %#ok<NASGU>
        MaxStepSize = Tfinal/50;
    end

    Tfinal = Tfinal + MaxStepSize;
    try
        % Load the slctrlextras model to copy blocks
        load_system('slctrlextras')

        % Add the linearization block to the model
        this.addblock('opsnapshot');

        % Run the simulation.  Do not need to simulate past
        % the final specified time.  Use the base workspace to write
        % variables and simulate.  This will be consistent with all
        % linearization functions that require the model parameters be
        % defined in the base workspace.
        S = simset('DstWorkspace','base');
        this.ModelParameterMgr.sim([Tstart Tfinal],S);

        % Get the resulting data
        Data = [Data;snapshot_storage.Data];

        % Sort the snapshot times to reorder in the user specified order.
        % If there are more operating points then snapshot times this
        % means that the user has the triggered based block.  In this case
        % there really isn't much we can do to return the order that the
        % user has specified.
        if length(Data) == length(snapshottimes)
            [~,ix] = sort(snapshottimes);
            [~,ixx] = sort(ix);
        else
            ixx = 1:length(Data);
        end
        
        % Sort the data
        Data = Data(ixx);
                
        % Remove the linearization block from the model
        delete_block(this.SimulinkSnapshotBlock);
        
        % Clean up
        snapshot_storage.Data = [];

        % Close the slctrlextras model to copy blocks
        close_system('slctrlextras')
    catch SnapshotException
        % Remove the linearization block from the model
        delete_block(this.SimulinkSnapshotBlock);

        % Close the slctrlextras model to copy blocks
        close_system('slctrlextras')

        % Call the clean up
        cleanupmodel(this,initdata);

        % Remove the time event object
        snapshot_storage.TimeEventObj = [];
        % Throw the last error
        throwAsCaller(SnapshotException);
    end
end

% Call the clean up
cleanupmodel(this,initdata);

% Remove the time event object
snapshot_storage.TimeEventObj = [];
end
