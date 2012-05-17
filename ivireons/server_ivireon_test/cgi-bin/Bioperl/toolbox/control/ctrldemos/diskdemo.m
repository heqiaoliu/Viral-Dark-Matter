%% Digital Servo Control of a Hard-Disk Drive
% This demo shows how to use Control System Toolbox(TM) to design  a digital
% servo controller for a disk drive read/write head.
%
% For details about the system and model, see Chapter 14 of "Digital Control of
% Dynamic Systems," by Franklin, Powell, and Workman.
%

% Copyright 1986-2010 The MathWorks, Inc. 
% $Revision: 1.22.2.7 $  $Date: 2010/02/08 22:29:45 $

%% Disk Drive Model
% Below is a picture of the system to be modeled.
%
% <<../Figures/diskdemofigures_01.png>>

%% 
% The head-disk assembly (HDA) and actuators are modeled by a 10th-order
% transfer function including two rigid-body modes and the first four
% resonances. 
%  
% The model input is the current ic driving the voice coil motor, and the
% output is the position error signal (PES, in % of track width). The model
% also includes a small delay.
% 
% *Disk Drive Model:*
%
% $$ G(s) = G_r(s)G_f(s) $$
%
% $$ G_r(s) = e^{-1e-5s}\frac{1e6}{s(s+12.5)} $$
%
% $$ G_f(s) = \sum_{i=1}^{4} \frac{\omega_i(a_is+b_i\omega_i)}{s^2+2\zeta_i\omega_is+\omega_i^2} $$

%%
% The coupling coefficients, damping, and natural frequencies (in Hz) for the
% dominant flexible modes are listed below.  

%% 
% *Model Data:*
%
% $$ (a_1,b_1,\zeta_1,\omega_1) = (.0000115,-.00575,.05,70) $$
%
% $$ (a_2,b_2,\zeta_2,\omega_2) = (0,.0230,.005,2200) $$
%
% $$ (a_3,b_3,\zeta_3,\omega_3) = (0,.8185,.05,4000) $$
%
% $$ (a_4,b_4,\zeta_4,\omega_4) = (.0273,.1642,.005,9000) $$

%%
% Given this data, construct a nominal model of the head assembly:

load diskdemo
Gr = tf(1e6,[1 12.5 0],'outputdelay',1e-5);
Gf1 = tf(w1*[a1 b1*w1],[1 2*z1*w1 w1^2]); % first  resonance
Gf2 = tf(w2*[a2 b2*w2],[1 2*z2*w2 w2^2]); % second resonance
Gf3 = tf(w3*[a3 b3*w3],[1 2*z3*w3 w3^2]); % third  resonance
Gf4 = tf(w4*[a4 b4*w4],[1 2*z4*w4 w4^2]); % fourth resonance
G = Gr * (ss(Gf1) + Gf2 + Gf3 + Gf4);     % convert to state space for accuracy


%%
% Plot the Bode response of the head assembly model:

cla reset
set(G,'inputname','ic','outputname','PES')
h = bodeplot(G);
title('Bode diagram of the head assembly model');
setoptions(h,'Frequnits','Hz','XLimMode','manual','XLim', {[1 1e5]});
        

%% Servo Controller
% Servo control is used to keep the read/write head "on track."   The servo
% controller C(z) is digital and designed to maintain the PES (offset from the
% track center) close to zero.
%  
% The disturbance considered here is a step variation d in the input current ic.
% Your task is to design a digital compensator C(z) with adequate disturbance
% rejection performance.
%
% <<../Figures/diskdemofigures_02.png>>

%%
% The sampling time for the digital servo is Ts = 7e-5 sec (14.2 kHz).
%  
% Realistic design specs are listed below.
% 
% *Design Specs:*
% 
% * Open-loop gain > 20dB at 100 Hz
% * Bandwidth > 800 Hz
% * Gain margin > 10 dB
% * Phase margin > 45 deg
% * Peak closed-loop gain < 4 dB

%% Discretization of Model
% Since the servo controller is digital, you can perform the design in the 
% discrete domain.  To this effect, discretize the HDA model using C2D and the
% zero-order hold (ZOH) method:

cla reset
Ts = 7e-5;
Gd = c2d(G,Ts);
h = bodeplot(G,'b',Gd,'r'); % compare with the continuous-time model
title('Continuous (blue) and discretized (red) HDA models');
setoptions(h,'Frequnits','Hz','XLimMode','manual','XLim', {[1 1e5]});


%% Controller Design
% Now to the compensator design.  Start with a pure integrator 1/(z-1) to ensure
% zero steady-state error, plot the root locus of the open-loop model Gd*C, and
% zoom around z=1 using the Zoom In option under the Tools menu.

C = tf(1,[1 -1],Ts);
h = rlocusplot(Gd*C);
setoptions(h,'Grid','on','XLimMode','Manual','XLim',{[-1.5,1.5]},...
    'YLimMode','Manual','YLim',{[-1,1]});


