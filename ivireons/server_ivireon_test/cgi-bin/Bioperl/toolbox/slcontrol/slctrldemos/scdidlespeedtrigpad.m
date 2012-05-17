%% Computing Operating Point Snapshots at Triggered Events
% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.6.8 $ $Date: 2009/11/09 16:35:39 $

%%
% This demonstration introduces the generation of operating points using
% triggered snapshots. The model can be opened using the command:
scdspeedtrigger

%% Generation of Operating Points Using Triggered Snapshots
% In this example the model will be linearized at steady state operating
% points of 2500, 3000, and 3500 RPM. To get these operating points,
% simulation is used to generate operating point snapshots of the steady
% state conditions. Since the exact time a system reaches a steady state
% value is not always known, blocks such as the subsystem - Generate
% settling time events can be built to generate settling events. The block
% in this example sends rising edge trigger signals when a model is near a
% settling condition. The mask shown below allows for multiple settling
% conditions to be entered. In this example the block is configured to fire
% the rising edge triggers when the engine speed settles near 2500, 3000,
% and 3500 RPM for a minimum of 5 seconds.
%
% <<../html_extra/scdspeedtrigger/BlockDialog.png>>

%%
% The output settling time events are then fed to an Operating Point
% Snapshot block. In this example, the block creates operating point 
% snapshots in the event of a rising edge trigger.
%
% <<../html_extra/scdspeedtrigger/SnapShotDialog.png>>

%%
% Using the FINDOP command, the simulation is run for 60 seconds and
% returns the operating points when engine speed is near steady state. 
op = findop('scdspeedtrigger',60);

%%
% The first operating point is near the 2500 RPM (261.8 rad/s) settling
% condition.
op(1)
%%
% The second operating point is near the 3000 RPM (314.16 rad/s) settling
% condition.
op(2)
%%
% The third operating point is near the 3500 RPM (366.52 rad/s) settling
% condition.
op(3)

%% Model Linearization
% The operating points are used for linearization. First specify the input
% and output points using the commands:
io(1) = linio('scdspeedtrigger/Reference Steps',1,'in');
io(2) = linio('scdspeedtrigger/rad//s to rpm',1,'out');
%% 
% Linearize the model and plot the Bode plot for each of the closed loop
% transfer functions.
sys = linearize('scdspeedtrigger',op(1:3),io);
bode(sys)

%% Snapshot Generation in the Control and Estimation Tools Manager
% The operating points in the example above can be recalculated in the 
% Control and Estimation Tools Manager GUI. The operating point snapshots 
% are generated in the node Operating Points as shown in the image below.
%
% <<../html_extra/scdspeedtrigger/TriggerShapshotGUIImage.png>>

bdclose('scdspeedtrigger')
displayEndOfDemoMessage(mfilename)