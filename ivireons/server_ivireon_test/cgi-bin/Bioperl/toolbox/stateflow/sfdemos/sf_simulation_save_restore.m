%% Simulation Save and Restore with Stateflow(R) Charts
% 
% Copyright 2008-2009 The MathWorks, Inc.
% $Revision: 1.1.10.2 $  $Date: 2009/07/27 20:35:38 $
%
% This demonstration shows how to use "Simulation Save and Restore" feature
% with Stateflow charts. There are two common use cases as listed below.
%
% # Division of a long simulation into segments.
% # Test of a chart response to different settings by restoring simulation
% from modified chart simulation state.
%
% We'll show in detail how to view Stateflow chart SimState saved in
% model simulation state, and how to change chart SimState before restoring
% simulation.
%
%% Open a Stateflow Model
% In this demo, we'll use Stateflow demo model "sf_boiler" . Open this 
% model by typing the following MATLAB(R) commands. 
%
model = 'sf_boiler';
open_system(model);

%% Enable Saving of Final SimState
% The following command programmatically enables saving of complete model
% final SimState to base workspace when simulation stops. The specified
% SimState variable name is "xFinal".
%
set_param(model, 'SaveFinalState', 'on', ...
                 'FinalStateName', 'xFinal', ...
                 'SaveCompleteFinalSimState', 'on');

%%
% You can also do this with the Configuration Parameters dialog
%
% # Open the Configuration Parameters dialog box and go to the Data Import/Export pane.
% # Select the "Final states:" check box, and enter desired model SimState variable name.
% # Select the "Save complete SimState in final state" check box.
%

%% Simulate Model to a Mid-Point
% Define a simulation stop time, for example 400. When you simulate model for this
% time period, you save the complete simulation state at t = 400 as the
% variable "xFinal" in the MATLAB base workspace.
%
tstop = 400;
[t1, x1, y1] = sim(model, [0 tstop]);
xFinal

%% View Chart SimState in Saved Model Simulation State
% You can get chart SimState by calling model SimState method
% "getBlockSimState", and passing in the chart path.
% 
chartpath = 'sf_boiler/Bang-Bang Controller';
cst = xFinal.getBlockSimState(chartpath);

%%
% Chart SimState has information for all graphical and data states
% contained in the chart. Chart SimState is managed in a hierarchical tree
% structure, which matches the hierarchy of chart objects. A non-leaf node in chart
% SimState represents a Stateflow container object, for example State,
% Function, Box. A leaf node in chart SimState represents a Data object parented
% by the container node. You can use dot notation to navigate to specific
% state data.
%

%%
% For example, to view chart SimState at chart level use the following
% command. Notice chart contains a Box, several Functions, and chart level
% data. Container nodes are listed after expansion signs "+".
%
cst

%%
% To view chart parented Local scope data "color", type in the following
% command. The display shows data properties and its value.
%
cst.color

%%
% The following command shows states "On" and "Off" inside of Box "Heater". 
% State "Off" is the current active state.
%
cst.Heater

%%
% You can use "open" method of a SimState node to open the corresponding chart object.
% For example, use the following command to highlight function "turn_boiler" in chart editor.
%
cst.turn_boiler.open;

%%
% To query activity of a graphical state, use "isActive" method. For example,
% the following command returns whether state "NORM" is active.
%
cst.Heater.On.NORM.isActive

%%
% To examine the value of a data state, check the "Value" field.
%
cst.boiler.Value

%%
% You can also highlight all states that are active using the following command.
%
cst.highlightActiveStates;

%% Modify Chart SimState
% You can change chart SimState by assigning new values to data states, or
% by calling "setActive" method on graphical state nodes. In the former
% case, the new value is checked for compatibility with state data's
% type, size and value ranges. In the latter case, Stateflow automatically
% maintains state consistency as much as possible.
%
% For example, to change chart output data "boiler" mode to be "ON", type
% in the following command.
%
cst.boiler.Value = 1;

%%
% To make current inactive state "NORM" to be active, call "NORM" node's
% setActive method.
%
cst.Heater.On.NORM.setActive;

%%
% You can check chart state consistency after modifying graphical state
% activities by calling "checkStateConsistency" method.
%
cst.checkStateConsistency;

%%
% If you are satisfied with the updated chart SimState, you can set it back
% to model simulation state using "setBlockSimState" method. For example,
% to create a new model SimState variable "xInitial" in MATLAB base
% workspace with the updated chart SimState, type in the following command.
%
xInitial = xFinal.setBlockSimState(chartpath, cst);

%% Restore Simulation from Saved Model SimState
% Model simulation can be restored from a model SimState saved in an older
% session. To demonstrate this, we will close "sf_boiler" and reopen it.
%
close_system(model, 0);
open_system(model);

%%
% The following command programmatically enables loading of model SimState
% when simulation starts. The specified SimState variable name is "xInitial".
%
set_param(model, 'LoadInitialState', 'on', ...
                 'InitialState', 'xInitial');

%%
% You can also do this with the Configuration Parameters dialog
%
% # Open the Configuration Parameters dialog box and go to the Data Import/Export pane.
% # Select the "Initial states:" check box, and enter desired model SimState variable name.
%

%%
% Start simulation and observe that simulation is resumed from the saved SimState.
%
[t2, x2, y2] = sim(model);
open_system('sf_boiler/Scope');

%%
%
displayEndOfDemoMessage(mfilename)
