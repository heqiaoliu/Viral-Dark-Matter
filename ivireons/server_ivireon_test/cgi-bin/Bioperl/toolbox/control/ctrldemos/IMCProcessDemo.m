%% Internal Model Control Design for a Chemical Reactor Plant
% In process control applications, model-based control systems are often
% used to track setpoints and reject load disturbances.  This example
% illustrates how to design a compensator in a IMC structure for series
% chemical reactors, using the IMC tuning feature available in SISO Design
% Tool.  

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2009/11/09 16:22:06 $

%% Mathematical Models for the Series Chemical Reactors
% <<../Figures/IMCProcessDemoFigures_01.png>>

%%
% *PLANT DESCRIPTION*
%
% The chemical reactor system, comprised of two well mixed tanks, is shown
% in the above figure.  The reactors are isothermal and the reaction in
% each reactor is first order on component A: 
%
% $$r_{A} = -kC_{A}$$
%
% Material balance is applied to the system to generate the dynamic model
% for the system.  The tank levels are assumed to stay constant because of
% the overflow nozzle and hence there is no level control involved.  
%
% For details about this plant, see Example 3.3 in Chapter 3 of "Process
% Control: Design Processes and Control systems for Dynamic Performance" by
% Thomas E. Marlin.  

%%
% *EQUATIONS*
%
% We have the following differential equations to describe component
% balances:
%
% $$V\frac{dC_{A1}}{dt} = F(C_{A0} -C_{A1}) - VkC_{A1}$$ 
%
% $$V\frac{dC_{A2}}{dt} = F(C_{A1} -C_{A2}) - VkC_{A2}$$
%
% At steady state, from
%
% $$ \frac{dC_{A1}}{dt} = 0 $$ 
%
% $$ \frac{dC_{A2}}{dt} = 0 $$
%
% we have the following material balances:
%
% $$F^*(C_{A0}^* - C_{A1}^*) - VkC_{A1}^* = 0$$
%
% $$F^*(C_{A1}^* - C_{A2}^*) - VkC_{A2}^* = 0$$
%
% where variables with * denote steady state values.  
%
% By substituting the following design specifications and reactor
% parameters, 
% 
% $$F^*$$ = 0.085 $$mole/min$$
%
% $$C_{A0}^*$$ = 0.925 $$mol/min$$
%
% $$V$$ = 1.05 $$m^3$$
%
% $$k$$ = 0.04 $$min^{-1}$$
%
% we obtain the steady state values of the concentrations in two reactors:
% 
% $$C_{A1}^* = KC_{A0}^* = 0.6191 mol/m^3$$
%
% $$C_{A2}^* = K^2C_{A0}^* = 0.4144 mol/m^3$$
%
% where
%
% $$K = \frac{F^{*}}{F*+Vk} = 0.6693$$

%%
% *CONTROL OBJECTIVE*
%
% The outlet concentration of reactant from the second reactor |CA2| should
% be maintained by the molar flowrate of the reactant |F| entering the
% first reactor in the presence of disturbance in feed concentration |CA0|.
%
% In this control design problem, the plant model is  
%
% $$ \frac{C_{A2}(s)}{ F(s)}$$    
%
% and the disturbance model is 
%
% $$ \frac{C_{A0}(s)}{C_{A2}(s)}$$
%
% In the next section we will discuss how these two models are obtained.

%% Linear Plant Models
% This chemical process can be represented in the following diagram with
% LTI blocks.  
%
% <<../Figures/IMCProcessDemoFigures_02.png>>
%
% where
% 
% $$ G_{A1} = \frac{C_{A1}(s)}{C_{A0}(s)} = \frac{0.6693}{8.2677s+1}$$
%
% $$ G_{F1} = \frac{C_{A1}(s)}{F(s)} = \frac{2.4087}{8.2677s+1}$$ 
%
% $$ G_{A2} = \frac{C_{A2}(s)}{C_{A1}(s)} = \frac{0.6693}{8.2677s+1}$$
%
% $$ G_{F2} = \frac{C_{A2}(s)}{F(s)} = \frac{1.6118}{8.2677s+1}$$ 
%
% Based on the block diagram, the plant and disturbance models are obtained
% as follows: 
%
% $$ \frac{C_{A2}(s)}{ F(s)} = G_{F1}G_{A2} + G_{F2} = \frac{13.3259s+3.2239}{(8.2677s+1)^2} $$
% 
% $$ \frac{C_{A2}}{C_{A0}} = G_{A1}G_{A2} = \frac{0.4480}{(8.2677s+1)^2}$$

%% IMC Design with Automatic Tuning
% We will now design the compensator in an IMC structure in SISO Design
% Tool.   

%%
% *Step 1: Open SISO Design Tool*
%
% At the MATLAB(R) command prompt, type |sisotool| and the Controls and
% Estimation Tools Manager opens. 
%
% <<../Figures/IMCProcessDemoFigures_03.png>>

%%
% *Step 2: Select IMC as the Control Architecture*
%
% * Click on the Control Architecture... button
% * Select Configuration 5 for IMC structure from the left panel in the
% Control Architecture dialog.  
%
% <<../Figures/IMCProcessDemoFigures_04.png>>
%
% * Click OK to select this configuration. The Controls and Estimation
% Tools Manager should look like the following figure
%
% <<../Figures/IMCProcessDemoFigures_05.png>>

