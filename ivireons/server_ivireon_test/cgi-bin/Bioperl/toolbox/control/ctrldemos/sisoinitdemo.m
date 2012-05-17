%% Programmatically Initializing the SISO Design Tool
% This demo shows how to configure the SISO Design Tool from the command
% line and how to create functions to customize the startup of a SISO Tool
% Design session.
%

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.3 $  $Date: 2006/12/27 20:33:05 $

%% The SISO Design Tool Configurations
% The SISO Design Tool allows different feedback control system
% configurations to be used. The six configurations available are:
%
% 1) The standard feedback loop with the compensator in the forward path and a
% prefilter.
%
% 2) The standard feedback loop with the compensator in the feedback path and a
% prefilter.
% 
% 3) Feedforward compensation and a feedback loop with a compensator in the
% forward path. This configuration is often used to attenuate disturbances
% that can be measured before they act on the system.
% 
% 4) The first multi-loop design configuration. This configuration provides the
% ability to separate the design into steps by isolating portions of the
% control loops.
%
% 5) The standard Internal Model Control(IMC) structure. 
%
% 6) The second multi-loop design configuration. This configuration provides the
% ability to separate the design into steps by isolating portions of the
% control loops.
%
% <<../Figures/sisoinitconfig.png>>


%% 
% By default the SISO Design Tool is initialized with configuration 1. The
% configuration can then be modified from within the SISO Design Tool.
% Alternatively, the SISO Design Tool can be initialized from the command
% line as presented in this demo.

%% Initializing the SISO Design Tool
% The command |sisoinit| is used to create a default SISO Tool configuration
% object. For example, suppose we want to start the SISO Tool with the
% following settings:
%%
% * Feedback architecture defined by configuration 4
% * The plant G has a value of tf(1,[1,1])
% * Root locus and bode editors for the outer open-loop 
% * Nichols editor for the inner open-loop 

%%
% First a design initialization object is created using |sisoinit| with the
% configuration as the argument. For this example the configuration is 4.
s = sisoinit(4)

%%
% The system model components are defined by the properties C1, C2, G and
% F. The open-loops for the system are defined by the properties OL1 for
% the outer loop and OL2 for the inner loop.

%%
% The next step is to specify the value of the plant G
s.G.Value = tf(1,[1,1]);

%%
% Now we can specify the editors we would like to see for each open-loop.
% In addition we can specify meaningful names for the loops to make them
% easier to identify in the SISO Tool.
s.OL1.Name = 'Outer Loop';
s.OL1.View = {'rlocus','bode'};
s.OL2.Name = 'Inner Loop';
s.OL2.View = {'nichols'};

%%
% Now that the desired settings have been applied we can start SISO Design
% Tool with this configuration type:
%
% |>> sisotool(s)|

%%
% <<../Figures/sisoinitsisotool.png>>


%% Creating a Custom Initialization Function
%
% Creating a custom initialization function is useful to start up the SISO
% Design Tool in a configuration that is used often. For example, the above
% example could be put in a function with an input argument for the plant
% dynamics. This is done in the following function.

type mycustomsisotoolfcn

%%
% To launch the SISO Design Tool using this function type
%%
% |>> G = tf(1,[1,1]);|
%%
% |>> mycustomsisotoolfcn(G)|

displayEndOfDemoMessage(mfilename)