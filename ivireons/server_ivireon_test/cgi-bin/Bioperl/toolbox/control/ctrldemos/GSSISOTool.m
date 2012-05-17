%% Getting Started with the SISO Design Tool
%

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $  $Date: 2009/07/18 15:50:06 $

%% Compensator Design Task and the SISO Design Tool
% The SISO Design Tool facilitates the compensator design process by
% providing interactive and automated tools to tune compensators for a
% feedback control system. The SISO Design Tool allows: 
%
% 1) The design problem to be setup graphically by defining the control
% design requirement on time, frequency, and pole/zero response plots.
%
% 2) Tuning the compensator with:
%
% * automated design methods such as Ziegler Nichols, IMC, and LQG.
% * graphically tuning poles and zeros on design plots such as Bode and root locus.
% * optimization to meet time and frequency-domain requirements using
%  Simulink(R) Design Optimization(TM).
%
% 3) While tuning the compensators, the closed-loop and open-loop responses
% are dynamically updated to display the performance of the control system.
%
% The design process using the SISO Design Tool will be illustrated with an
% example problem.


%% Compensator Design Problem Example 
% For this example we will design a compensator for the system

%%
% $$ G(s) = \frac{1}{s+1} $$
%
% with the following design requirements:
%
% * Zero steady state error with respect to a step input.
% * 80% rise time < 1 second.
% * Settling time < 2 seconds.
% * Maximum overshoot < 20%.
% * Open-loop crossover constraint of less than 5 rad/s.


%% Launching the SISO Design Tool and Configuring Design Objectives
% For this example we will use the standard feedback structure with the
% controller in the forward path which happens to be the default feedback
% structure when launching the SISO Design Tool. To launch the SISO Design
% Tool with the specified plant G type
%
% |>> sisotool(tf(1,[1,1]))|
%
% This will bring up two windows. The first window is Control and
% Estimation Tools Manager (CETM) 
%
% <<../Figures/GSSISOToolCETMStep1.png>>

%%
% and the second window is the SISO Design graphical editors
%
% <<../Figures/GSSISOToolDesignPlotsStep1.png>>

%%
% In the CETM the *SISO Design Task* node contains tabbed panels which are
% used to configure the compensator design options as well as manipulate
% the compensators. For complete details of the functionality for each of
% the panels refer to the documentation.

%%
% For this design example we will use the root-locus plot and open-loop
% Bode plot for graphically tuning the compensator and validate the design
% by viewing the step response.
%
% To view the closed-loop step response, click on the *Analysis Plot* tab in
% the CETM. Now configure the plot by selecting "Step" for the first plot
% and checking the first check box for the response "Closed-Loop r to y". This
% will bring up the SISO Tool Viewer.
%
% <<../Figures/GSSISOToolCETMStep2.png>>
%%
% <<../Figures/GSSISOToolAnalysisPlotsStep2.png>>

%%
% Now add the time domain design requirements to the step response plot by right
% clicking on the axis and selecting the *Design Requirements -> New* menu item.
% We will use the "Step response bounds" design requirement type to specify the 
% rise time, settling time and overshoot requirements.


%%
% <<../Figures/GSSISOToolStepConstraint.png>>

%%
% We can now use this time response with its requirements to view the
% performance of the compensator design.
%
% <<../Figures/GSSISOToolAnalysisPlotsStep3.png>> 

%%
% To specify the frequency domain crossover requirement, right click the
% bode axis in the SISO Design window and select the *Design Requirement->New* 
% menu item and specify an upper gain limit.
%
% <<../Figures/GSSISOToolCrossOverConstraint.png>> 


%% 
% Now that the problem has been set up we will begin to design the
% compensator to satisfy the problem specifications.

%% Tuning Compensators
% Compensators can be manually tuned from the graphical editors or the 
% *Compensator Editor* tab of the CETM. For this example we will use the
% graphical editors to tune the compensator. To begin the design an
% integrator will be added to achieve zero steady state error to a step
% input. To add the integrator to the compensator use the right-click menu
% on the root-locus plot and select *Add Pole/Zero->Integrator*. To create
% a desirable shape for the root locus plot we will add a zero at
% approximately -2. To add the zero, use the right-click menu on the
% root-locus plot and select *Add Pole/Zero->Real Zero* menu item and then
% left-click at approximately -2 on the real axis of the root locus
% plot. Now in the bode plot adjust the open-loop gain by clicking and
% dragging the curve on the magnitude plot such that the cross-over and time
% domain constraints are satisfied.
%%
% <<../Figures/GSSISOToolDesignPlotsStep4.png>>

%%
% <<../Figures/GSSISOToolAnalysisPlotsStep4.png>>


%%
% To view the compensator go to *Compensator Editor* tab. Note that the steps
% performed in the graphical tuning plots to tune the compensator can also
% be accomplished from this panel. 
%
% <<../Figures/GSSISOToolCETMStep4.png>>



%% Automated Tuning of Compensators
% In addition to the manual tuning interfaces, the SISO Design Tool also
% provides the following automated tuning algorithms:
%
% * Use the *PID tuning*, *IMC tuning*, and *LQG synthesis* options in the
% *Automated Tuning* panel to compute initial parameters for the
% compensators based on tuning parameters such as closed-loop time
% constants.  See the demo
% <autotunedemo.html "Automated Controller Design in the SISO Design Tool">.
% * Use the *Optimization based tuning* option in the *Automated Tuning*
% panel (requires Simulink Design Optimization) to tune the compensators using
% both time and frequency domain design requirements.  See the demo
% <../../../sldo/sldodemos/optim/html/dcmotor_demopad.html "DC Motor Controller Tuning">.


%% Summary
% Using the SISO Design Tool we were able to successfully design a
% compensator such that all of the specified design requirements were
% satisfied. The tool facilitated the heuristic process of compensator
% design by providing an interactive and visual environment for
%
% * Specifying the design requirements
% * Tuning the compensator, and
% * Evaluating the performance of the design.


displayEndOfDemoMessage(mfilename)
 