%%
% *Step 3: Load System Data into SISO Design Tool*
%
% First we create the following LTI models in MATLAB command prompt:
s = tf('s');
G1 = (13.3259*s+3.2239)/(8.2677*s+1)^2;
G2 = G1;
Gd = 0.4480/(8.2677*s+1)^2;

%%
% Note: G1 is the real plant used in controller evaluation; G2 is an
% approximation of the real plant and it is used as the predictive model in
% the IMC structure. G1 = G2 means that there is no model mismatch.  Gd is
% the disturbance model.

%%
% Then we load the system data into the Controls and Estimation Tools
% Manager by clicking on the |System Data...| button.  The |System Data|
% Dialog should look like what is shown below after G1, G2 and Gd are
% specified in the Data column:  
%%
% <<../Figures/IMCProcessDemoFigures_06.png>>

%%
% *Step 4: Tune the IMC Compensator C*
%
% The open loop step response of G1 is shown below:
%
% step(G1)
%
% <<../Figures/IMCProcessDemoFigures_13.png>>
%

%%
% Right-click on the plot and select the |Characteristics -> Rise Time|
% submenu. Finally, click on the blue dot marker.  The resulting plot is
% shown below: 
%
% <<../Figures/IMCProcessDemoFigures_07.png>>
%
% The step plot shows the rise time is about 25 seconds and we want the
% closed loop response becomes faster after the IMC compensator is tuned. 
%
% To tune the IMC compensator, click on the Automated Tuning on the
% Controls and Estimation Tools Manager and select |Internal Model Control
% (IMC) Tuning| as the design method.  It should appear like the diagram
% shown below:
%
% <<../Figures/IMCProcessDemoFigures_08.png>>
%
% Select a closed-loop time constant of 2 and specify 2 as the desired
% compensator order. Click on the Update Compensator button to obtain the
% IMC compensator C.  
%
% <<../Figures/IMCProcessDemoFigures_09.png>>

%%
% *Step 5: Check Closed Loop Step Response*
%
% To look at the closed loop step response, click on the Analysis Plots on
% the Controls and Estimation Tools Manager, select |Step| as the plot type
% for Plot 1 and make |Closed Loop r to y| as the content of Plot 1:
%
% <<../Figures/IMCProcessDemoFigures_10.png>>
%
% The step response plot looks like: 
%
% <<../Figures/IMCProcessDemoFigures_11.png>>
%

%% Control Performance with Model Mismatch
% In the previous section, we assume G1 is equal to G2. In practice they
% are often different and the controller needs to be robust enough to track
% setpoints and reject disturbances.  In this section we will change the
% real plant G1 but keep the predictive model G2 and IMC compensator C
% untouched.  
%
% We will create model mismatches between G1 and G2 and re-examine control
% performance in MATLAB command prompt with the presence of both set point
% change and load disturbance.   

%%
% *Step 1: Export IMC Compensator C from SISO Design Tool to MATLAB Workspace*
%
% Go to the |File| menu of the Controls and Estimation Tools Manager and
% select |Export...| menu item.  It opens the |SISO Tool Export| dialog:
%
% <<../Figures/IMCProcessDemoFigures_12.png>>
%
% Select |Compensator C| and click on the |Export to Workspace| button.  An
% LTI object C is shown up in MATLAB workspace afterwards.

%%
% *Step 2: Convert IMC Structure to Classic Feedback Control Structure*
%
% IMC structure can be converted into a classic feedback control structure
% with the controller in the feedforward path and unit feedback. The new
% controller C_new is obtained as follows: 
C = zpk([-0.121 -0.121], [-0.242, -0.466], 2.39);
C_new = feedback(C,G2,+1)

%%
% *Step 3: Define G1 That Differs From G2* 
%
% So far we assume that G2 was a perfect model of the real plant G1. Now
% let us consider two possible ways G1 can differ from G2 due to imperfect
% modeling.  

%%
% No Model Mismatch (G1 is the same as G2):
G1p = (13.3259*s+3.2239)/(8.2677*s+1)^2;

%%
% G1's time constant is changed by 5%:
G1t = (13.3259*s+3.2239)/(8.7*s+1)^2;

%%
% G1's gain is increased by 3 times:
G1g = 3*(13.3259*s+3.2239)/(8.2677*s+1)^2;

%%
% *Step 4: Evaluate Performance of Set-Point Tracking and Load Disturbance
% Rejection*  
%
% * Set Point Tracking
step(feedback(G1p*C_new,1),feedback(G1t*C_new,1),feedback(G1g*C_new,1))
legend('No Model Mismatch','Mismatch in Time Constant','Mismatch in Gain')

%%
% * Load Disturbance Rejection
step(Gd*feedback(1,G1p*C_new),Gd*feedback(1,G1t*C_new),Gd*feedback(1,G1g*C_new))
legend('No Model Mismatch','Mismatch in Time Constant','Mismatch in Gain')

%%
% The above figures show that our controller is fairly robust to
% uncertainties in the plant parameters.   

%%
displayEndOfDemoMessage(mfilename)

