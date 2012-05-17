%% Friction Modeling: MATLAB File Modeling of Static SISO System
% System identification normally deals with identifying parameters of
% dynamic models. However, static models are also of interest, sometimes by
% their own and sometimes as sub-models of larger more involved models. An
% example of the latter is discussed in the case study "An Industrial Robot
% Arm" (idnlgreydemo13.m), where a static friction model is employed as a
% fixed (pre-estimated) component of a robot arm model.
%
% In this demo we also resort to static friction modeling and illustrate
% how this can be carried out using IDNLGREY.

%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.9 $ $Date: 2009/10/16 04:54:28 $

%% A Continuously Differentiable Friction Model
% Discontinuous and piecewise continuous friction models are often
% problematic for high-performance continuous controllers. This very fact
% motivated Makkar, Dixon, Sawyer and Hu to suggest a new continuously
% and differentiable friction model that captures the most common friction
% phenomena encountered in practice. The new friction model structure was
% reported in
%
%   C. Makkar, W. E. Dixon, W. G. Sawyer, and G.Hu "A New Continuously
%   Differentiable Friction Model for Control Systems Design", IEEE(R)/ASME
%   International Conference on Advanced Intelligent Mechatronics,
%   Monterey, CA, 2005, pages 600-605.
%
% and will serve as a basis for our static identification experiments.

