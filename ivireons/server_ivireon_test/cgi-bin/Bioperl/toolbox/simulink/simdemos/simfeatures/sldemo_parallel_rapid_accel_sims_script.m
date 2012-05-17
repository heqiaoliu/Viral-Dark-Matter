%% Rapid Accelerator Simulations Using PARFOR
% In this demo we illustrate the use of Rapid Accelerator in 
% applications that require running parallel simulations for a range of 
% input and parameter values. 
%
% We use the engine idle speed model which simulates the idle speed of an 
% engine. The input of this model is the voltage of the bypass air valve 
% and the output is the idle speed.
%
% We run parallel simulations using PARFOR with two sets of valve voltages 
% and by independently varying two of the three gain parameters of
% the transfer functions over a range of two values. Hence, in total, we
% will be running eight different sets of simulations.
%
% It is very easy to customize this demo for your own application by 
% modifying the script file used to build this demo. Click the link in 
% the top left corner of this page to edit the script file. Click the 
% link in the top right corner to run this demo from MATLAB(R). 
% Before running this demo, make sure you are in a writable directory. 
%
% Copyright 2005-2009 The MathWorks, Inc.


%% Step 1: Preparation
% First we open the model where the simulation mode has been set to 
% Rapid Accelerator.
% The default input data and the required parameters are preloaded in the 
% models workspace. We change to a temporary directory since running in 
% Rapid Accelerator mode creates extra files.
%
% The parameters gain2 and gain3 have been specified as tunable parameters 
% so that they can be modified later using the utility function
% Simulink.BlockDiagram.modifyTunableParameters.
% To learn how to select tunable parameters and set their properties 
% graphically, read the following help page concerning the
% <matlab:helpview(fullfile(docroot,'toolbox','rtw','helptargets.map'),'model_param_config_dialog') Model Parameter Configuration Dialog Box>.
%
% We copy the default input and time data to a variable so that we can 
% later modify them and pass them to the SIM command.
%

% Open model: 
mdl = 'sldemo_raccel_engine_idle_speed';
open_system(mdl);
curDir = pwd;
cd(tempdir);

% Copy input data
inpData = evalin('base', 'inpData');
tData = evalin('base', 'time');

%% Step 2: Build the Rapid Accelerator Target
% We now build the Rapid Accelerator executable for the model and get the 
% default run-time parameter set.
%

rtp = Simulink.BlockDiagram.buildRapidAcceleratorTarget(mdl);
close_system(mdl, 0);

%% Step 3: Create Parameter Sets
% Using the default rtp structure from step 2, we build a new structure 
% with different values for the tunable variables in the model. 
% We want to see how the idle speed changes for different values of parameters
% gain2 and gain3. Therefore, we generate different parameter sets with 
% different values of gain2 and gain3 and leave the other tunable variables 
% at their default values.
%
% The utility function Simulink.BlockDiagram.modifyTunableParameters
% is a convenient way to build the rtp structure with different parameter 
% values.
%

gain2_vals = 25:10:35;
gain3_vals = 20:10:30;

num_gain2_vals = length(gain2_vals);
num_gain3_vals = length(gain3_vals);
numParamSets = num_gain2_vals*num_gain3_vals;

% Create parameter sets:
paramSets = cell(1, numParamSets);
idx = 1;
for iG2 = 1:num_gain2_vals
    for iG3 = 1:num_gain3_vals
        paramSets{idx} = ...
            Simulink.BlockDiagram.modifyTunableParameters(rtp, ...
            'gain2',gain2_vals(iG2), ...
            'gain3',gain3_vals(iG3));
        idx = idx+1;
    end
end

%% Step 4: Create Input Sets
% Here we perturb the default input values vector to obtain a new
% input values vector.
%
% In this demo, we will be plotting the engine idle speed as a function of 
% the valve voltage for different parameter values.
%

inpSets{1} = inpData;
rndPertb = 0.5 + rand(length(tData), 1);
inpSets{2} = inpSets{1}.*rndPertb;
numInpSets  = length(inpSets);

%% Step 5: Create SIM Command Argument Sets
% We now create a cell array of parameter-name-value structures that will be 
% passed to the SIM command called from inside of a PARFOR loop.
%
% To run the SIM command in Rapid Accelerator mode, we need to set the 
% field 'RapidAcceleratorUpToDateCheck' to 'off' and pass the parameter sets
% by using the 'RapidAcceleratorParameterSets' field.
%
% We also collect all of the external inputs in a cell array. Later we assign 
% each of them with 'externalInput' as the variable name in the base 
% workspace of the workers.
%

numSimCmdArgStructs = numParamSets*numInpSets;
simCmdParamValStructs = cell(1, numSimCmdArgStructs);
externalInput = cell(1, numSimCmdArgStructs);

paramValStruct.SaveTime = 'on';
paramValStruct.SaveOutput = 'on';
paramValStruct.LoadExternalInput = 'on';
% 'externalInput' is the name of the base workspace variable of  
% the MATLAB worker sessions containing the external inputs data
paramValStruct.ExternalInput = 'externalInput';
paramValStruct.RapidAcceleratorUpToDateCheck = 'off';
paramValStruct.RapidAcceleratorParameterSets = [];

idx = 1;
for paramSetsIdx = 1:numParamSets
    for inpSetsIdx = 1:numInpSets     
        simCmdParamValStructs{idx} = paramValStruct;
        simCmdParamValStructs{idx}.RapidAcceleratorParameterSets = ...
            paramSets{paramSetsIdx};
        externalInput{idx} = [tData, inpSets{inpSetsIdx}];
        idx = idx + 1;
    end
end

%% Step 6: Start Matlabpool
% Uncomment the code to start a matlabpool
% The following line of code starts four worker MATLAB sessions. PARFOR   
% would then distribute jobs to these four worker sessions.

% matlabpool open 4;

%% Step 7: Simulate in PARFOR
% Here we simulate the model in parallel using PARFOR with different argument
% sets that contain different parameter values and input vectors. 
% We assign the input vectors corresponding to the simulation in the 
% base workspace of the MATLAB worker session that is running the simulation.
% The use of EVALIN(‘base’) and ASSIGNIN(‘base’) inside of a PARFOR loop 
% indicates a reference to the base workspaces of the worker machines, 
% and thus is not generally recommended. 
% However, in the current demo, the variable ‘externalInputs’ is required by 
% the base workspace of each session. Consequently, using ASSIGNIN(‘base’) 
% inside of PARFOR is valid here.
% 

out = cell(1, numSimCmdArgStructs);

parfor(i = 1:numSimCmdArgStructs)    
    assignin('base', 'externalInput', externalInput{i}); %#ok<PFEVB>
    out{i} = sim(mdl, simCmdParamValStructs{i});
end

%% Step 8: Plot Results
% We now plot the engine idle speed with respect to time for different
% parameter values and inputs.
% The variable 'out' is a cell array of Simulink.SimulationOutput objects 
% which contains the simulation data for each simulation.
%

for i=1:numSimCmdArgStructs
    t = out{i}.find('tout'); 
    y = out{i}.find('yout');
    plot(t, y)
    hold all
end

fprintf('\n Contents of the out{1}: \n');
display(out{1});

%% Step 9: Close Matlabpool
% We now return to the original directory.
% If the matlabpool was started earlier then it must be closed.
% The second line of the following code closes the matlabpool, and thus
% closes the worker sessions, when the comment symbol is removed. For more 
% information, see the documentation on PARFOR and MATLABPOOL.
%

cd(curDir);
% matlabpool close


displayEndOfDemoMessage(mfilename)