%%
% Because of the two poles at z=1, the servo loop is unstable for all positive
% gains.  To stabilize the feedback loop, first add a pair of zeros near z=1.

C = C * zpk([.963,.963],-0.706,1,Ts);
h = rlocusplot(Gd*C);
setoptions(h,'Grid','on','XLimMode','Manual','XLim',{[-1.25,1.25]},...
    'YLimMode','Manual','YLim',{[-1.2,1.2]});

%%
% Next adjust the loop gain by clicking on the locus and dragging the black
% square inside the unit circle.  The loop gain is displayed in the data marker.
% A gain of approximately 50 stabilizes the loop (set C1 = 50*C).

C1 = 50 * C;

%% 
% Now simulate the closed-loop response to a step disturbance in current.  The
% disturbance is smoothly rejected, but the PES is too large (head deviates from
% track center by 45% of track width).

cl_step = feedback(Gd,C1);
h = stepplot(cl_step);
title('Rejection of a step disturbance (PES = position error)')
setoptions(h,'Xlimmode','auto','Ylimmode','auto','Grid','off');


%%
% Next look at the open-loop Bode response and the stability margins.  The gain
% at 100 Hz is only 15 dB (vs. spec of 20 dB) and the gain margin is only 7dB,
% so increasing the loop gain is not an option.

margin(Gd*C1)

diskdemo_aux1(1);

   

%%
% To make room for higher low-frequency gain, add a notch filter near the 4000
% Hz resonance.

w0 = 4e3 * 2*pi;                                 % notch frequency in rad/sec
notch = tf([1 2*0.06*w0 w0^2],[1 2*w0 w0^2]);    % continuous-time notch
notchd = c2d(notch,Ts,'matched');                % discrete-time notch
C2 = C1 * notchd;

h = bodeplot(notchd);
title('Discrete-time notch filter');
setoptions(h,'FreqUnits','Hz','Grid','on');


%%
% You can now safely double the loop gain.
% The resulting stability margins and gain at 100 Hz are within specs.

C2 = 2 * C2;
margin(Gd * C2)

diskdemo_aux1(2);

%%
% Step disturbance rejection has also greatly improved.  The PES now stays
% below 20% of the track width.

cl_step1 = feedback(Gd,C1);
cl_step2 = feedback(Gd,C2);
stepplot(cl_step1,'r--',cl_step2,'b')
title('2nd-order compensator C1 (red) vs. 4th-order compensator C2 (blue)')

%%
% Check if the 3dB peak gain spec on   T = Gd*C/(1+Gd*C)   (closed-loop 
% sensitivity) is met:

Gd = c2d(G,Ts);
Ts = 7e-5;
        
T = feedback(Gd*C2,1);
h = bodeplot(T);
title('Peak response of closed-loop sensitivity T(s)')

setoptions(h,'PhaseVisible','off','FreqUnits','Hz','Grid','on', ...
            'XLimMode','Manual','XLim',{[1e2 1e4]});

%%
% To see the peak value, right-click on the axis and choose the *Peak
% Response* option under the *Characteristics* menu, then hold the mouse over the blue
% marker, or just click on it.


%% Robustness Analysis
% Finally let's analyze the robustness to variations in the damping and natural
% frequencies of the 2nd and 3rd flexible modes.  

%% 
% Parameter Variations:
%
% $$ \omega_2 = 2200 \pm 10\% $$
%
% $$ \omega_3 = 4000 \pm 20\% $$
%
% $$ \zeta_2 = 0.005 \pm 50\% $$
%
% $$ \zeta_3 = 0.05 \pm 50\% $$

%%
% Generate an array of 16 models
% corresponding to all combinations of extremal values of z2,w2,z3,w3:

[z2,w2,z3,w3] = ndgrid([.5*z2,1.5*z2],[.9*w2,1.1*w2],[.5*z3,1.5*z3],[.8*w3,1.2*w3]);
for j=1:16,  
    Gf21(:,:,j) = tf(w2(j)*[a2 b2*w2(j)] , [1 2*z2(j)*w2(j) w2(j)^2]);
    Gf31(:,:,j) = tf(w3(j)*[a3 b3*w3(j)] , [1 2*z3(j)*w3(j) w3(j)^2]);
end
G1 = Gr * (ss(Gf1) + Gf21 + Gf31 + Gf4);


%%
% Discretize these 16 models at once and see how the parameter variations
% affect the open-loop response. Note: You can click on any curve to
% identify the underlying model.

Gd = c2d(G1,Ts);
h = bodeplot(Gd*C2);

title('Open-loop response - Monte Carlo analysis') 
setoptions(h,'XLimMode','manual','XLim',{[8e2 8e3]},'YLimMode','auto',...
    'FreqUnits','Hz','MagUnits','dB','PhaseUnits','deg','Grid','on');

%%
% Plot the step disturbance rejection performance for these 16 models:

stepplot(feedback(Gd,C2))
title('Step disturbance rejection - Monte Carlo analysis')

%% 
% All 16 responses are nearly identical: our servo design is robust!

 
displayEndOfDemoMessage(mfilename)