%%
% The friction model proposed by Makkar, et al, links the slip speed v(t)
% of a body in contact with another body to the friction force f(t) via the
% static relationship
%
%    f(t) =   g(1)*(tanh(g(2)*v(t) - tanh(g(3)*v(t))
%           + g(4)*tanh(g(5)*v(t)) + g(6)*v(t)
%
% where g(1), ..., g(6) are 6 unknown positive parameters. This model
% structure displays a number of nice properties arising in real-world
% applications:
%
%    1. The friction model is symmetric around the origin.
%    2. The static friction coefficient is approximated by g(1)+g(4).
%    3. The first term of the equation, tanh(g(2)*v(t) - tanh(g(3)*v(t),
%       captures the so called Striebeck effect, where the friction term
%       shows a rather sudden drop with increasing slip speed near the
%       origin.
%    4. The Coulombic friction effect is modeled by the term
%       g(4)*tanh(g(5)*v(t)).
%    5. The viscous friction dissipation is reflected by the last term,
%       g(6)*v(t).
%
% Consult the above mentioned paper for many more details about friction
% in general and the proposed model structure in particular.

%% IDNLGREY Friction Modeling
% Let us now create an IDNLGREY model object describing static friction. As
% usual, the starting point is to write an IDNLGREY modeling file, and here
% we construct an MATLAB file, friction_m.m, with contents as follows.
%
%    function [dx, f] = friction_m(t, x, v, g, varargin)
%    %FRICTION_M  Nonlinear friction model with Stribeck, Coulomb and viscous
%    %   dissipation effects.
% 
%    % Output equation.
%    f =  g(1)*(tanh(g(2)*v(1))-tanh(g(3)*v(1))) ... % Stribeck effect.
%       + g(4)*tanh(g(5)*v(1))                   ... % Coulomb effect.
%       + g(6)*v(1);                                 % Viscous dissipation term.
% 
%    % Static system; no states.
%    dx = [];
%
% Notice that a state update dx always must be returned by the model file
% and that it should be empty ([]) in static modeling cases.

%%
% Our next step is to pass the model file, information about model order,
% guessed parameter vector and so forth as input arguments to the IDNLGREY
% constructor. We also specify names and units of the input and output and
% state that all model parameters must be positive.
FileName      = 'friction_m';          % File describing the model structure.
Order         = [1 1 0];               % Model orders [ny nu nx].
Parameters    = {[0.20; 90; 11; ...
                  0.12; 110; 0.015]};  % Initial parameters.
InitialStates = [];                    % Initial initial states.
Ts            = 0;                     % Time-continuous system.
nlgr = idnlgrey(FileName, Order, Parameters, InitialStates, Ts,    ...
                'Name', 'Static friction model',                   ...
                'InputName', 'Slip speed', 'InputUnit', 'm/s',     ...
                'OutputName', 'Friction force', 'OutputUnit', 'N', ...
                'TimeUnit', 's');
setpar(nlgr, 'Minimum', {zeros(5, 1)});   % All parameters must be >= 0.

%%
% After these actions we have an initial friction model with properties as
% follows.
present(nlgr);

%%
% In our identification experiments we are not only interested in the full
% friction model, but also in examining how a reduced friction model would
% perform. By reduced we here mean a friction model that contains two of
% the three terms of the full model. To investigate this, three copies of
% the full model structure are created and in each copy we fix the
% parameter vector so that only two of the terms will contribute:
nlgr1 = nlgr;
nlgr1.Name = 'Static friction model without Striebeck term';
setpar(nlgr1, 'Value', {[zeros(3, 1); Parameters{1}(4:6)]});
setpar(nlgr1, 'Fixed', {[true(3, 1); false(3, 1)]});
nlgr2 = nlgr;
nlgr2.Name = 'Static friction model without Coulombic term';
setpar(nlgr2, 'Value', {[Parameters{1}(1:3); 0; 0; Parameters{1}(6)]});
setpar(nlgr2, 'Fixed', {[false(3, 1); true(2, 1); false]});
nlgr3 = nlgr;
nlgr3.Name = 'Static friction model without dissipation term';
setpar(nlgr3, 'Value', {[Parameters{1}(1:5); 0]});
setpar(nlgr3, 'Fixed', {[false(5, 1); true]});

%% Input-Output Data
% At our disposal are 2 different (simulated) data sets where the input
% slip speed was swept from -10 m/s to 10 m/s in a ramp-type manner. We
% load the data and create two IDDATA objects for our identification
% experiments, ze for estimation and zv for validation purposes.
load(fullfile(matlabroot, 'toolbox', 'ident', 'iddemos', 'data', 'frictiondata'));
ze = iddata(f1, v, 1, 'Name', 'Static friction system');
set(ze, 'InputName', 'Slip speed', 'InputUnit', 'm/s',  ...
        'OutputName', 'Friction force', 'OutputUnit', 'N', ...
        'Tstart', 0, 'TimeUnit', 's');
zv = iddata(f2, v, 1, 'Name', 'Static friction system');
set(zv, 'InputName', 'Slip speed', 'InputUnit', 'm/s',  ...
        'OutputName', 'Friction force', 'OutputUnit', 'N', ...
        'Tstart', 0, 'TimeUnit', 's');

%%
% The input-output data that will be used for estimation are shown in a
% plot window. 
figure('Name', ze.Name);
plot(ze);

%%
% *Figure 1:* Input-output data from a system exhibiting friction.

%% Performance of the Initial Friction Models
% With access to input-output data and four different initial friction
% models the obvious question now is how good these models are? Let us
% investigate this for the estimation data set through simulations carried
% out by COMPARE:
figure;
compare(ze, nlgr, nlgr1, nlgr2, nlgr3);

%%
% *Figure 2:* Comparison between true output and the simulated outputs
% of the four initial friction models.

%% Parameter Estimation
% None of the initial models are able to properly describe the true
% output. To overcome this we estimate the model parameters of all four
% model structures. We configure all estimations to perform at most 30
% iterations and to stop the iterations only in case the tolerance is 0
% (which it in practice never will be for real-world data). These
% computations will take some time.
nlgr = pem(nlgr, ze,   'Display', 'On', 'MaxIter', 30, 'Tol', 0);
nlgr1 = pem(nlgr1, ze, 'MaxIter', 30, 'Tol', 0, 'cov', 'none');
nlgr2 = pem(nlgr2, ze, 'MaxIter', 30, 'Tol', 0, 'cov', 'none');
nlgr3 = pem(nlgr3, ze, 'MaxIter', 30, 'Tol', 0, 'cov', 'none');

%% Performance of the Estimated Friction Models
% The performance of the models are once again investigated by comparing
% the true output with the simulated outputs of the four models as obtained
% using COMPARE, but this time the comparison is based on the validation
% data set zv.
figure;
compare(zv, nlgr, nlgr1, nlgr2, nlgr3);

%%
% *Figure 3:* Comparison between true output and the simulated outputs
% of the four estimated friction models.

%%
% For this system we clearly see that the full model outperforms the
% reduced ones. Nevertheless, the reduced models seem to be able to capture
% the effects they model rather well, and in each case estimation results
% in a much better fit. The worst fit is obtained for the model where the
% viscous dissipation term has been left out. The impressive fit of the
% full model comes as no big surprise as its model structure coincide with
% that used to generate the true output data. The parameters of the full
% model are also close to the ones that were used to generate the true
% model output:
disp('   True       Estimated parameter vector');
ptrue = [0.25; 100; 10; 0.1; 100; 0.01];
fprintf('   %7.3f    %7.3f\n', [ptrue'; getpvec(nlgr)']);

%%
% The Final Prediction Error (FPE) criterion (low values are good) applied
% to all four friction models confirms the superiority of the full friction
% model:
fpe(nlgr, nlgr1, nlgr2, nlgr3);

%%
% As for dynamic systems, we can also examine the prediction errors of a
% static model using PE. We do this for the full friction model and
% conclude that the residuals seem to have a random nature:
figure;
pe(zv, nlgr);

%%
% *Figure 4:* Prediction errors obtained with the estimated full friction
% model.

%%
% We further verify the randomness by looking at the residuals
% ("leftovers") of the full friction model:
figure('Name', [nlgr.Name ': residuals of estimated IDNLGREY model']);
resid(zv, nlgr);

%%
% *Figure 5:* Residuals obtained with the estimated full friction model.

%%
% The step response of static models can also be computed and plotted. Let
% us apply a unit step and do this for all four estimated friction models:
figure('Name', [nlgr.Name ': step responses of estimated models']);
step(nlgr, nlgr1, nlgr2, nlgr3);
legend(nlgr.Name, nlgr1.Name, nlgr2.Name, nlgr3.Name, 'location', 'SouthEast');

%%
% *Figure 6:* Unit step responses of the four estimated friction models.

%%
% We finally display a number of properties, like the estimated standard
% deviations of the parameters, the loss function, etc., of the full
% friction model.
present(nlgr);

%% Conclusions
% This demo has exemplified how to perform IDNLGREY modeling of a static
% system. The procedure for doing this is basically the same as for dynamic
% systems' modeling.

%% Additional Information
% For more information on identification of dynamic systems with System Identification Toolbox(TM) 
% visit the
% <http://www.mathworks.com/products/sysid/ System Identification Toolbox>
% product information page.

displayEndOfDemoMessage(mfilename)