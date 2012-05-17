%% Designing PID Controller in Simulink with Estimated Frequency Response
% This demo shows how to design a PI controller with frequency response
% estimated from a plant built in Simulink. This is an alternative PID
% design workflow when the linearized plant model is invalid for PID
% design (for example, when the plant model has zero gain).

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/05/10 17:56:30 $

%% Opening the Model
% Take a few moments to explore the model. 
%%
% <matlab:open_system('scdenginectrlpidblock') Open the engine control model>
mdl = 'scdenginectrlpidblock';
open_system(mdl)

%%
% The PID loop includes a PI controller in parallel form that manipulates
% the throttle angle to control the engine speed. The PI controller has
% default gains that makes the closed loop system oscillate. We want to
% design the controller using the PID Tuner that is launched from the PID
% block dialog.
open_system([mdl '/Engine Speed (rpm)'])
sim(mdl);

%% PID Tuner Obtaining a Plant Model with Zero Gain From Linearization
% In this example, the plant seen by the PID block is from throttle angle
% to engine speed. Linearization input and output points are already
% defined at the PID block output and the engine speed measurement
% respectively. Linearization at the initial operating point gives a plant
% model with zero gain.

% Hide scope
close_system([mdl '/Engine Speed (rpm)'])
% Obtain the linearization input and output points 
io = getlinio(mdl);
% Linearize the plant at initial operating point
linsys = linearize(mdl,io)

%%
% The reason for obtaining zero gain is that there is a triggered subsystem
% "Compression" in the linearization path and the analytical block-by-block
% linearization does not support events-based subsystems. Since the PID
% Tuner uses the same approach to obtain a linear plant model, the PID
% Tuner also obtains a plant model with zero gain and reject it during the
% launching process.

%%
% To launch the PID Tuner, open the PID block dialog and click Tune button.
% An information dialog shows up and indicates that the plant model
% linearized at initial operating point has zero gain and cannot be used to
% design a PID controller.
%
% <<../html_extra/scdenginectrlpidblock/pid_informationdialog.png>>

%%
% The alternative way to obtain a linear plant model is to directly
% estimate the frequency response data from the Simulink model, create
% an FRD system in MATLAB Workspace, and import it back to the PID Tuner
% to continue PID design.

%% Obtaining Estimated Frequency Response Data Using Sinestream Signals
% Sinestream input signal is the most reliable input signal for estimating
% an accurate frequency response of a Simulink® model using *frestimate*
% command. More information on how to use *frestimate* can be found in the
% demonstration <scdenginepad.html "Frequency Response Estimation Using
% Simulation-Based Techniques"> in Simulink Control Design demos.

%%
% In this example, we create a sine stream that sweeps frequency from 0.1
% to 10 rad/sec. Its amplitude is set to be 1e-3. You can inspect the
% estimation results using the bode plot.

% Construct sine signal
in = frest.Sinestream('Frequency',logspace(-1,1,50),'Amplitude',1e-3);
% Estimate frequency response
sys = frestimate(mdl,io,in); % this command may take a few minutes to finish
% Display Bode plot
figure;
bode(sys);

%% Designing PI with the FRD System in PID Tuner
% SYS is a FRD system that represents the plant frequency response at the
% initial operating point. To use it in the PID Tuner, we need to import it
% after the Tuner is launched. Open the PID block dialog and click Tune
% button again. When the information dialog shows up, click "Continue" to
% resume the launching process. After the PID Tuner is launched, an "Obtain
% Plant Model" dialog shows up and asks you to import a new plant model for
% PID design.
%
% <<../html_extra/scdenginectrlpidblock/pid_importdialog.png>>

%%
% Click the radio button in the middle, select "sys" from the list, and
% click "OK" to import the FRD system into the PID Tuner. The automated
% design returns a stabilizing controller. Select "Open-loop" as the
% response in the Bode plot and the plot shows reasonable gain and phase
% margin. Time domain response plots are not available for FRD plant
% models.
%
% <<../html_extra/scdenginectrlpidblock/pid_boderesponse.png>>

%%
% Click "OK" button in the PID Tuner. The PID Tuner writes the P and I
% gains to the PID block and closes.

%% Simulating Closed-Loop Performance in Simulink Model
% Simulation in Simulink shows that the new PI controller provides good
% performance when controlling the nonlinear model.
%
% <<../html_extra/scdenginectrlpidblock/pid_stepresponse.png>>

%%
% Close the model.
bdclose(mdl);
displayEndOfDemoMessage(mfilename)


