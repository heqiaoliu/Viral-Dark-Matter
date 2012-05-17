%% Trimming and Linearizing Simulink Models
%
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2009/12/22 18:58:00 $
%
% The <matlab:scdguihelp('functions'); command line> tools available in
% Simulink(R) Control Design(TM) software allow for the programmatic
% specification of the input and output points for the linearization of a
% model. Additionally, there are new command line tools to extract and
% specify (trimming) operating points for a linearization. This demo
% introduces some of these commands by linearizing a 
% <matlab:scdguihelp('watertank'); water-tank> feedback control system. An
% open loop linearized model of the watertank will be extracted at an
% operating point where the tank level is at H = 10. The following 3 steps
% linearize and analyze the water-tank model.

%%
% Open the model
watertank

%% Step 1: Configuring Linearization Points
% The linearization points specify the inputs and outputs of a linearized
% model. To extract the open loop linearized model, add an input point at
% the output of the Controller block and an output point, with a loop
% opening, at the output of the Water-Tank System block.

%%
% Specify the input point
watertank_io(1)=linio('watertank/PID Controller',1,'in');
%%
% Specify the output point with a loop opening
watertank_io(2)=linio('watertank/Water-Tank System',1,'out','on');

%%
% The linearization points can then be set and viewed in the model 
setlinio('watertank',watertank_io);
watertank

%% Step 2: Computing and Specifying Operating Points
% This next step involves finding an operating point of the Simulink model
% 'watertank' so that the level of the tank is at H = 10. One approach is
% to simulate the model then extract the operating point when the
% simulation is near the desired value. The command FINDOP will simulate a
% model and extract the operating points at times defined in the function
% call.  
opsim = findop('watertank',10)

%%
% In this operating point, H is not at the desired value of 10.
% However, you can use this operating point to initialize a
% search for the desired operating point where H = 10. An operating point
% specification object allows you to specify the desired value of H = 10.

%%
% Create an operating point specification object
opspec = operspec('watertank');
%%
% Initialize the values of the states of the operating point specification
% with the ones in the operating point opsim
opspec = initopspec(opspec,opsim);
%%
% The specified operating point can then be searched for (trimmed) using
% the FINDOP command
opss = findop('watertank',opspec);

%% Step 3: Linearizing and Analyzing the Model
% You are now ready to linearize the plant model by using the LINEARIZE
% function.
sys = linearize('watertank',opss,watertank_io);

%%
% The resulting model is a state space object that you can analyze using
% any of the tools in the Control System Toolbox(TM) software.
bode(sys);

%%
% Close the Simulink model
bdclose('watertank')
displayEndOfDemoMessage(mfilename)
