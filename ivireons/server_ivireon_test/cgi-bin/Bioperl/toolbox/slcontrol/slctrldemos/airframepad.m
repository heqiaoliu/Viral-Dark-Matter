%% Trimming and Linearizing an Airframe
%
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2009/12/05 02:33:52 $

%%
% In this example, we need to find the elevator deflection and the
% resulting trimmed body rate (q) that will generate a given incidence
% value when the airframe is traveling at a set speed. Once we find the trim
% condition, we can derive a linear model for the dynamics of the states
% around the trim condition. 
% 
%          Fixed parameters  :
%                              Incidence (Theta)
%                              Body attitude (U)
%                              Position 
%          Trimmed steady state parameters :
%                              Elevator deflection (w)
%                              Body rate (q)

%%
% The model can be opened using the scdairframe command
scdairframe

%% Generating  Operating Points
% To get the operating point specification object, you use the operspec
% command:
opspec = operspec('scdairframe')

%%
% First, we set the Position state specifications, which are known but not at steady state:
opspec.States(1).Known = [1;1];
opspec.States(1).SteadyState = [0;0];

%% 
% The second state specification is Theta which is known but not at steady state: 
opspec.States(2).Known = 1;
opspec.States(2).SteadyState = 0;

%%
% The third state specification includes the body axis angular rates where the 
% variable w is at steady state: 
opspec.States(3).Known = [1 1];
opspec.States(3).SteadyState = [0 1];

%%
% Next, we search for the operating point that meets this specification 
op = findop('scdairframe',opspec);

%% Linearizing the Model
% The operating points are now ready for linearization. First, we specify
% the input and output points using the following commands:
io(1) = linio('scdairframe/Fin Deflection',1,'in');
io(2) = linio('scdairframe/EOM',3,'out');
io(3) = linio('scdairframe/Selector',1,'out');

%%
% Linearize the model and plot the Bode magnitude response for each condition. 
sys = linearize('scdairframe',op,io);
bodemag(sys)

bdclose('scdairframe')
displayEndOfDemoMessage(mfilename)
