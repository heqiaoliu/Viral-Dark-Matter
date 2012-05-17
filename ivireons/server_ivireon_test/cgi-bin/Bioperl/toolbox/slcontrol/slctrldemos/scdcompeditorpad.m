%% Tuning Simulink(R) Blocks in the Compensator Editor
%
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2009/11/09 16:35:36 $

%% Opening the Model
% The following example is the speed control of a spark ignition 
% engine. The initial compensator has been designed in a fashion similar to the
% demo entitled
% <scdspeedctrldespad.html "Single Loop Feedback/Prefilter Design">. 
% Take a few moments to explore the model. 
%%
% <matlab:open_system('scdspeedctrl') Open the engine speed control model>
open_system('scdspeedctrl');
%%
%% Introduction
% This demonstration introduces the use of the *Compensator Editor* when
% tuning Simulink(R) blocks.  When tuning a block in Simulink there are two
% representations available in a SISO Design Task.  These representations
% are the block parameters and the pole/zero/gain representations.  For
% example in the speed control demonstration there is a PID controller with
% filtered derivative |scdspeedctrl/PID Controller|:
%%
% <<../html_extra/scdcompedit/pidcontroller.png>>
%%
% This block implements the traditional PID with filtered derivative as:
%%
% $$G(s) = P + {I \over s} + {D s \over Ns+1}$$
%% 
% In this block |P|, |I|, |D|, and |N| are the parameters that are
% available for tuning.  Another approach is to reformulate the block
% transfer function to be in the form of poles and zeros:
%%
% $$G(s) = {Ps(Ns+1) + I(Ns+1) + D s^s \over s(Ns+1)} = {K(s^2+2 \zeta \omega_n+w_n^2) \over s(s + z)}$$
%%
% This formulation of poles, zeros, and gains allows for direct graphical
% tuning on design plots such as Bode, root locus, and Nichols plots.  Additionally the
% SISO Design Task allows for both representations to be tuned using the
% *Compensator Editor*. The tuning of both representations is available for all
% <matlab:scdguihelp('supported_tunable_blocks'); supported>
% blocks in Simulink(R) Control Design(TM).

%% Creating a SISO Design Task
% In this example a Simulink Compensator Design Task will be used to
% create a SISOTOOL Design Task to tune the compensators in this feedback system.
% Launch a preconfigured task by double clicking on the subsystem in the
% lower left hand corner of the model to load a preconfigured Simulink
% Compensator Design Task.

%% Exploring the Compensator Editor Tab
% The representations of PID compensator can be viewed and edited using the
% *Compensator Editor* tab.  The upper portion of this panel allows for all
% compensators to be viewed and edited.  When selecting this tab for the
% first time the pole and zero representation is first shown in the lower
% tabbed panel as shown below:
%%
% <<../html_extra/scdcompedit/polezeroeditor.png>>
%% 
% Use this panel to add and remove poles and zeros from the compensator.
% Since the PID with filtered derivative is fixed in structure number of poles and 
% zeros will be limited to having up 2 zeros, 1 pole, and an integrator at
% |s = 0|.
%%
% The second panel labeled *Parameter* allows the |P|, |I|, |D|, and |N|
% parameters to be independently tuned.  This panel is shown below:
%%
% <<../html_extra/scdcompedit/parametereditor.png>>
%%
% Use the *Value* column to specify new values and use the *Slider* column
% to interactively tune the gains.  By changing these gains the following
% will be updated:
%%
% * The open and closed-loop responses configured in the *Graphical Tuning*
% tab
% * The responses such as closed loop step responses specified in the
% *Analysis Plots* tab
% * The poles, zeros, and gains seen in the *Pole/Zero* tab
%% 
% Use the *Compensator Editor* tab to tune the response of the control
% system.

%% Completed Design
% The design requirements in the demo <scdspeedctrldespad.html "Single Loop
% Feedback/Prefilter Design"> can be met with the following controller
% parameters
%%
% * |scdspeedctrl/PID Controller| has parameters:
%%
%           P = 0.0012191
%%
%           I = 0.0030038
%%
% * |scdspeedctrl/Reference Filter|:
%%
%           Numerator = 10;
%%
%           Denominator = [1 10];
%%
% The responses of the closed loop system are shown below:
%%
% <<../html_extra/scdspeedctrl/analysisresp.png>>

%% Writing the Design to Simulink
% You can then test the design on the nonlinear model by clicking the
% *Update Simulink Block Parameters* button.  This writes the parameters back to
% the Simulink model.
bdclose('scdspeedctrl')
displayEndOfDemoMessage(mfilename)