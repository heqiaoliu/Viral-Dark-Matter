%% Regulating Pressure in a Drum Boiler
% Copyright 2005-2007 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2007/12/14 15:27:32 $

%% 
% This demo illustrates how to use Simulink(R) Control Design(TM), using a drum
% boiler as an example application. Using the operating point search
% function, we illustrate model linearization as well as subsequent state
% observer and LQR design. 

%%
% In this drum-boiler model, the control problem is to regulate boiler
% pressure in the face of random heat fluctuations from the furnace by
% adjusting the feedwater flow rate and the nominal heat applied. For this
% example, 95% of the random heat fluctuations are less than 50% of the
% nominal heating value. This is not unusual for a furnace-fired boiler.  

%% Step 1: Initialize and Open the Model
% To begin, let's open the Simulink(R) model.
Boiler_Demo
 
%%
% The boiler control model's pre-load function initializes the controller sizes. This is 
% necessary because to compute the operating point and linear model, the 
% Simulink model must be executable. Note that u0, y0 are set after the 
% operating point computation and are thus initially set to zero. The observer 
% and regulator are computed during the controller design step and are 
% also initially set to zero. 

%% Step 2: Find a Nominal Operating Point and Linearize the Model
% The model's initial state values are defined in the Simulink model. Using 
% these state values find the steady state operating point using the findop function. 

%%
% First, we'll create an operating point specification where the state values are known.
opspec = operspec('Boiler_Demo');
opspec.States(1).Known = 1;
opspec.States(2).Known = 1;
opspec.States(3).Known = [1;1];

%%
% Now, let's adjust the operating point specification to indicate that the inputs must be computed and that they are lower bounded.
opspec.Inputs(1).Known = [0;0];     %Inputs unknown
opspec.Inputs(1).Min = [0;0];   %Input minimum value

%%
% Finally, we'll add an output specification to the operating point specification; this is necessary to ensure that the output operating point is computed during the solution process. 
opspec = addoutputspec(opspec,'Boiler_Demo/Boiler',1);
opspec.Outputs(1).Known = 0;    %Outputs unknown
opspec.Outputs(1).Min = 0;      %Output minimum value

%%
% Next, we compute the operating point and generate a report.
[opSS,opReport] = findop('Boiler_Demo',opspec);

%%
% Before linearizing the model around this point, we'll specify the input and
% output signals for the linear model. 

%%
% First we specify the input points for linearization.
Boiler_io(1)=linio('Boiler_Demo/Sum',1,'in');
Boiler_io(2)=linio('Boiler_Demo/Demux',2,'in');

%%
% Now we specify the open loop output points for linearization.
Boiler_io(3)=linio('Boiler_Demo/Boiler',1,'out','on');
setlinio('Boiler_Demo',Boiler_io);

%% 
% In this code, we find a linear model around the chosen operating point.
Lin_Boiler = linearize('Boiler_Demo',opSS,Boiler_io);

%% 
% Finally, using the minreal function, make sure that the model is a
% minimum realization, (e.g., there are no pole zero cancellations).
Lin_Boiler = minreal(Lin_Boiler);

%% Step 3: Designing a Regulator and State Observer
% Using this linear model, we will design an LQR regulator and Kalman filter state 
% observer. First find the controller offsets to make sure that the controller 
% is operating around the chosen linearization point by retrieving the computed 
% operating point. 
u0 = opReport.Inputs.u;
y0 = opReport.Outputs.y;

%%
% Now design the regulator using the lqry function. Note that tight regulation 
% of the output is required while input variation should be limited. 
Q = diag(1e8);                  %Output regulation
R = diag([1e2,1e6]);            %Input limitation
[K,S,E] = lqry(Lin_Boiler,Q,R);

%%
% Design the Kalman state observer using the kalman function. Note that for 
% this example the main noise source is process noise.  It enters the system 
% only through one input, hence the form of G and H. 
[A,B,C,D] = ssdata(Lin_Boiler);
G = [B(:,1)];
H = [0];
QN = 1e4;
RN = 1e-1;
NN = 0;
[Kobsv,L,P] = kalman(ss(A,[B G],C,[D H]),QN,RN);

%% Step 4: Simulate and Test
% For the designed controller the process inputs and outputs are shown below. 
sim('Boiler_Demo')

%%
% Here is the feedwater actuation signal in kg/s
figSize = [0 0 360 240];
h = figure(1); plot(FeedWater.time/60,FeedWater.signals.values)
set(h,'color',[1 1 1])
set(h,'Position',figSize)
title('Feedwater flow rate [kg/s]');
ylabel('Flow [kg/s]')
xlabel('time [min]')
grid on

%%
% This illustrates the heat actuation signal in kJ:
h = figure(2); plot(Heat.time/60,Heat.signals.values/1000)
set(h,'color',[1 1 1])
set(h,'Position',figSize)
title('Applied heat [kJ]');
ylabel('Heat [kJ]')
xlabel('time [min]')
grid on

%% 
% The next figure shows the heat disturbance in kJ. Note that the
% disturbance varies by as much as 50% of the nominal heat value.
h = figure(3); plot(HeatDist.time/60,HeatDist.signals.values/1000)
set(h,'color',[1 1 1])
set(h,'Position',figSize)
title('Heat disturbance [kJ]');
ylabel('Heat [kJ]')
xlabel('time [min]')
grid on

%%
% The figure below shows the corresponding drum pressure in kPa. Notice 
% how the pressure varies by about 1% of the nominal value even though 
% the disturbance is relatively large.  
h =figure(4); plot(DrumPressure.time/60,DrumPressure.signals.values)
set(h,'color',[1 1 1])
set(h,'Position',figSize)
title('Drum pressure [kPa]');
ylabel('Pressure [kPa]')
xlabel('time [min]')
grid on

bdclose('Boiler_Demo')
displayEndOfDemoMessage(mfilename)