%% Software and Processor-in-the-Loop (SIL and PIL) Simulation
% You can use SIL or PIL simulation mode to verify automatically generated code
% by comparing the results with a normal mode simulation and by collecting
% metrics, e.g. for code coverage. With SIL, you can easily verify the behavior
% of production-intent source code on your host computer; however, it is
% generally not possible to verify exactly the same code that will subsequently
% be compiled for your target hardware because the code must be compiled for
% your host platform (i.e. a different compiler and different processor
% architecture than the target). With PIL simulation, you can verify exactly the
% same code that you intend to deploy in production, and you can run the code
% either on real target hardware or on an instruction set simulator.
%
% This demonstration shows you how to select the approach for SIL or PIL
% verification that best fits your needs. To help with this choice, you should
% answer these questions about your task.
%
%  1. For which model component and code interface will you verify the
%     generated code?
%       a) A top-model (standalone code interface)
%       b) A subsystem (right-click build and standalone code
%          interface)
%       c) A referenced model (model reference code interface)
%  2. How will you apply input stimulus signals or test vectors to your
%     component under test?
%       a) Load stimulus data from the MATLAB workspace or from a
%          MATLAB script
%       b) Use a test harness model (or a system model) to generate
%          stimulus data
%  3. Is it important to rapidly switch between normal, SIL or PIL
%     simulation mode without making any changes to your model?
%       a) Yes - it must be easy to switch simulation mode simply by
%          choosing from a menu selection
%       b) No - it is acceptable to change the model and insert a 
%          special block to represent a component running in SIL or PIL
%          mode
%  4. If you intend to verify object code executing in the target
%     environment (real hardware or instruction set simulator), which
%     of the following options apply to your situation?
%       a) The Embedded IDE Link product from MathWorks supports your
%          compiler and target environment
%       b) There is a third party, off-the-shelf PIL configuration for
%          your target environment
%       c) You will use the documented API to implement a connectivity
%          configuration that supports your target environment
%
% Study the examples below to help you determine the right approach for your
% situation.
%
% See also <matlab:showdemo('rtwdemo_custom_pil') rtwdemo_custom_pil>,
% <matlab:showdemo('rtwdemo_rtiostream') rtwdemo_rtiostream>

% Copyright 2007-2009 The MathWorks, Inc.
% $Revision: 1.1.6.2 $  $Date: 2010/01/25 22:11:33 $


%% Example 1: SIL Block for Software-in-the-Loop Simulation
% This example shows how the automatically generated SIL block can be used for
% verification. With this approach:
%
% * You can verify code generated for top models or subsystems (standalone code
% interface)
% * You must provide a test harness model (or a system model) to supply test
% vector or stimulus inputs
% * You must swap your original subsystem with an automatically generated SIL
% block; you should be careful to avoid saving your model in this state as you
% would lose your original subsystem
% * This approach cannot use the documented target connectivity API:
% consequently, you can only run SIL (and not PIL) simulations
%
% Open a simple model by typing the following MATLAB commands. The model
% comprises a control algorithm connected in closed loop with a plant model. The
% control algorithm is designed to regulate the output from the plant.
model='rtwdemo_sil_block';
close_system(model,0)
open_system(model)
out = sim(model,10);
yout_normal = find(out,'yout');
clear out

%%
% Configure the build process to create the SIL block for verification. When
% code is generated for this model - or any of its subsystems - it is compiled
% to a shared library and the SIL block (a Simulink S-function block) is
% automatically created that calls this library.
set_param(model,'GenerateErtSFunction','on');

%%
% Generate code for the control algorithm subsystem by running the commands
% below; alternatively, you can right-click on the subsystem and select
% Real-Time Workshop > Build Subsystem then click Build on the resulting
% dialog. Note that the SIL block is created at the end of the build and its
% input/output ports match those of the control algorithm subsystem.
if ~isempty(find_system('type', 'block_diagram','Name','untitled'))
    error(['A model named untitled is already open. You must close this model '...
          'and run the demo again.']);
end
rtwbuild([model '/Controller'])

%%
% *Example 1: simulate the model*
%
% To perform a SIL simulation, with the controller configured in closed loop
% with the plant model, you must replace the original control algorithm with the
% new SIL block. Run the following commands to perform this replacement
% automatically.
controllerBlock = [model '/Controller'];
blockPosition = get_param(controllerBlock,'Position');
delete_block(controllerBlock);
add_block('untitled/Controller',[controllerBlock '(SIL)'],...
          'Position', blockPosition);
close_system('untitled',0);
clear controllerBlock blockPosition

%%
% Run the SIL simulation and plot all the results to compare with the normal
% simulation. Do the normal and SIL simulation results differ? The control
% algorithm uses single precision floating point arithmetic; you should expect
% to see differences with order of magnitude in the region of machine precision
% for single precision data. If you need to verify the exact behaviour on
% production hardware, you should use PIL simulation.
out = sim(model,10);
yout_sil = find(out,'yout');
tout = find(out,'tout');

% Define an error tolerance based on machine precision for the normal simulation
% result represented in single precision
machine_precision = eps(single(yout_normal));
tolerance = 4 * machine_precision;

fig1 = figure;
subplot(3,1,1), plot(yout_normal), title('Controller output for normal simulation')
subplot(3,1,2), plot(tout, [abs(yout_normal-yout_sil) tolerance]), ...
    title('Error and error tolerance threshold')
subplot(3,1,3), plot(yout_sil), title('Controller output for SIL simulation');

