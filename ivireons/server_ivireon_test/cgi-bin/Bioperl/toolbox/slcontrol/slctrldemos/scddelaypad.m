%% Linearization of Models with Delays
%
% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2009/07/18 15:54:50 $
%

%% Linearization of Models with Continuous Delays
% You can linearize a Simulink(R) model with continuous time delays blocks such as the
% Transport Delay, Variable Transport Delay, and Variable Time Delay using one
% of the following options:
%%
% * Use a Pade approximations of the delays to get a rational linear system
% through linearizations.
% * Compute a linearization where the delay is exactly represented. Use
% this option when you need accurate simulation and frequency responses
% from a linearized model and when assessing the accuracy of Pade
% approximation.

%%
% By default, Simulink(R) Control Design(TM) uses Pade
% approximations of the delay blocks in a Simulink model.  

%%
% To open the engine speed model used in this demonstration, type
model = 'scdspeed';
open_system(model);

%%
% The engine speed model contains a Variable Transport Delay block named
% dM/dt in the subsystem Induction to Power Stroke Delay.
% For convienince you can store the path to the block in a MATLAB(R) variable by
% typing
DelayBlock = 'scdspeed/Induction to  Power Stroke Delay/dM//dt delay';

%%
% To compute a linearization using a first order approximation, use one of
% the following techniques to set the order of the Pade approximation to 1:
%%
% * In the Variable Transport Delay block dialog box, enter 1 in the *Pade
% Order (for linearization)* field.
% * At the command line, enter the following command:
set_param(DelayBlock,'PadeOrder','1');

%%
% Next, specify the linearization I/O to throttle angle as the input and 
% engine speed as the output by typing
io(1) = linio('scdspeed/throttle (degrees)',1,'in');
io(2) = linio('scdspeed/rad//s to rpm',1,'out');

%%
% Compute the linearization using the following linearize command:
sys_1st_order_approx = linearize(model,io);

%% 
% You can compute a linearization using a second order approximation by setting the
% Pade order to 2:
set_param(DelayBlock,'PadeOrder','2');
sys_2nd_order_approx = linearize(model,io);

%% 
% To compute a linear model with the exact delay representation, set the
% 'UseExactDelayModel' property in the linoptions object to on:
opt = linoptions;
opt.UseExactDelayModel = 'on';

%% 
% Linearize the model using the following linearize command:
sys_exact = linearize(model,io,opt);

%%
% Compare the Bode response of the Pade approximation model and the exact
% linearization model by typing
p = bodeoptions('cstprefs');
p.Grid = 'on';
p.PhaseMatching = 'on';
p.XLimMode = {'Manual'};
p.XLim = {[0.1 1000]};
f = figure;
bode(sys_1st_order_approx,sys_2nd_order_approx,sys_exact,p);
h = legend('sys_1st_order_approx','sys_2nd_order_approx','sys_exact',...
            'Location','SouthWest');
set(h,'Interpreter','none')

%%
% In the case of a first order approximation, the phase begins to diverge
% around 50 rad/s and diverges around 100 rad/s.

%%
% Close the Simulink model.
bdclose(model)

%% Linearization of Models with Discrete Delays
% When linearizing a model with discrete delay blocks, such as Unit and Integer Delay
% blocks use the exact delay option to account for the delays without adding
% states to the model dynamics.  Explicitly accounting for these delays
% improves your simulation performance for systems with many discrete
% delays because your fewer states in your model.

%%
% To open the Simulink model of a discrete system with an Integer Delay
% block with 20 delay state used for this demonstration, type
model = 'scdintegerdelay';
open_system(model);

%%
% By default the linearization includes all of the states folded into
% the linear model.  Set the linearization I/Os and linearize the model as
% follows:
io(1) = linio('scdintegerdelay/Step',1,'in');
io(2) = linio('scdintegerdelay/Discrete Filter',1,'out');
sys_default = linearize(model,io);
%%
% Integrate the resulting model to see that it has 21 states (1 - Discrete
% Filter, 20 - Integer Delay).
size(sys_default)

%% 
% You can linearize this same model using the 'UseExactDelayModel' property
% as follows:
opt = linoptions;
opt.UseExactDelayModel = 'on';
sys_exact = linearize(model,io,opt);

%%
% Interrogating the new resulting model shows that it has 1 state and the
% delays are accounted for interally in the linearized model. 
size(sys_exact)

%%
% Run a step response simulation of both linearized model to see that they
% are identical by typing
step(sys_default,sys_exact);
h = legend('sys_default','sys_exact',...
            'Location','SouthEast');
set(h,'Interpreter','none')

%%
% Close the Simulink model and clean up figures.
bdclose(model)
close(f)

%% Working with Linearized Models with Delays
% For more information on manipulating linearized models with delays, see
% the Control System Toolbox(TM) documentation along with the demos 
% <../../../control/ctrldemos/html/GSSpecifyingDelays.html "Specifying Time
% Delays"> and 
% <../../../control/ctrldemos/html/MADelayResponse.html "Analyzing Control Systems with Delays"> .


displayEndOfDemoMessage(mfilename)