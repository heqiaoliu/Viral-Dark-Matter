function varargout = target_block_verify(varargin)
%TARGET_BLOCK_VERIFY simulates and returns logged signals of 2 blocks.
%   [LOG_SIGS1, LOG_SIGS2] = TARGET_BLOCK_VERIFY('BLOCK1', 'BLOCK2') turns
%   on signal logging for the outports of BLOCK1, then the model containing
%   BLOCK1 is simulated and the logged signals are returned in LOG_SIGS1.
%   BLOCK1 and BLOCK2 are then swapped, the same model is simulated again
%   and the logged signals for BLOCK2 are returned in LOG_SIGS2. At the end
%   of the simulation, BLOCK1 is highlighted.
%
%   TARGET_BLOCK_VERIFY can be used to verify the generated PIL or SIL
%   block. BLOCK1 can be the simulation or algorithm block, and BLOCK2 can
%   be the generated PIL or SIL block for BLOCK1.
%
%   - Input Arguments
%   BLOCK1: Full path name of a Simulink block. The model containing
%   BLOCK1 is loaded.
%
%   BLOCK2: Full path name of a Simulink block. BLOCK2 may exist in the
%   same model as BLOCK1 or in its own model. The model containing
%   BLOCK2 is loaded.
%
%   - Output Arguments
%   LOG_SIGS1: is a ModelDataLogs object containing all the logged
%   signals for the outports of BLOCK1. The data returned for each outport
%   is a Timeseries object that allows different comparison and plotting
%   capabilities.
%
%   LOG_SIGS2: same as LOG_SIGS1 but for BLOCK2. Note that if BLOCK1 and
%   BLOCK2 are in the same model, then one LOG_SIGS output is returned
%   containing the data for both BLOCK1 and BLOCK2.
%
%   Note: Please note that this script makes temporary changes to the model
%   by swapping the BLOCK1 and BLOCK2 in addition to setting some logging
%   options. Although the script restores back the original settings of the
%   model, it is recommended that you save a copy of your model first
%   before using this script.

% Copyright 2006-2008 The MathWorks, Inc.
% $Revision: 1.1.10.9 $

error(nargchk(2, 2, nargin,'struct'));
error(nargoutchk(0, 2, nargout, 'struct'));

