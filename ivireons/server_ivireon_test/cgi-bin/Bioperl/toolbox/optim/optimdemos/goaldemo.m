%% Multi-Objective Goal Attainment Optimization
% This demo shows how the Optimization Toolbox(TM) solver fgoalattain
% can be used to solve 
% a pole-placement problem via the multiobjective goal attainment method. 

% Copyright 1990-2008 The MathWorks, Inc.
% $Revision: 1.1.6.4 $  $Date: 2008/04/06 19:17:23 $

%%
% Consider a 2-input 2-output unstable plant.
% The equation describing the evolution of the system x(t) is
%
% $$\frac{dx}{dt} = Ax(t) + Bu(t),$$
%
% where u(t) is the input (control) signal.
% The output of the system is
%
% $$y(t) = Cx(t).$$
%
% The matrices A, B, and C are

A =  [ -0.5  0  0;  0  -2  10;  0  1  -2 ];

B =  [ 1  0;  -2  2;  0  1 ];

C =  [ 1  0  0;  0  0  1 ];

%%
% Suppose that the control signal u(t) is set as proportional to
% the output y(t):
%
% $$u(t) = Ky(t)$$
%
% for some matrix K.
%
% This means that the evolution of the system x(t) is:
%
% $$\frac{dx}{dt} = Ax(t) + BKCx(t) = (A + BKC)x(t).$$
%
% The object of the optimization is to design K to have the following
% two properties:
%
% 1. The real parts of the eigenvalues of (A + B*K*C) are smaller than
% [-5, -3, -1]. (This is called pole placement in the control literature.)
%
% 2. abs(K) <= 4  (each element of K is between -4 and 4)

%%
% In order to solve the optimization, first set the
% multiobjective goals:

goal = [-5, -3, -1];

%%
% Set the weights equal to the goals to ensure same percentage 
% under- or over-attainment in the goals.

weight = abs(goal);

%%
% Initialize the output feedback controller

K0 = [ -1 -1; -1 -1]; 

%%
% Set upper and lower bounds on the controller

lb = repmat(-4,size(K0)) 
ub = repmat(4,size(K0))

%%
% Set optimization display parameter to give output at each iteration:

options = optimset('Display','iter');

%%
% Create a vector-valued function eigfun that returns the eigenvalues of the 
% closed loop system.  This function requires additional parameters (namely, 
% the matrices A, B, and C); the most convenient way to pass these is through 
% an anonymous function:

eigfun = @(K) sort(eig(A+B*K*C));

%%
% To begin the optimization we call FGOALATTAIN:

[K,fval,attainfactor,exitflag,output,lambda] = ...
        fgoalattain(eigfun,K0,goal,weight,[],[],[],[],lb,ub,[],options); 

%%
% The value of the control parameters at the solution is:

K

%%
% The eigenvalues of the closed loop system are 
% in eigfun(K) as follows: (they are also held in output fval)

eigfun(K)

%%
% The attainment factor indicates the level of goal achievement.
% A negative attainment factor indicates over-achievement, positive
% indicates under-achievement. The value attainfactor we obtained in 
% this run indicates that the objectives have been over-achieved by 
% almost 40 percent:

attainfactor 

%%
% Here is how the system x(t) evolves from time 0 to time 4,
% using the calculated feedback matrix K,
% starting from the point x(0) = [1;1;1].
%
% First solve the differential equation:

[Times, xvals] = ode45(@(u,x)((A + B*K*C)*x),[0,4],[1;1;1]);
%%
% Then plot the result:
plot(Times,xvals)
legend('x_1(t)','x_2(t)','x_3(t)','Location','best')
xlabel('t');
ylabel('x(t)');

%%
% Suppose we now require the eigenvalues to be as near as possible
% to the goal values, [-5, -3, -1]. 
% Set options.GoalsExactAchieve to the number of objectives that should be 
% as near as possible to the goals (i.e., do not try to over-achieve):
%
% All three objectives should be as near as possible to the goals.
options = optimset(options,'GoalsExactAchieve',3);

%%
% We are ready to call the optimization solver:

[K,fval,attainfactor,exitflag,output,lambda] = ...
    fgoalattain(eigfun,K0,goal,weight,[],[],[],[],lb,ub,[],options);

%%
% The value of the control parameters at this solution is:

K

%%
% This time the eigenvalues of the closed loop system,
% which are also held in output fval, are as follows:
eigfun(K)

%%
% The attainment factor is the level of goal achievement. A negative 
% attainment factor indicates over-achievement, positive indicates 
% under-achievement. The low attainfactor obtained indicates that the
% eigenvalues have almost exactly met the goals:

attainfactor

%%
% Here is how the system x(t) evolves from time 0 to time 4,
% using the new calculated feedback matrix K,
% starting from the point x(0) = [1;1;1].
%
% First solve the differential equation:

[Times, xvals] = ode45(@(u,x)((A + B*K*C)*x),[0,4],[1;1;1]);
%%
% Then plot the result:
plot(Times,xvals)
legend('x_1(t)','x_2(t)','x_3(t)','Location','best')
xlabel('t');
ylabel('x(t)');

displayEndOfDemoMessage(mfilename)
