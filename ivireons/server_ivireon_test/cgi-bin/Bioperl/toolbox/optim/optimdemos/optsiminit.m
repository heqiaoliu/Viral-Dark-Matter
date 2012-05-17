%OPTSIMINIT Sets up necessary parameters for optimization of optsim.mdl
% Documentation example

%   Copyright 1990-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/07/07 13:42:41 $


% Define Tunable Variable initial values
Kp = 0.63;
Ki = 0.0504;
Kd = 1.9688;

% Define Uncertain Variable initial values
a2 = 43;
a1 = 3;

disp('Done initializing optsim.')
% end optsiminit
