function configPID2DOF(currentblock)
% CONFIGPID2DOF  Initialization utility for the PID 2dof block.

%   Author: Murad Abu-Khalaf
%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $ $Date: 2010/01/25 22:57:54 $

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
end

% Connect Integrators to RESET and I0 and D0 ports
pidpack.PIDConfig.connectIntegrators(currentblock);

end

% Create PID (Only set_param position, i/o size, and Name)
function createPID(currentblock)
blkH = handle(currentblock);
blk = getfullname(currentblock);

posI =           [225   110   255   140];
posIntegratorI = [440    93   515   157];
posSum =         [535   115   555   135];
posD =           [225   220   255   250];
posSumD =        [370   225   390   245];
posN =           [460   220   490   250];
posIntegratorD = [440   273   515   337];
posSum1 =        [170    30   190    50];
posSum2 =        [170    83   190   167];
posSum3 =        [170   225   190   245];
posb =           [85    20   115    50];
posc =           [85   215   115   245];

if strcmp(blkH.Form,'Parallel')
    posP = [225    25   255    55];
else % Ideal
    posP = [595   110   625   140];
end

% Add required blocks with the right orientation, position, number of
% ports.
if strcmp(blkH.TimeDomain,'Discrete-time')
    integrator = 'built-in/DiscreteIntegrator';
else
    integrator = 'built-in/Integrator';
