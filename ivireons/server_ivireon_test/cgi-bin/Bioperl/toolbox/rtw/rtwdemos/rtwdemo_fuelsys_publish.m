%% Control and Logic Design with Simulink and Stateflow
% In this demonstration you will generate code for a fuel rate
% control system designed using Simulink(R) and Stateflow(R).  See
% <matlab:showdemo('sldemo_fuelsys') sldemo_fuelsys> for a detailed
% explanation of the model.

% Copyright 1994-2009 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2009/05/14 17:30:44 $

%% Familiarize Yourself with the Relevant Portions of the Model
% Figures 1-3 show relevant portions of the sldemo_fuelsys model, which is
% a closed-loop system containing a "plant" and "controller".  The plant is
% used to validate the controller in simulation early in the design cycle.
% In this example, we'll generate code for the relevant controller
% subsystem, "fuel_rate_control".  Figure 1 shows the top-level simulation
% model.

% open sldemo_fuelsys via rtwdemo_fuelsys and compile the diagram to see
% see the signal data types.
rtwdemo_fuelsys

sldemo_fuelsys([],[],[],'compile');
sldemo_fuelsys([],[],[],'term');

%%
% *Figure 1: Top-level model of the "plant" and "controller"*
%
% The fuel rate control system is comprised of Simulink and Stateflow blocks,
% and is the portion of the model for which we'll generated code.

open_system('sldemo_fuelsys/fuel_rate_control');

%%
% *Figure 2: The fuel rate controller subsystem*
%
% The control logic is a Stateflow chart that specifies the different
% modes of operation.

open_system('sldemo_fuelsys/fuel_rate_control/control_logic');

%%
% *Figure 3: Fuel rate controller logic*
%

%%
% Now let's remove the window clutter.
close_system('sldemo_fuelsys/fuel_rate_control/airflow_calc');
close_system('sldemo_fuelsys/fuel_rate_control/fuel_calc');
close_system('sldemo_fuelsys/fuel_rate_control/control_logic');
hDemo.rt=sfroot;hDemo.m=hDemo.rt.find('-isa','Simulink.BlockDiagram');
hDemo.c=hDemo.m.find('-isa','Stateflow.Chart','-and','Name','control_logic');
hDemo.c.visible=false;
close_system('sldemo_fuelsys/fuel_rate_control');

%% Configure and Build the Model Using Real-Time Workshop
% Real-Time Workshop(R) and Stateflow Coder(TM) generate generic ANSI-C
% code for Simulink and Stateflow models via the Generic Real-Time (GRT)
% target. Configuring a model for code generation can be done
% programmatically.

rtwconfiguredemo('sldemo_fuelsys','GRT');

%%
% For this example, let's build the fuel rate control system only.  Once
% the code generation process is complete, an HTML report detailing the generated
% code is displayed automatically.  The main body of the code is located
% in fuel_rate_control.c.

rtwbuild('sldemo_fuelsys/fuel_rate_control');

%% Configure and Build the Model Using Real-Time Workshop Embedded Coder
% Real-Time Workshop Embedded Coder is used to generate production
% ANSI-C/C++ code via the Embedded Real-Time (ERT) target. Configuring a
% model for code generation can be done programmatically. 

rtwconfiguredemo('sldemo_fuelsys','ERT');

%%
% Repeat the build process and inspect the generated code.  Figure 4 shows
% a portion of the generated control logic.  You can navigate to the
% relevant code segments interactively in the Real-Time Workshop Report
% using the *Previous* and *Next* buttons by selecting *Real-Time
% Workshop > Navigate to Code ...* from the charts context menu (i.e.,
% right-click on the Stateflow block), or programmatically using the
% rtwtrace utility.

rtwbuild('sldemo_fuelsys/fuel_rate_control');
rtwtrace('sldemo_fuelsys/fuel_rate_control/control_logic')

%%
%
% <<rtwdemo_fuelsys_control_logic.jpg>>

%%
% *Figure 4: Portion of the generated code for the fuel rate controller logic*

%%
% Close the demo.
clear hDemo
close_system('sldemo_fuelsys',0);

%% Closing Remarks
% Refer to Table 1 for related fixed-point demos using sldemo_fuelsys.
%
% <html>
% <TABLE>
% <table border=2 CELLPADDING=10>
% <TR>
% <TD>Fixed-point design</TD>
% <TD>
% <a
% href="matlab:sldemo_fuelsys_data('fxpdemo_fuelsys','showdemo','fxpdemo_fuelsys_publish','Simulink&nbsp;Fixed&nbsp;Point')">
% fxpdemo_fuelsys</a>
% </TD>
% </TR>
% <TR>
% <TD>Fixed-point production C/C++ code generation</TD>
% <TD>
% <a
% href="matlab:sldemo_fuelsys_data('fxpdemo_fuelsys','showdemo','rtwdemo_fuelsys_fxp_publish','Real-Time&nbsp;Workshop')">
% rtwdemo_fuelsys_fxp</a>
% </TD>
% </TR>
% </TABLE>
% </html>
% 
% *Table 1:*  Related product demos using sldemo_fuelsys 

displayEndOfDemoMessage(mfilename)