% load model
model = strtok(varargin{1}, '/\');
load_system(model);

if strcmpi(get_param(varargin{1}, 'BlockType'), 'ModelReference')
    modelBlock = varargin{1};
    simulationModes = varargin{2};
    implementation = 'modelBlockBasedPIL';
else
    simulationComponent = varargin{1};
    targetComponent = varargin{2};
    implementation = 'subsystemBasedPIL';
end

% save model settings before altering them
% Model parameters that need to be saved
ModelParamsToSave = {'SignalLogging', 'SignalLoggingName'};
% Block Output port parameters that need to be saved
OutputPortParamsToSave = {'DataLogging', 'TestPoint',...
    'DataLoggingName','DataLoggingNameMode'};

switch (implementation)
    case 'subsystemBasedPIL'
        % validate algorithm and target blocks
        [target_model target_subsys]  = i_validateBlockAndModel(targetComponent);
        [simulation_model simulation_subsys]  = i_validateBlockAndModel(simulationComponent);

        % save model and simulation block output ports settings
        [SavedModelParamsValues simulation_SavedOutputPortsParamsValues] = i_saveModelSettings(...
            simulationComponent,...
            ModelParamsToSave, ...
            OutputPortParamsToSave);

        % target block and algorithm block are in different models
        if ~strcmp(simulation_model, target_model)
            % Set Logging Options for host simulation
            SigLogName_s = 'simlogs';
            i_setLoggingOptions(simulationComponent, SigLogName_s, 'out');

            % Simulate
            mode = 'Normal';
            simulation_results = i_sim(simulation_model, mode);

            % Replace simulation component with target component
            pil_block_replace(targetComponent, simulationComponent);

            % Set Logging Options for target simulation
            SigLogName_t = 'tgtlogs';
            i_setLoggingOptions(simulationComponent, SigLogName_t, 'out');

            % trap the target simulation and in case of failure, restore the alg
            % block into the model
            try
                % Simulate
                mode = 'PIL';
                target_results = i_sim(simulation_model, mode);
            catch e
                % restore the original alg block
                i_restoreOrigAlgBlock(target_model, ...
                    simulation_subsys, ...
                    simulationComponent, ...
                    target_subsys);

                % Throw last error msg
                rethrow(e);
            end

            % restore the original alg block
            i_restoreOrigAlgBlock(target_model, ...
                simulation_subsys, ...
                simulationComponent, ...
                target_subsys);

            % outputs
            varargout(1) = {simulation_results};
            varargout(2) = {target_results};

        else % target block and algorithm block are both in the same model

            % save block output port settings before altering them
            [SavedModelParamsValues target_SavedOutputPortsParamsValues] = i_saveModelSettings(...
                targetComponent,...
                ModelParamsToSave, ...
                OutputPortParamsToSave);

            % set the logging options and simulate
            SigLogName = 'logs';
            i_setLoggingOptions(simulationComponent, SigLogName, 'simout');
            i_setLoggingOptions(targetComponent, SigLogName, 'tgtout');
            mode = '';
            results = i_sim(simulation_model, mode);

            % output
            varargout(1) = {results};

            % restore model and target block output ports settings
            i_restoreModelSettings(targetComponent,...
                ModelParamsToSave, SavedModelParamsValues,...
                OutputPortParamsToSave, target_SavedOutputPortsParamsValues);
        end

        % Restore model and simulation block output ports settings
        i_restoreModelSettings(simulationComponent,...
            ModelParamsToSave, SavedModelParamsValues,...
            OutputPortParamsToSave, simulation_SavedOutputPortsParamsValues);

    case 'modelBlockBasedPIL'
        % should be cell array even if it is one mode
        if ~iscell(simulationModes)
            TargetCommon.ProductInfo.error('pil', 'ParamTypeCellArray');
        end
        
        % error out when an unsupported mode is passed in
        supportedSimulationModes = {'Normal','Accelerator','PIL'};
        unsupported = setdiff(simulationModes, supportedSimulationModes);
        if ~isempty(unsupported)
            TargetCommon.ProductInfo.error('pil', 'SimulationModeValues');
        end
        
        % make sure the passed model block is valid
        model  = i_validateBlockAndModel(modelBlock);

        
        % save model and simulation block output ports settings
        [savedModelSettings savedOutputPortsSettings] = i_saveModelSettings(...
            modelBlock,...
            ModelParamsToSave, ...
            OutputPortParamsToSave);

        % save simulationMode
        orig_simMode = get_param(modelBlock, 'SimulationMode');
        
        % loop over simulation modes and simulate
        for i = 1:length(simulationModes)
            i_setLoggingOptions(modelBlock, 'logs', 'out');
            thisSimMode = strrep(simulationModes{i}, 'PIL','Processor-in-the-loop (PIL)');                        
            set_param(modelBlock, 'SimulationMode', thisSimMode);       
            results = i_sim(model, simulationModes{i});                        
            varargout(i) = {results};  %#ok<AGROW>
        end
                
        % restore simulationMode
        set_param(modelBlock, 'SimulationMode', orig_simMode);

        % Restore model and simulation block output ports settings
        i_restoreModelSettings(modelBlock,...
            ModelParamsToSave, savedModelSettings,...
            OutputPortParamsToSave, savedOutputPortsSettings);
end




%__________________________________________________________________________
function results = i_sim(model, mode)

disp(['--- Running ' mode ' simulation for model ' model '. Please wait...']);

% measure time it takes to simulate the model
t = tic;
% simulate
sim(model, [],  simset('SrcWorkspace','base','DstWorkspace','base'));
disp(['--> Simulation took ' num2str(toc(t)) ' seconds.']);

% get simulation results: Simulink.ModelDataLogs object
sigLogName = get_param(model,'SignalLoggingName');
results = evalin('base', [sigLogName ';']);

%__________________________________________________________________________
function i_setLoggingOptions(simulation_block, SigLogName,DataLoggingPrefix)
model = strtok(simulation_block, '/');
set_param(model, 'SignalLogging', 'on');
set_param(model, 'BusObjectLabelMismatch','none')
set_param(model,'SignalLoggingName', SigLogName);
portHandles = get_param(simulation_block, 'PortHandles');
outPorts = portHandles.Outport;

for k = 1:length(outPorts)
    set(outPorts(k), 'DataLogging','on');
    set(outPorts(k), 'DataLoggingNameMode','Custom');
    set(outPorts(k), 'DataLoggingName',[DataLoggingPrefix num2str(k)]);
end

%__________________________________________________________________________
function i_restoreModelSettings(simulation_block,...
    ModelParamsToSave, SavedModelParamsValues,...
    OutputPortParamsToSave, SavedOutputPortsParamsValues)

% model name
model = strtok(simulation_block, '/');

% restore model parameters
for k = 1:length(ModelParamsToSave)
    set_param(model, ModelParamsToSave{k}, SavedModelParamsValues{k});
end

% restore the port settings
portHandles = get_param(simulation_block, 'PortHandles');
outPorts = portHandles.Outport;
for m = 1:length(outPorts)
    for n = 1:length(OutputPortParamsToSave)
        set(outPorts(m), OutputPortParamsToSave{n}, SavedOutputPortsParamsValues{m}{n});
    end
end

%__________________________________________________________________________
function i_restoreOrigAlgBlock(target_model, ...
    simulation_block, ...
    simulationComponent, ...
    target_subsys)

% Restore original alg block
pil_block_replace([target_model simulation_block], simulationComponent);

% restore the name of the target block
set_param([target_model simulation_block], 'Name', target_subsys(2:end));


%__________________________________________________________________________
function [SavedModelParamsValues SavedOutputPortsParamsValues] =...
    i_saveModelSettings(simulation_block, ModelParamsToSave, OutputPortParamsToSave)

% model name
model = strtok(simulation_block, '/');

% get current values for passed model parameters
SavedModelParamsValues = [];
for k = 1:length(ModelParamsToSave)
    SavedModelParamsValues{k} = get_param(model, ModelParamsToSave{k}); %#ok<AGROW>
end


% get current values for passed Block output ports parameters
SavedOutputPortsParamsValues = [];
portHandles = get_param(simulation_block, 'PortHandles');
outPorts = portHandles.Outport;
for m = 1:length(outPorts)
    for n = 1:length(OutputPortParamsToSave)
        SavedOutputPortsParamsValues{m}{n} = get(outPorts(m),...
            OutputPortParamsToSave{n}); %#ok<AGROW>
    end
end

%__________________________________________________________________________
function [model, block] = i_validateBlockAndModel(BlockNameFullPath)
% make sure the user passed the full path of the block

ndx = findstr(BlockNameFullPath, '/');
if isempty(ndx)
    TargetCommon.ProductInfo.error('pil', 'FullSimulinkSystemPathRequired', BlockNameFullPath);
end

model = strtok(BlockNameFullPath, '/');

% load model if not loaded
load_system(model);

% make sure the block exists in the model. If it does not exist, the
% load_system command below will issue the right error msg
load_system(BlockNameFullPath);

% return last trailing block name
block = BlockNameFullPath(ndx(end):end);

% open model
open_system(model);

if strcmpi(get_param(model, 'StopTime'), 'inf')
    TargetCommon.ProductInfo.error('pil', 'InfSimulationTime');
end

if strcmpi(get_param(BlockNameFullPath, 'LinkStatus'), 'implicit')
    TargetCommon.ProductInfo.error('pil', 'SubsystemLinkedToLibrary',  BlockNameFullPath);
end

