%% Designing a Family of PID Controllers for Multiple Operating Points
% This demo shows how to design an array of PID controllers for a nonlinear
% plant in Simulink that operates over a wide range of operating points. 

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/05/10 17:56:27 $

%% Opening the Plant Model
% The plant is a continuous stirred tank reactor (CSTR) that operates over
% a wide range of operating points. A single PID controller can effectively
% use the coolant temperature to regulate the output concentration around a
% small operating range that the PID controller is designed for. But since
% the plant is a strongly nonlinear system, control performance degrades if
% operating point changes significantly. The closed-loop system can even
% become unstable.
%%
% <matlab:open_system('scdcstrctrlplant') Open the CSTR plant model>
mdl = 'scdcstrctrlplant';
open_system(mdl)

%%
% For background, see Seborg, D.E. et al., "Process Dynamics and Control",
% 2nd Ed., 2004, Wiley, pp.34-36. 

%% Introduction to Gain Scheduling
% A common approach to solve the nonlinear control problem is using gain
% scheduling with linear controllers. Generally speaking designing a gain
% scheduling control system takes four steps:
%
%   (1) Obtain a plant model for each operating region. The usual practice
%   is to linearize the plant at several equilibrium operating points.
%
%   (2) Design a family of linear controllers such as PID for the plant
%   models obtained in the previous step. 
%
%   (3) Implement a scheduling mechanism such that the controller
%   coefficients such as PID gains are changed based on the values of the
%   scheduling variables.  Smooth (bumpless) transfer between controllers
%   is required to minimize disturbance to plant operation.
%
%   (4) Assess control performance with simulation.
%
% For more background reading on gain scheduling, see a survey paper from
% W. J. Rugh and J. S. Shamma: "Research on gain scheduling", Automatica,
% Issue 36, 2000, pp.1401-1425.

%%
% In this example, we focus on designing a family of PID controllers for
% the CSTR plant described in step 1 and 2.

%% Obtaining Linear Plant Models for Multiple Operating Points
% The output concentration C is used to identify different operating
% regions. The CSTR plant can operate at any conversion rate between low
% conversion rate (C=9) and high conversion rate (C=2). In this demo,
% divide the whole operating range into 8 regions represented by C = 2, 3,
% 4, 5, 6, 7, 8 and 9.

%%
% In the following loop, first compute equilibrium operating points with
% the *findop* command. Then linearize the plant at each operating point
% with the *linearize* command.

% Obtain default operating point
op = operspec(mdl); 
% Set the value of output concentration C to be known
op.Outputs.Known = true;                
% Specify operating regions 
C = [2 3 4 5 6 7 8 9];
% Initialize an array of state space systems
Plants = rss(1,1,1,8);
for ct = 1:length(C)
    % Compute equilibrium operating point corresponding to the value of C
    op.Outputs.y = C(ct);
    opoint = findop(mdl,op,linoptions('DisplayReport','off')); 
    % Linearize plant at this operating point
    Plants(:,:,ct) = linearize(mdl, opoint); 
end

%%
% Since the CSTR plant is nonlinear, we expect different characteristics
% among the linear models. For example, plant models with high and low
% conversion rates are stable, while the others are not.
isstable(Plants)'

%% Designing PID Controllers for the Plant Models
% To design multiple PID controllers in batch, we can use the *pidtune*
% command. The following command will generate an array of PID controllers
% in parallel form. The desired open loop crossover frequency is at 1
% rad/sec and the phase margin is the default value of 60 degrees.

% Design controllers
Controllers = pidtune(Plants,'pidf',pidtuneOptions('Crossover',1));
% Display controller for C=4
Controllers(:,:,4)

%%
% Plot the closed loop responses for step set-point tracking as below:

% Construct closed-loop systems
clsys = feedback(Plants*Controllers,1);
% Plot closed-loop responses
figure;
hold on
for ct =1:length(C)
    % Select a system from the LTI array
    sys = clsys(:,:,ct);
    set(sys,'Name',['C=',num2str(C(ct))],'InputName','Reference');
    % Plot step response
    stepplot(sys,20);
end
legend('show','location','southeast')

%%
% All the closed loops are stable but the settling time of the loops with
% unstable plants (C=4, 5, 6 and 7) are too long.  It can be improved by
% increasing the open loop bandwidth to 5 rad/sec and reducing the phase
% margin to 30 degrees.  The overshoots of these loops remain large because
% the unstable plants restrict the performance of PID controllers.

% Design controllers for unstable plant models
Controllers(:,:,3:6) = pidtune(Plants(:,:,3:6),'pidf',pidtuneOptions('CrossoverFrequency',5,'PhaseMargin',30));
% Display controller for C=4
Controllers(:,:,4)

%%
% All the closed loop responses are satisfactory now.

% Construct closed-loop systems
clsys = feedback(Plants*Controllers,1);
% Plot closed-loop responses
figure;
hold on
for ct =1:length(C)
    % Select a system from the LTI array
    sys = clsys(:,:,ct);
    set(sys,'Name',['C=',num2str(C(ct))],'InputName','Reference');
    % Plot step response
    stepplot(sys,20);
end
legend('show','location','southeast')

%%
% We designed an array of PID controllers and each of them should give
% reasonable performance around the local operating point. The next step is
% to implement the scheduling mechanism, which is beyond the scope of this
% demo.

%%
% Close the model.
bdclose(mdl);
displayEndOfDemoMessage(mfilename)
