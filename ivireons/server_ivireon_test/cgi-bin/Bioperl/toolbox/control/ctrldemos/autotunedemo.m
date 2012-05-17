%% Automated LQG Tracker Design in the SISO Design Tool 
% This demo shows how to use the LQG synthesis method in SISOTOOL to
% design a feedback controller for a disk drive read/write head. 
%
% For details about the system and model, see Chapter 14 of "Digital
% Control of Dynamic Systems," by Franklin, Powell, and Workman.
%
% Copyright 2005-2007 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2007/11/09 19:48:00 $

%% Disk Drive Model
% Below is a picture of the system to be modeled.
%
% <<../Figures/diskdemofigures_01.png>>

%% 
% The model input is the current ic driving the voice coil motor, and the
% output is the position error signal (PES, in % of track width). To learn
% more about the 10th order model, see <diskdemo.html "Digital Servo
% Control of a Hard-Disk Drive">. Because the model contains a small time
% delay and SISOTOOL does not yet support models with a time delay, we 
% remove the time delay in the input to design a feedback controller.   
load diskdemo
Gr = tf(1e6,[1 12.5 0]);
Gf1 = tf(w1*[a1 b1*w1],[1 2*z1*w1 w1^2]); % first  resonance
Gf2 = tf(w2*[a2 b2*w2],[1 2*z2*w2 w2^2]); % second resonance
Gf3 = tf(w3*[a3 b3*w3],[1 2*z3*w3 w3^2]); % third  resonance
Gf4 = tf(w4*[a4 b4*w4],[1 2*z4*w4 w4^2]); % fourth resonance
G = (ss(Gf1) + Gf2 + Gf3 + Gf4) * Gr;     % convert to state space for accuracy

%% Design Overview
% We want to get a rough design of a full-ordered LQG tracker, which
% places the read/write head at the correct position.
% We also want to tune the LQG tracker to achieve specific
% performance requirements and reduce the controller order as much as
% possible. For example, turn the LQG tracker into a PI controller format.

%% Creating a SISOTOOL Design Task
% Open SISOTOOL by typing the following command at the MATLAB(R) prompt:
% 
% sisotool(G)

%%
% A SISO Design Task is added to the Control and Estimation Tools
% Manager.  You also see a SISO Design Tool dialog that contains
% graphical tuning tools.  Go to the 'Analysis Plot' tab in SISOTOOL and
% select to plot the step response of the closed loop system.  Details
% about how to use SISO Design Tool are described in <GSSISOTool.html
% "Getting Started with the SISO Design Tool">. 

%%
% Select the SISO Design Task node in the tree, and then select the
% 'Automated Tuning' tab.  There are four compensator design methods available
% in the 'Design Method' list.  In this example, we use the LQG synthesis 
% design method.

%%
% <<autotune_cetm_combo.PNG>>

%% Design a Full-Order LQG Tracker
% *Step 1* Select 'LQG Synthesis' in the 'Design Method' list.  
%
% In the 'Compensator' area, the initial controller is set to 1. This
% results in a stable closed-loop system with large oscillations.
% See the closed-loop step response plot.  

%%
% <<autotune_ltiview_init.PNG>>

%% 
% *Step 2* Determine LQG Design Specifications.
%
% In the 'Specifications' area, use sliders to qualitatively set requirements 
% on the controller performance:
%
% 1. Controller Response: Drag the slider to the left (Aggressive)
% results a more aggressive controller that reduces the overshoot and 
% settling time in the closed-loop response. However, if you model is not
% sufficiently accurate, an aggressive controller reduces the stability
% margin (robustness).
%
% 2. Measurement Noise: Drag the slider to the left (Small) indicates
% that you consider your measurement noise to be small. Therefore,  
% the controller has more confidence in the states estimated by the Kalman
% filter and responds more aggressively. However, if you consider your
% measurements to be noisy, drag the slider to the right to cause the
% controller to react more slowly to changes.
%
% 3. Desired LQG Controller Order: Drag the slider to set the desired order
% of the LQG tracker. The LQG tracker automatically contains an integrator. 
% Try reducing the controller order until you begin to lose closed-loop stability.  
%
% As a first iteration in the design, use default slider settings.   

%%
% <<autotune_cetm_LQG.PNG>>

%%
% *Step 3* Click the 'Update Compensator' button.
%
% The new compensator is displayed in the 'Compensator' area, and the
% step response plot is updated.

%%
% <<autotune_ltiview_LQG.PNG>>

%%
% *Step 4* Tune Closed-Loop Performance of the LQG Tracker.  
%
% To design a more aggressive controller, move the Controller Response slider 
% to the far left. This reduces the overshoot by 50% and reduces the settling
% time by 70%.

%%
% <<autotune_cetm_LQG_FullAgg.PNG>>

%% Design a Reduced-Order LQG Tracker
%
% Set Desired LQG Controller Order to 1 and click the 'Update Compensator'
% button.  The new compensator is essentially a PI controller: 0.57(1+s)/s.
% This produces a heavily oscillating closed-loop system.  

%%
% <<autotune_cetm_LQG_RedAggSISO.PNG>>

%%
% <<autotune_cetm_LQG_RedAgg.PNG>>

%%
% To make the controller less aggressive, move the Controller Response
% slider to the right.  The new compensator is essentially a PI controller:
% 0.001(1+s)/s.  

%%
% <<autotune_cetm_LQG_RedRobSISO.PNG>>

%%
% <<autotune_cetm_LQG_RedRob.PNG>>

%%
% The response plot shows that the PI controller design provides a good
% starting point for optimization-based design.  For information, see
% <GSSISOTool.html "Getting Started with the SISO Design Tool">.

%%
displayEndOfDemoMessage(mfilename)
