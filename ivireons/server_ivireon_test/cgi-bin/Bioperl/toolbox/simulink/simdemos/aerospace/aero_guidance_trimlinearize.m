%% Airframe Trim and Linearize
% Trim and linearize an airframe using Simulink(R) Control Design(TM)
%
% Copyright 1990-2007 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2007/12/10 22:40:17 $
%
% Designing an autopilot using classical design techniques requires linear 
% models of the airframe pitch dynamics for a number of trimmed flight 
% conditions. MATLAB(R) can determine the trim conditions and derive linear
% state-space models directly from the nonlinear Simulink(R) and Aerospace Blockset(TM) 
% model. This saves time and helps to validate the model. The 
% functions provided by Simulink Control Design allow you to visualize 
% the behavior of the airframe in terms of open-loop frequency (or time) 
% responses.

%% Initialize Guidance Model
%
% The first problem is to find the elevator deflection, and the
% resulting trimmed body rate (q), which will generate a given
% incidence value when the missile is travelling at a set speed.
% Once the trim condition is found, a linear model can be derived
% for the dynamics of the perturbations in the states around 
% the trim condition. 

open_system('aero_guidance_airframe');


%% Define State Values
%

h_ini     = 10000/m2ft;      % Trim Height [m]
M_ini     = 3;               % Trim Mach Number
alpha_ini = -10*d2r;         % Trim Incidence [rad]
theta_ini = 0*d2r;           % Trim Flightpath Angle [rad]
v_ini = M_ini*(340+(295-340)*h_ini/11000); 	% Total Velocity [m/s]

q_ini = 0;               % Initial pitch Body Rate [rad/sec]


%% Set Operating Point and State Specifications
%
% The first state specifications are Position states, the second state 
% specification is Theta.  Both are known, but not at steady state.  The 
% third state specifications are body axis angular rates of which the 
% variable w is at steady state.
%

opspec = operspec('aero_guidance_airframe');
opspec.State(1).Known = [1;1];
opspec.State(1).SteadyState = [0;0];
opspec.State(2).Known = 1;
opspec.State(2).SteadyState = 0;
opspec.State(3).Known = [1 1];
opspec.State(3).SteadyState = [0 1];

%% Search for Operating Point, Set I/O, then Linearize
%

op = findop('aero_guidance_airframe',opspec);

io(1) = linio('aero_guidance_airframe/Fin Deflection',1,'in');
io(2) = linio('aero_guidance_airframe/Selector',1,'out');
io(3) = linio(sprintf(['aero_guidance_airframe/Aerodynamics &\n', ...
                    'Equations of Motion']),3,'out');

sys = linearize('aero_guidance_airframe',op,io);

%% Select Trimmed States, Create LTI Object, and Plot Bode Response
%

airframe = ss(sys.A(3:4,3:4),sys.B(3:4,:),sys.C(:,3:4),sys.D);

set(airframe,'inputname',{'Elevator'}, ...
             'outputname',[{'az'} {'q'}]);

ltiview('bode',airframe);

bdclose('aero_guidance_airframe');


displayEndOfDemoMessage(mfilename)