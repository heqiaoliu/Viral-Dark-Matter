%% Automated Tuning of Simulink PID Controller Block
%
% Copyright 2005-2010 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2010/05/10 17:56:31 $

%% Introduction of the PID Tuner
% PID Tuner provides a fast and widely applicable single-loop PID tuning
% method for the Simulink(R) PID Controller blocks.  With this method, you
% can tune PID parameters to achieve a robust design with the desired
% response time.     
% 
% A typical design workflow with the PID Tuner involves the following
% tasks: 
%
% (1) Launch the PID Tuner.  When launching, the software automatically
% computes a linear plant model from the Simulink model and designs an
% initial controller.  
%
% (2) Tune the controller in the PID Tuner by manually adjusting design
% criteria in two design modes. The tuner computes PID parameters that
% robustly stabilize the system.     
%
% (3) Export the parameters of the designed controller back to the PID
% Controller block and verify controller performance in Simulink.

%% Opening the Model
% Take a few moments to explore the model. 
%%
% <matlab:open_system('scdspeedctrlpidblock') Open the engine speed control model with PID Controller block>
open_system('scdspeedctrlpidblock');

%%
%% Design Overview
% In this demo, you design a PI controller in an engine speed control loop.
% The goal of the design is to track the reference signal from a Simulink
% step block |scdspeedctrlpidblock/Speed Reference|.  The design
% requirement are: 
% 
% * Settling time under 5 seconds
% * Zero steady-state error to the step reference input.  
%
% In this example, you stabilize the feedback loop and achieve good
% reference tracking performance by designing the PI controller
% |scdspeedctrl/PID Controller| in the PID Tuner.   

%% Opening the PID Tuner
% To launch the PID Tuner, double-click the PID Controller block to open
% its block dialog.  In the *Main* tab, click *Tune*.
%
% <<../html_extra/scdspeedctrlpidblock/pid_blockdialog.png>>

%% Initial PID Design
% When the PID Tuner launches, the software computes a linearized plant
% model seen by the controller.  The software automatically identifies the
% plant input and output, and uses the current operating point for the
% linearization.  The plant can have any order and can have time delays.       
%
% The PID Tuner computes an initial PI controller to achieve a reasonable
% tradeoff between performance and robustness. By default, step reference
% tracking performance displays in the plot.
%% 
% The following figure shows the PID Tuner dialog with the initial design:
%
% <<../html_extra/scdspeedctrlpidblock/pid_initialtuner.png>>

%% Displaying PID Parameters
% Click the *Show parameters* arrow to view controller parameters P and I,
% and a set of performance and robustness measurements.  In this example,
% the initial PI controller design gives a settling time of 2 seconds,
% which meets the requirement.   
%% 
% The following figure shows the parameter and performance tables:
%
% <<../html_extra/scdspeedctrlpidblock/pid_newtuner.png>>

%% Adjusting PID Design in the PID Tuner
% The overshoot of the reference tracking response is about 8 percent.
% Because the response performance is limited in many systems with time
% delays, you need to slow down response speed to reduce overshoot. Move
% the response time slider to the left to increase the closed loop response
% time.  Notice that when you adjust response time, the response plot and
% the controller parameters and performance measurements update.      
%% 
% The following figure shows an adjusted PID design with an overshoot of
% zero and a settling time of 4 seconds.  The designed controller
% effectively becomes an integral-only controller.
%
% <<../html_extra/scdspeedctrlpidblock/pid_finaltuner.png>>

%% Completing the Design in the Extended Design Mode
% To reduce the overshoot while maintaining the settling time of 2 seconds,
% you must tradeoff between controller performance (measured by settling
% time) and robustness (measured by overshoot).  You can perform such a
% trade-off in the *Extended* design mode of the PID Tuner.  
%
% To switch to the *Extended* design mode, select *Extended* in the *Design
% Mode* dropdown menu in the toolbar.  The following figure shows the PID
% Tuner in the *Extended* design mode with the integral only controller
% designed in the previous section:      
%%
% <<../html_extra/scdspeedctrlpidblock/pid_initialextendedtuner.png>>
%
% There are two sliders in the *Extended* design mode.  You can adjust
% performance with the *Bandwidth* slider.  Large bandwidth results in fast
% response.  You can also adjust robustness with the *Phase margin* slider.
% Large phase margin results in small overshoot.  Move around both sliders
% to achieve the settling time of 2 seconds and zero overshoot. One way to
% achieve this is   
%% 
% * Bandwidth of 1.23 rad/sec
% * Phase margin of 72 degree
%% 
% The following figure shows the PID Tuner with these settings:
%%
% <<../html_extra/scdspeedctrlpidblock/pid_finalextendedtuner.png>>

%% Writing the Tuned Parameters to PID Controller Block
% After you are happy with the controller performance on the linear plant
% model, you can test the design on the nonlinear model.  To do this, click
% *Apply* in the PID Tuner.  This action writes the parameters back 
% to the PID Controller block in the Simulink model.
%% 
% The following figure shows the updated PID Controller block dialog:
%
% <<../html_extra/scdspeedctrlpidblock/pid_updatedblockdialog.png>>

%% Completed Design
% The following figure shows the response of the closed-loop system:
%%
% <<../html_extra/scdspeedctrlpidblock/pid_analysisresp.png>>
%
% The response shows that the new controller meets all the design
% requirements.     
%%
% You can also use the SISO Compensator Design Tool to design the PID
% Controller block.  When the PID Controller block belongs to a multi-loop
% design task.  See the demo <scdspeedctrldespad.html "Single Loop
% Feedback/Prefilter Compensator Design">. 

bdclose('scdspeedctrlpidblock')
displayEndOfDemoMessage(mfilename)
