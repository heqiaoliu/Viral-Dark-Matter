function configPID(currentblock)
% CONFIGPID  Initialization utility for the PID 1dof block.

%   Author: Murad Abu-Khalaf
%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $ $Date: 2010/01/25 22:57:51 $

blk = getfullname(currentblock);
blkH = handle(currentblock);

%% Do not run initialization if the dialog has unapplied changes.
% This protects against preapply changes in the block properties even with
% Mode=False.
hDialog = blkH.getDialogSource.getOpenDialogs;
if ~isempty(hDialog) && hDialog{1}.hasUnappliedChanges
    return;
end

% Get Simulation Status Info.
simStatus   = get_param(bdroot(blk), 'SimulationStatus');
isRunning   = strcmp(simStatus, 'running') || strcmp(simStatus, 'paused');

%% Building the Subsystem
try
    isCurrent = pidpack.PIDConfig.isBlockDiagramCurrent(currentblock);
    if ~isRunning
        if ~isCurrent
            % Building the Controller
            pidpack.PIDConfig.addPorts(currentblock);
            addController(currentblock);
            pidpack.PIDConfig.addSatWindupTracking(currentblock);
        end
        pidpack.PIDConfig.setParam(currentblock);
    else
        % DO NOTHING:
        % - Cannot modify Subsystem while running
        % - Cannot change dialog parameters of under mask blocks. (Non tunable)
    end
catch E
    disp(E.message);
end


%% Icon related for the most part
try
    iconstr = pidpack.PIDConfig.getMaskDisplayString(currentblock);
    if ~strcmp(blkH.MaskDisplay,iconstr)
        blkH.MaskDisplay = iconstr;
    end
catch E
    disp(E.message);
end

end

% PID Form and Structure (Only set_param position, i/o size, and Name)
function addController(currentblock)
blkH = handle(currentblock);

% Clear Susbsytem
pidpack.PIDConfig.clearSubsystem(currentblock);

if strcmp(blkH.Controller,'PID')
    createPID(currentblock);
elseif strcmp(blkH.Controller,'PI')
    createPI(currentblock);
elseif strcmp(blkH.Controller,'PD')
    createPD(currentblock);
elseif strcmp(blkH.Controller,'P')
    createP(currentblock);
elseif strcmp(blkH.Controller,'I')
    createI(currentblock);
end

% Connect Integrators to RESET and I0 and D0 ports
pidpack.PIDConfig.connectIntegrators(currentblock);

end

% Create PID (Only set_param position, i/o size, and Name)
function createPID(currentblock)
blkH = handle(currentblock);
blk = getfullname(currentblock);

posI =           [105   110   135   140];
posIntegratorI = [315    93   390   157];
posSum =         [415   115   435   135];
posD =           [105   215   135   245];
posSumD =        [235   220   255   240];
posN =           [335   215   365   245];
posIntegratorD = [315   268   390   332];

if strcmp(blkH.Form,'Parallel')
    posP = [105    20   135    50];
else % Ideal
    posP = [465   110   495   140];
end

% Add required blocks with the right orientation, position, number of
% ports.
if strcmp(blkH.TimeDomain,'Discrete-time')
    integrator = 'built-in/DiscreteIntegrator';
else
    integrator = 'built-in/Integrator';
end
add_block('built-in/Sum',[blk '/Sum'],...
    'Position',posSum,'IconShape', 'round','Inputs', '+++');
add_block('built-in/Gain',[blk '/Proportional Gain'],'Position',posP);
add_block('built-in/Gain',[blk '/Integral Gain'],'Position',posI);
add_block('built-in/Gain',[blk '/Derivative Gain'],'Position',posD);
add_block(integrator,[blk '/Integrator'],...
    'Position',posIntegratorI,'ExternalReset',blkH.ExternalReset,...
    'InitialConditionSource',blkH.InitialConditionSource);
add_block(integrator,[blk '/Filter'],...
    'Position',posIntegratorD,'Orientation','left',...
    'ExternalReset',blkH.ExternalReset,...
    'InitialConditionSource',blkH.InitialConditionSource);
add_block('built-in/Gain',[blk '/Filter Coefficient'],'Position',posN);
add_block('built-in/Sum',[blk '/SumD'],...
    'Position',posSumD,'IconShape', 'round','Inputs', '|+-');

% Connect added blocks
add_line(blk,'u/1','Integral Gain/1','autorouting','on');
add_line(blk,'u/1','Derivative Gain/1','autorouting','on');
add_line(blk,'Integral Gain/1','Integrator/1','autorouting','on');
add_line(blk,'Derivative Gain/1','SumD/1','autorouting','on');
add_line(blk,'SumD/1','Filter Coefficient/1','autorouting','on');
add_line(blk,'Filter Coefficient/1','Filter/1','autorouting','on');
add_line(blk,'Filter/1','SumD/2','autorouting','on');
add_line(blk,'Integrator/1','Sum/2','autorouting','on');
add_line(blk,'Filter Coefficient/1','Sum/3','autorouting','on');
if strcmp(blkH.form,'Parallel')
    add_line(blk,'u/1','Proportional Gain/1','autorouting','on');
    add_line(blk,'Proportional Gain/1','Sum/1','autorouting','on');
    add_line(blk,'Sum/1','y/1','autorouting','on');
else % Ideal
    add_line(blk,'u/1','Sum/1','autorouting','on');
    add_line(blk,'Sum/1','Proportional Gain/1','autorouting','on');
    add_line(blk,'Proportional Gain/1','y/1','autorouting','on');
end

end

% Create PI (Only set_param position, i/o size, and Name)
function createPI(currentblock)
blkH = handle(currentblock);
blk = getfullname(currentblock);

