%% Linearization of a Conveyor Model (Requires SimMechanics)
% Copyright 2005-2007 The MathWorks, Inc.
% $Revision: 1.1.6.9 $ $Date: 2009/05/23 08:20:12 $

%%
% This demonstration introduces the use of the operating point search and
% snapshot features along with the linearization of a SimMechanics(TM) model. (Requires SimMechanics) 

%% Operating Condition Search
% Open the model
open_system('scdmechconveyor');

%%
% The steady state operating point can now be found using the operating specification object initialized using the simulated operating point. For the steady state operating point search, the Analysis Type for the SimMechanics machine must be set to be in Trimming mode. See the SimMechanics documentation for details on this feature. 
set_param('scdmechconveyor/Mechanical Environment','AnalysisType','Trimming')
opspec = operspec('scdmechconveyor');

%%
% For SimMechanics models, the operating condition search in some cases can converge to a steady state condition more quickly using a nonlinear least squares algorithm. This algorithm is available if the Optimization Toolbox(TM) is licensed. An iterative report of the search can also be displayed by using the LINOPTIONS command. 
opt = linoptions('OptimizerType','lsqnonlin','DisplayReport','none');
opt.OptimizationOptions.MaxFunEvals = 2000;

%%
% To ensure that the algebraic constraints in the SimMechanics model are
% met, the trim output port must be specified to be zero. 
opspec.Outputs.y = zeros(8,1);
opspec.Outputs.Known = ones(8,1);

%%
% The steady state operating point can now be found using the FINDOP command.
[op,opreport] = findop('scdmechconveyor',opspec,opt);

%% 
% Display the final report
opreport

%%
% Before linearization of the model can be completed, the Analysis Type for the SimMechanics model needs to be restored.
set_param('scdmechconveyor/Mechanical Environment','AnalysisType','Forward dynamics')

%% Linearize the Model
% In this model the open loop plant model between the conveyor position and the torque command can be found using the following input and outputs: 
io(1) = linio('scdmechconveyor/Joint Sensor',1,'out','on');
io(2) = linio('scdmechconveyor/Position Controller',1,'in');

%%
% Linearize the model.
sys = linearize('scdmechconveyor',op,io);

%%
% View the linearized model and corresponding Bode plot. 
sysm = zpk(sys)
bodemag(sysm)

%%
% Close the model.
bdclose('scdmechconveyor')
displayEndOfDemoMessage(mfilename)