%% Linearization of an Engine Speed Model
%
% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2009/03/09 19:36:01 $

%%
% This demonstration introduces the linearization of an engine speed model. 

%%
% The model can be opened using the command: 
scdspeed

%% Generation of Operating Points
% This example generates linear models of the output engine speed and 
% between the inputs the Spark Advance and the Throttle Angle. The FINDOP 
% command computes the operating points at steady state conditions at 2000, 
% 3000, and 4000 RPM. 

%% 
% Create an operating point specification object using the command 
opspec = operspec('scdspeed')

%% 
% Next, specify the desired operating conditions. Fix the first output port 
% of the Vehicle Dynamics to be 2000, 3000, and 4000 RPM. Use the command
% ADDOUTPUTSPEC to do this. 
opspec = addoutputspec(opspec,'scdspeed/rad//s to rpm',1);

%%
% Set the first operating specification
opspec.Output.Known = 1;
opspec.Outputs.y = 2000;

%% 
% Search for the operating point that meets this specification 
op(1) = findop('scdspeed',opspec);

%% 
% Now, search for the remaining operating points at 3000 and 4000 RPM 
opspec.Outputs.y = 3000;
op(2) = findop('scdspeed',opspec);
opspec.Outputs.y = 4000;
op(3) = findop('scdspeed',opspec);

%% Model Linearization
% The operating points are now ready for linearization. First specify the 
% input and output points using the commands: 
io(1) = linio('scdspeed/throttle (degrees)',1,'in');
io(2) = linio('scdspeed/Spark Advance',1,'in');
io(3) = linio('scdspeed/rad//s to rpm',1,'out');

%% 
% Linearize the model and plot the Bode magnitude response for each condition. 
sys = linearize('scdspeed',op,io);
bodemag(sys)

%%
% Close the model.
bdclose('scdspeed')
displayEndOfDemoMessage(mfilename)