posI =           [105   110   135   140];
posIntegratorI = [315    93   390   157];
posSum =         [415   115   435   135];

if strcmp(blkH.Form,'Parallel')
    posP = [105    20   135    50];
else % Ideal
    posP = [465   110   495   140];
end

% Add required blocks with the right orientation, position, number of
% ports.
if strcmp(blkH.TimeDomain,'Discrete-time')
    integrator = 'built-in/DiscreteIntegrator';
else
    integrator = 'built-in/Integrator';
end
add_block('built-in/Sum',[blk '/Sum'],...
    'Position',posSum,'IconShape', 'round','Inputs', '++|');
add_block('built-in/Gain',[blk '/Proportional Gain'],'Position',posP);
add_block('built-in/Gain',[blk '/Integral Gain'],'Position',posI);
add_block(integrator,[blk '/Integrator'],...
    'Position',posIntegratorI,'ExternalReset',blkH.ExternalReset,...
    'InitialConditionSource',blkH.InitialConditionSource);

% Connect added blocks
add_line(blk,'u/1','Integral Gain/1','autorouting','on');
add_line(blk,'Integral Gain/1','Integrator/1','autorouting','on');
add_line(blk,'Integrator/1','Sum/2','autorouting','on');
if strcmp(blkH.Form,'Parallel')
    add_line(blk,'u/1','Proportional Gain/1','autorouting','on');
    add_line(blk,'Proportional Gain/1','Sum/1','autorouting','on');
    add_line(blk,'Sum/1','y/1','autorouting','on');
else % Ideal
    add_line(blk,'u/1','Sum/1','autorouting','on');
    add_line(blk,'Sum/1','Proportional Gain/1','autorouting','on');
    add_line(blk,'Proportional Gain/1','y/1','autorouting','on');
end

end

% Create PD (Only set_param position, i/o size, and Name)
function createPD(currentblock)
blkH = handle(currentblock);
blk = getfullname(currentblock);

posSum =         [415   115   435   135];
posD =           [105   215   135   245];
posSumD =        [235   220   255   240];
posN =           [335   215   365   245];
posIntegratorD = [315   268   390   332];

if strcmp(blkH.Form,'Parallel')
    posP = [105    20   135    50];
else % Ideal
    posP = [465   110   495   140];
end

% Add required blocks with the right orientation, position, number of
% ports.
if strcmp(blkH.TimeDomain,'Discrete-time')
    integrator = 'built-in/DiscreteIntegrator';
else
    integrator = 'built-in/Integrator';
end
add_block('built-in/Sum',[blk '/Sum'],...
    'Position',posSum,'IconShape', 'round','Inputs', '+|+');
add_block('built-in/Gain',[blk '/Proportional Gain'],'Position',posP);
add_block('built-in/Gain',[blk '/Derivative Gain'],'Position',posD);
add_block(integrator,[blk '/Filter'],...
    'Position',posIntegratorD,'Orientation','left',...
    'ExternalReset',blkH.ExternalReset,...
    'InitialConditionSource',blkH.InitialConditionSource);
add_block('built-in/Gain',[blk '/Filter Coefficient'],'Position',posN);
add_block('built-in/Sum',[blk '/SumD'],...
    'Position',posSumD,'IconShape', 'round','Inputs', '|+-');

% Connect added blocks
add_line(blk,'u/1','Derivative Gain/1','autorouting','on');
add_line(blk,'Derivative Gain/1','SumD/1','autorouting','on');
add_line(blk,'SumD/1','Filter Coefficient/1','autorouting','on');
add_line(blk,'Filter Coefficient/1','Filter/1','autorouting','on');
add_line(blk,'Filter/1','SumD/2','autorouting','on');
add_line(blk,'Filter Coefficient/1','Sum/2','autorouting','on');
if strcmp(blkH.Form,'Parallel')
    add_line(blk,'u/1','Proportional Gain/1','autorouting','on');
    add_line(blk,'Proportional Gain/1','Sum/1','autorouting','on');
    add_line(blk,'Sum/1','y/1','autorouting','on');
else % Ideal
    add_line(blk,'u/1','Sum/1','autorouting','on');
    add_line(blk,'Proportional Gain/1','y/1','autorouting','on');
    add_line(blk,'Sum/1','Proportional Gain/1','autorouting','on');
end

end

% Create I controller
function createI(currentblock)
blkH = handle(currentblock);
blk = getfullname(currentblock);

posI =           [105   110   135   140];
posIntegratorI = [315    93   390   157];

% Add required blocks with the right orientation, position, number of
% ports.
if strcmp(blkH.TimeDomain,'Discrete-time')
    integrator = 'built-in/DiscreteIntegrator';
else
    integrator = 'built-in/Integrator';
end
add_block('built-in/Gain',[blk '/Integral Gain'],'Position',posI);
add_block(integrator,[blk '/Integrator'],...
    'Position',posIntegratorI,'ExternalReset',blkH.ExternalReset,...
    'InitialConditionSource',blkH.InitialConditionSource);

% Connect added blocks
add_line(blk,'u/1','Integral Gain/1','autorouting','on');
add_line(blk,'Integral Gain/1','Integrator/1','autorouting','on');
add_line(blk,'Integrator/1','y/1','autorouting','on');

end

% Create a P controller
function createP(currentblock)
blk = getfullname(currentblock);

posP = [105   110   135   140];

% Add required blocks with the right orientation, position, number of
% ports.
add_block('built-in/Gain',[blk '/Proportional Gain'],'Position',posP);

% Connect added blocks
add_line(blk,'u/1','Proportional Gain/1','autorouting','on');
add_line(blk,'Proportional Gain/1','y/1','autorouting','on');

end
