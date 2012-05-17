%% Sequential Marginal Value-at-Risk Simulation
% This demo performs a Monte Carlo simulation of a number of stocks in a
% portfolio. At a given confidence level, we predict the value at risk (VaR) 
% of the portfolio as well as the marginal value at risk (mVaR) of each of
% the stocks in the portfolio.  We also provide confidence intervals for our 
% estimates.
%
% For details about the computations, 
% <matlab:edit('pctdemo_setup_mvar.m') view the code for pctdemo_setup_mvar>.
%
% Prerequisites:
% 
% * <paralleltutorial_defaults.html
% Customizing the Settings for the Demos in the Parallel Computing Toolbox(TM)> 
%
% Related demos:
%
% * <paralleldemo_mvar_dist.html Distributed Marginal Value-at-Risk Simulation>

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/09 20:04:56 $

%% Load the Demo Settings and the Data
% We start by getting the demo difficulty level.  If you want to use a different
% demo difficulty level, use |paralleldemoconfig| and then run this demo again.
% See <paralleltutorial_defaults.html 
% Customizing the Settings for the Demos in the Parallel Computing Toolbox> 
% for full details.
difficulty = pctdemo_helper_getDefaults();
%%
% We obtain the performance of the stocks, their weights in our portfolio, and
% other input data from |pctdemo_setup_mvar|. 
% The number of repetitions, |numTimes|, is determined by the |difficulty|
% parameter.  
% You can 
% <matlab:edit('pctdemo_setup_mvar.m') view the code for pctdemo_setup_mvar> 
% for full details.
[fig, numSims, numTimes, stock, names, weights, time, confLevel] = ...
    pctdemo_setup_mvar(difficulty); 
%%
% Let's look at the confidence level at which we are calculating the VaR and
% mVaR.
fprintf('Calculating VaR and mVaR at the %3.1f%% confidence level.\n', ...
        confLevel);
startTime = clock;

%% Run the Simulation
% We perform |numSims| simulations |numTimes| times.  This allows us to make
% predictions on the VaR and mVaR, as well as to compute the confidence 
% intervals.
% You can 
% <matlab:edit('pctdemo_task_mvar.m') view the code for pctdemo_task_mvar> 
% for full details.
[VaR, mVaR] = pctdemo_task_mvar(numTimes, stock, weights, time, ...
                                 numSims, confLevel);

%% Measure the Elapsed Time
% The time used for the sequential computations should be compared
% against the time it takes to perform the same set of calculations
% using the Parallel Computing Toolbox in the <paralleldemo_mvar_dist.html
% Distributed Marginal Value-at-Risk Simulation> demo.
% The elapsed time varies with the underlying hardware.
elapsedTime = etime(clock, startTime);
fprintf('Elapsed time is %2.1f seconds\n', elapsedTime);

%% Plot the Results
% We use |pctdemo_plot_mvar| to create a graph of the value at risk of our
% portfolio at the given confidence level.  The graph also shows the marginal
% value at risk of the individual stocks in our portfolio at that same
% confidence level. You can 
% <matlab:edit('pctdemo_plot_mvar.m') view the code for pctdemo_plot_mvar> for
% full details.
pctdemo_plot_mvar(fig, VaR, mVaR, time, names);


displayEndOfDemoMessage(mfilename)