end
add_block('built-in/Sum',[blk '/Sum'],'Position',posSum,...
    'IconShape', 'round','Inputs', '+++');
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
% Use sprintf('/Setpoint Weighting\n(Proportional)') instead of ['/Setpoint
% Weighting' char(10) '(Proportional)']
add_block('built-in/Gain',...
    [blk sprintf('/Setpoint Weighting\n(Proportional)')],'Position',posb);
add_block('built-in/Gain',...
    [blk sprintf('/Setpoint Weighting\n(Derivative)')],'Position',posc);
add_block('built-in/Sum',[blk '/SumD'],...
    'Position',posSumD,'IconShape','round','Inputs','|+-');
add_block('built-in/Sum',[blk '/Sum1'],'Inputs', '+-','Position',posSum1);
add_block('built-in/Sum',[blk '/Sum2'],'Inputs', '+-','Position',posSum2);
add_block('built-in/Sum',[blk '/Sum3'],'Inputs', '+-','Position',posSum3);

% Connect added blocks
add_line(blk,'r/1',...
    sprintf('Setpoint Weighting\n(Proportional)/1'),'autorouting','on');
add_line(blk,'r/1',...
    sprintf('Setpoint Weighting\n(Derivative)/1'),'autorouting','on');
add_line(blk,'r/1','Sum2/1','autorouting','on');
add_line(blk,'y/1','Sum1/2','autorouting','on');
add_line(blk,'y/1','Sum2/2','autorouting','on');
add_line(blk,'y/1','Sum3/2','autorouting','on');
add_line(blk,...
    sprintf('Setpoint Weighting\n(Proportional)/1'),'Sum1/1','autorouting','on');
add_line(blk,...
    sprintf('Setpoint Weighting\n(Derivative)/1'),'Sum3/1','autorouting','on');
add_line(blk,'Sum2/1','Integral Gain/1','autorouting','on');
add_line(blk,'Sum3/1','Derivative Gain/1','autorouting','on');
add_line(blk,'Integral Gain/1','Integrator/1','autorouting','on');
add_line(blk,'Derivative Gain/1','SumD/1','autorouting','on');
add_line(blk,'SumD/1','Filter Coefficient/1','autorouting','on');
add_line(blk,'Filter Coefficient/1','Filter/1','autorouting','on');
add_line(blk,'Filter/1','SumD/2','autorouting','on');
add_line(blk,'Integrator/1','Sum/2','autorouting','on');
add_line(blk,'Filter Coefficient/1','Sum/3','autorouting','on');
if strcmp(blkH.Form,'Parallel')
    add_line(blk,'Sum1/1','Proportional Gain/1','autorouting','on');
    add_line(blk,'Proportional Gain/1','Sum/1','autorouting','on');
    add_line(blk,'Sum/1','u/1','autorouting','on');
else % Ideal
    add_line(blk,'Sum1/1','Sum/1','autorouting','on');
    add_line(blk,'Sum/1','Proportional Gain/1','autorouting','on');
    add_line(blk,'Proportional Gain/1','u/1','autorouting','on');
end

end

% Create PI (Only set_param position, i/o size, and Name)
function createPI(currentblock)
blkH = handle(currentblock);
blk = getfullname(currentblock);

posI =           [225   110   255   140];
posIntegratorI = [420    93   495   157];
posSum =         [515   115   535   135];
posSum1 =        [170    30   190    50];
posSum2 =        [170    83   190   167];
posb =           [85    20   115    50];

if strcmp(blkH.Form,'Parallel')
    posP = [225    25   255    55];
else % Ideal
    posP = [565   110   595   140];
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
add_block('built-in/Gain',...
    [blk sprintf('/Setpoint Weighting\n(Proportional)')],'Position',posb);
add_block('built-in/Sum',[blk '/Sum1'],'Inputs', '+-','Position',posSum1);
add_block('built-in/Sum',[blk '/Sum2'],'Inputs', '+-','Position',posSum2);

% Connect added blocks
add_line(blk,'r/1',...
    sprintf('Setpoint Weighting\n(Proportional)/1'),'autorouting','on');
add_line(blk,'r/1','Sum2/1','autorouting','on');
add_line(blk,'y/1','Sum1/2','autorouting','on');
add_line(blk,'y/1','Sum2/2','autorouting','on');
add_line(blk,...
    sprintf('Setpoint Weighting\n(Proportional)/1'),'Sum1/1','autorouting','on');
add_line(blk,'Sum2/1','Integral Gain/1','autorouting','on');
add_line(blk,'Integral Gain/1','Integrator/1','autorouting','on');
add_line(blk,'Integrator/1','Sum/2','autorouting','on');
if strcmp(blkH.Form,'Parallel')
    add_line(blk,'Sum1/1','Proportional Gain/1','autorouting','on');
    add_line(blk,'Proportional Gain/1','Sum/1','autorouting','on');
    add_line(blk,'Sum/1','u/1','autorouting','on');
else % Ideal
    add_line(blk,'Sum1/1','Sum/1','autorouting','on');
    add_line(blk,'Sum/1','Proportional Gain/1','autorouting','on');
    add_line(blk,'Proportional Gain/1','u/1','autorouting','on');
end

end

% Create PD (Only set_param position, i/o size, and Name)
function createPD(currentblock)
blkH = handle(currentblock);
blk = getfullname(currentblock);

posSum =         [515   115   535   135];
posD =           [225   220   255   250];
posSumD =        [350   225   370   245];
posN =           [440   220   470   250];
posIntegratorD = [420   273   495   337];
posSum1 =        [170    30   190    50];
posSum3 =        [170   225   190   245];
posb =           [85    20   115    50];
posc =           [85   215   115   245];

if strcmp(blkH.Form,'Parallel')
    posP = [225    25   255    55];
else % Ideal
    posP = [565   110   595   140];
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
add_block('built-in/Gain',...
    [blk sprintf('/Setpoint Weighting\n(Proportional)')],'Position',posb);
add_block('built-in/Gain',...
    [blk sprintf('/Setpoint Weighting\n(Derivative)')],'Position',posc);
add_block('built-in/Sum',[blk '/Sum1'],'Inputs', '+-','Position',posSum1);
add_block('built-in/Sum',[blk '/Sum3'],'Inputs', '+-','Position',posSum3);

% Connect added blocks
add_line(blk,'r/1',...
    sprintf('Setpoint Weighting\n(Proportional)/1'),'autorouting','on');
add_line(blk,'r/1',...
    sprintf('Setpoint Weighting\n(Derivative)/1'),'autorouting','on');
add_line(blk,'y/1','Sum1/2','autorouting','on');
add_line(blk,'y/1','Sum3/2','autorouting','on');
add_line(blk,...
    sprintf('Setpoint Weighting\n(Proportional)/1'),'Sum1/1','autorouting','on');
add_line(blk,...
    sprintf('Setpoint Weighting\n(Derivative)/1'),'Sum3/1','autorouting','on');
add_line(blk,'Sum3/1','Derivative Gain/1','autorouting','on');
add_line(blk,'Derivative Gain/1','SumD/1','autorouting','on');
add_line(blk,'SumD/1','Filter Coefficient/1','autorouting','on');
add_line(blk,'Filter Coefficient/1','Filter/1','autorouting','on');
add_line(blk,'Filter/1','SumD/2','autorouting','on');
add_line(blk,'Filter Coefficient/1','Sum/2','autorouting','on');
if strcmp(blkH.Form,'Parallel')
    add_line(blk,'Sum1/1','Proportional Gain/1','autorouting','on');
    add_line(blk,'Proportional Gain/1','Sum/1','autorouting','on');
    add_line(blk,'Sum/1','u/1','autorouting','on');
else % Ideal
    add_line(blk,'Sum1/1','Sum/1','autorouting','on');
    add_line(blk,'Sum/1','Proportional Gain/1','autorouting','on');
    add_line(blk,'Proportional Gain/1','u/1','autorouting','on');
end

end
