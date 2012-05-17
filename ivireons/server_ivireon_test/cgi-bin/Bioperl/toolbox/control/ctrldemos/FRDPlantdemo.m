%% Compensator Design for Systems Represented by Frequency Response Data 
% This demo shows the design of a compensator for a plant model defined by
% frequency response data (FRD) using the interactive tools available in
% the SISO Design Tool.
%

% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.3 $  $Date: 2010/02/08 22:29:43 $

%% Acquiring a Frequency Response Data (FRD) Plant Model
% Non-parametric representations of plant models, such as frequency response
% data, are often used for analysis and control design. These
% FRD models are typically obtained from:
%
% 1) Signal analyzer hardware that perform frequency domain measurements on
% systems.
%
% 2) Non-parametric estimation techniques using the systems time response
% data. You can use the following products to estimate FRD models:
%
%
% Simulink(R) Control Design(TM)
%
% * Function: <matlab:doc('frestimate') frestimate>
% * Demo: <../../../slcontrol/slctrldemos/html/scdenginepad.html "Frequency Response Estimation Using Simulation-Based Techniques">.
%
% Signal Processing Toolbox(TM)
%
% * Function: <matlab:doc('tfestimate') tfestimate>.
%
% System Identification Toolbox(TM)
%
% * Functions: <matlab:doc('etfe') etfe>, <matlab:doc('spa') spa>,
% <matlab:doc('spafdr') spafdr>
%
% This example demonstrates the design of a compensator for a plant
% described by frequency response data.

%% Problem Statement
% In this example, you control engine speed by actuating the engine
% throttle angle in the following model.
%
% <<../Figures/FRDPlantDemo_Fig01.png>>


%%
% The design requirements are:
%
% * zero steady-state error step reference speed changes
% * phase margin > 60 degrees
% * gain margin > 20 dB.

%%
% The frequency response of the engine is already estimated and stored in
% the AnalyzerData variable in the file FRDPlantDemo.mat. First, load the
% data:
load FRDPlantDemoData.mat

%%
% The variable AnalyzerData contains the frequency response information of
% the engine.
AnalyzerData

%%
% To use this data in the Control System Toolbox(TM), create an FRD model
% object: 

FRDPlant = frd(AnalyzerData.Response,AnalyzerData.Frequency,'Unit',AnalyzerData.FrequencyUnits);


%% Designing the Compensator
% Next, start the SISO Design Tool.
%
% |>> sisotool({'bode','nichols'},FRDPlant)|
%
% The SISO Design Tool opens with both a Bode and Nichols open-loop
% editors.
%
% <<../Figures/FRDPlantDemo_Fig02.png>>

%%
% You can design the compensator by shaping the open-loop frequency
% response in either the Bode or Nichols editor. In these editors, you can
% interactively tune of the gain, poles and zeros of the compensator. 
%
% To satisfy the tracking requirement of zero steady-state error, add an
% integrator to the compensator using the bode editor's
% right-click "Add Pole/Zero" menu of the Bode editor. To meet the gain and
% phase margin requirements, add a zero. Modify the location of the
% zero and the gain of the compensator until you satisfy the margin
% requirements.
%
% The following figure shows a possible compensator design that meets all
% of the requirements.
%
% <<../Figures/FRDPlantDemo_Fig03.png>>

%%
% This compensator design, which is a PI controller, achieves a 20.7 dB gain margin and a
% 70.8 deg phase margin. 
%
% $$ C(s) = \frac{0.001(s+4)}{s}. $$
%
% You can export the designed compensator to the workspace using the
% "File->Export..." menu item.



%% Validating the Design
% For the final step in the design process, validate the performance by
% implementing the design on the engine. In this example, a nonlinear
% representation of the engine in Simulink(R) is used to simulate the
% response.
%
% Plot the response of the engine speed to a reference speed
% command change from 2000 to 2500 RPM:

plot(EngineStepResponse.Time,EngineStepResponse.Speed)
title('Engine Step Response')
xlabel('Time (s)')
ylabel('Engine Speed (RPM)')

%%
% The response shows zero steady-state error and well behaved transients
% with the following metrics.

stepinfo(EngineStepResponse.Speed,EngineStepResponse.Time)

displayEndOfDemoMessage(mfilename)