%% 
% *Example 1: clean up*
close_system(model,0);
if ishandle(fig1), close(fig1), end
clear fig1
simResults={'out','yout_sil','yout_normal','tout','machine_precision'};
save([model '_results'],simResults{:});
clear(simResults{:},'simResults')

%% Example 2: SIL or PIL Simulation for Model Blocks
% This example shows how you can verify the automatically generated code for a
% referenced model by running a SIL simulation. With this approach:
%
% * You can verify code generated for referenced models (model reference code
% interface)
% * You must provide a test harness model (or a system model) to provide test
% vector or stimulus inputs
% * You can easily switch a Model block between normal and SIL or PIL simulation
% mode
% * To run a PIL simulation, you must have a target-specific connectivity
% configuration available. A connectivity configuration allows the PIL
% simulation to build the target application, download it to real hardware or an
% instruction set simulator then, launch the application and communicate with it
% during the simulation. For details on Embedded IDE Link support for this
% simulation mode, see the documentation for that product.
%
% Open an example model by typing the following MATLAB commands. The model
% contains two Model blocks that both point at the same referenced model. One of
% the Model blocks is configured to run in SIL simulation mode and the other in
% normal mode.
model='rtwdemo_sil_modelblock';
open_system(model);

%% 
% *Example 2: simulate the model*
%
% Execute the following commands to run a simulation and plot the results. As
% one of the model blocks is configured to run in SIL mode, you will see in the
% command window that code is generated for the referenced model (unless
% generated code already exists from a previous build). Note that model block
% running in SIL mode is executed as a separate process on your computer.
out = sim(model,20);

%%
% Compare the behavior of Model blocks executing in normal and SIL simulation
% modes by running the following commands. The behaviors should match exactly.
yout = find(out,'logsOut');
yout_sil = yout.counterA.Data;
yout_normal = yout.counterB.Data;
fig1 = figure;
subplot(3,1,1), plot(yout_normal), title('Counter output for normal simulation')
subplot(3,1,2), plot(yout_normal-yout_sil), title('Error')
subplot(3,1,3), plot(yout_sil), title('Counter output for SIL simulation');

%% 
% *Example 2: clean up*
close_system(model,0);
if ishandle(fig1), close(fig1), end, clear fig1
simResults={'out','yout','yout_sil','yout_normal','SilCounterBus','T',...
            'reset','ticks_to_count','Increment'};
save([model '_results'],simResults{:});
clear(simResults{:},'simResults')



%% Example 3: SIL or PIL Simulation for Top Models
% This example shows how you can verify the automatically generated code for a
% top model by running a SIL or PIL simulation. With this approach:
%
% * You can verify code generated for a top model (standalone code interface)
% * You must configure the model to load test vectors or stimulus inputs from
% the MATLAB workspace
% * You can easily switch the entire model between normal and SIL or PIL
% simulation mode
% * To run a PIL simulation, you must have a target-specific connectivity
% configuration available. A connectivity configuration allows the PIL
% simulation to build the target application, download it to real hardware or an
% instruction set simulator then, launch the application and communicate with it
% during the simulation. For details on Embedded IDE Link support for this
% simulation mode, see the documentation for that product.
%
% Open an example model by typing the following MATLAB commands. The model
% is a simple counter.
model='rtwdemo_sil_topmodel';
open_system(model)

%%
% *Example 3: configure the input stimulus data*
[ticks_to_count, reset] = rtwdemo_sil_topmodel_data(T);

%%
% *Example 3: configure logging options in the model*
set_param(model, 'LoadExternalInput','on');
set_param(model, 'ExternalInput','ticks_to_count, reset');
set_param(model, 'SignalLogging', 'on');
set_param(model, 'SignalLoggingName', 'logsOut');


%% 
% *Example 3: simulate the model*
% Enter the following commands to run first a normal mode, then a SIL simulation
% and compare the results.
set_param(model,'SimulationMode','normal')
out = sim(model,10);
logsOut = find(out,'logsOut');
yout_normal = logsOut.output.Data;


%% 
% Run a SIL simulation; unless code for this model already exists and is up to
% date, new code will be generated and compiled. When the simulation runs, this
% code is executed as a separate process on your host computer.
set_param(model,'SimulationMode','Software-in-the-Loop (SIL)')
out = sim(model,10);
logsOut = find(out,'logsOut');
yout_sil = logsOut.output.Data;

%% 
% Run the following commands to plot and compare the results of normal and SIL
% simulation. The behaviors should match exactly.
fig1 = figure;
subplot(3,1,1), plot(yout_normal), title('Counter output for normal simulation')
subplot(3,1,2), plot(yout_normal-yout_sil), title('Error')
subplot(3,1,3), plot(yout_sil), title('Counter output for SIL simulation');

%% 
% *Example 3: clean up*
close_system(model,0);
if ishandle(fig1), close(fig1), end, clear fig1
simResults = {'out','logsOut','yout_sil','yout_normal','model','T',...
              'ticks_to_count','reset'};
save([model '_results'],simResults{:});
clear(simResults{:},'simResults')


%% Further Information on Hardware Implementation Settings for SIL Simulation
% When you run a SIL simulation, you must configure your hardware implementation
% settings (i.e. characteristics such as native word sizes) to allow compilation
% for your host computer. This means that the settings may differ from the
% hardware implementation settings that you must use when you build the model
% for your production hardware. You can avoid the need to change hardware
% implementation settings between SIL and PIL simulation modes by enabling
% portable word sizes. For further information on this topic see
% <matlab:open_system('rtwdemo_sil_hardware_config')
% rtwdemo_sil_hardware_config>.


displayEndOfDemoMessage(mfilename)
