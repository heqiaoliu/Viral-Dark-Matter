%% Tuning Custom Masked Subsystems
%
% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2009/11/09 16:35:38 $

%% Introduction
% This demo illustrates how to enable custom masked subsystems in a
% Simulink(R) Compensator Design Task.  Once configured a block can be used in
% the same way as any
% <matlab:scdguihelp('supported_tunable_blocks'); supported blocks> in Simulink Control Design.

%% Lead-Lag Library Block
% The example configured lead-lag block is in the library |scdexblks|
open_system('scdexblks');

%%
% The lead-lag block implements a compensator element with a single zero
% and pole.  There are three parameters |K|, |wz|, and |wp| which are configured
% in the block dialog:
%%
% <<../html_extra/scdcustomblock/blockdialog.png>>
%%
% The parameters are then used inside the mask create an equivalent transfer function:
%%
% $$G(s) = K {{{s \over {wz}} + 1} \over {{s \over wp} + 1}}$$

%% Configuring the Subsystem for a Simulink(R) Compensator Design Task 
% The configuration of a masked subsystem for Simulink Control Design
% is specified in a configuration function.  In this demonstration the
% configuration function has been written in the M-Function
% <matlab:edit('scdleadexample') scdleadexample.m>.  This configuration
% function specifies that:
%%
% * There is only a maximum of 1 pole allowed (MaxPoles Constraint)
% * There is only a maximum of 1 zero allowed (MaxZeros Constraint)
% * The gain is tunable (isStaticGainTunable Constraint)
%% 
% The configuration is registered in the subsystem using the |SCDConfigFcn|
% parameter for the block.  This function can be set using the command
% |set_param| or through the *Block Properties* dialog which is accessed
% by right clicking on any subsystem.
%%
% <<../html_extra/scdcustomblock/setscdconfigfcn.png>>
%%
% After setting the SCDConfigFcn the block is now ready to be
% used in a Simulink Compensator Design Task.

%% Example
% The lead-lag block can be used to tune the feedback loop in demo entitled
% <scdspeedctrldespad.html "Single Loop Feedback/Prefilter Design">.  To
% begin the compensator design process:
%%
% *Step 1* Start a new Simulink Compensator Design Task for the model
% <matlab:open_system('scdspeedctrlleadlag') scdspeedctrlleadlag> 
% by choosing *Tools -> Control Design -> Compensator
% Design* from the Simulink model.
%% 
% *Step 2* Select the following block to tune by clicking the *Select Blocks...*
% button on the *Tunable Blocks* panel:
%% 
% * |scdspeedctrlleadlag/Feedback Controller/Lead-Lag Controller|
%%
load_system('scdspeedctrlleadlag')
open_system('scdspeedctrlleadlag/Feedback Controller')
%%
% The lead-lag block will show up inside the subsystem |Feedback
% Controller|.
%%
% <<../html_extra/scdcustomblock/blockselection.png>>
%% 
% *Step 3* Select the closed loop signals by right clicking and using the
% Linearization Points menu:
%%
% * Input: |scdspeedctrlleadlag/Speed Reference| output port 1
%%
% * Output |scdspeedctrlleadlag/Speed Output| output port 1
%%
% *Step 4* In the *Operating Points* panel select *Default
% Operating Point*.
%%
% *Step 5* Click on the *Tune Blocks...* button to launch the Design
% Configuration Wizard.  
%%
% To tune the Open Loop at the outport 1 of |scdspeedctrlleadlag/Feedback
% Controller/Lead-Lag Controller|, select Open Loop 1 for Plot 1 and select
% Open-Loop Bode as its Plot Type.
%%
% In the wizard select Closed Loop 1 for Plot 2 and select Closed-Loop Bode
% as its Plot Type.
% 
%%
% In step 2 of the wizard select Step responses for Plot 1 and Plot 2.
% Then in the Contents of Plots table
%%
% * Select Plot 1 for the |Closed Loop from /Speed Reference| to scdspeedctrl/Speed
% Output|

%%
% After completing the wizard a *SISO Design Task* node is created.  Use this
% task node to complete the design.  Go to the *Compensator Editor* tab to
% tune the lead-lag compensator.  The block parameters for the lead-lag
% block can now be tuned.
%
% <<../html_extra/scdcustomblock/compeditor.png>>

%% Completed Design
% The design requirements for the reference step response in the demo
% <scdspeedctrldespad.html "Single Loop Feedback/Prefilter Design"> can be
% met with the following controller parameters
%%
% * |scdspeedctrlleadlag/Feedback Controller/Lead-Lag Controller| has parameters:
%%
%           Gain = 0.0075426
%%
%           Zero Frequency (rad/s) = 2
%%
%           Pole Frequency (rad/s) = 103.59
%%
% The responses of the closed loop system are shown below:
%%
% <<../html_extra/scdcustomblock/clresponse.png>>

%% Writing the Design to Simulink
% You can then test the design on the nonlinear model by clicking the
% *Update Simulink Block Parameters* button.  This writes the parameters
% back to the Simulink model.

bdclose('scdexblks')
bdclose('scdspeedctrlleadlag')
displayEndOfDemoMessage(mfilename)