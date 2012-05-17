%% Minimizing an Expensive Optimization Problem Using Parallel Computing Toolbox(TM)
% This is a demonstration of how to speedup the minimization of an expensive 
% optimization problem using functions in Optimization Toolbox(TM) and 
% Global Optimization Toolbox. In the first part of the demo we will solve 
% the optimization problem by evaluating functions in a serial fashion and 
% in the second part of the demo we will solve the same problem using the 
% parallel for loop (PARFOR) feature by evaluating functions in parallel. 
% We will compare the time taken by the optimization function in both cases.

%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.9 $   $Date: 2010/05/10 17:32:19 $

%% Expensive Optimization Problem
% For the purpose of this demo, we solve a problem in four variables, where
% the objective and constraint functions are made artificially expensive by
% having them compute the eigenvalues of a large matrix.
type expensive_objfun.m
type expensive_confun.m

%%
% We can measure the approximate time taken by the objective function and
% the constraint function to evaluate a point. This can give us an
% estimate of total time taken to minimize the problem. 
startTime = tic;
for i = 1:10
    expensive_objfun(rand(1,4));
end
stopTime = toc(startTime);
averageTime = stopTime/10;
fprintf('Objective function evaluation: %g seconds.\n', averageTime);

startTime = tic;
for i = 1:10
    expensive_confun(rand(1,4));
end
stopTime = toc(startTime);
averageTime = stopTime/10;
fprintf('Constraint function evaluation: %g seconds.\n',averageTime);

%% Minimizing Using FMINCON
% We are interested in measuring the time taken by FMINCON so that we can
% compare it to the parallel FMINCON evaluation.
startPoint = [1 -2 0 5];
options = optimset('Display','iter','Algorithm','active-set');
startTime = tic;
fmincon(@expensive_objfun,startPoint,[],[],[],[],[],[],@expensive_confun,options);
time_fmincon_sequential = toc(startTime);
fprintf('Serial FMINCON optimization takes %g seconds.\n',time_fmincon_sequential);

%% Minimizing Using Genetic Algorithm
% Since GA usually takes more function evaluations than FMINCON we will
% remove the expensive constraint from this problem and perform
% unconstrained optimization instead; we pass empty ([]) for constraints.
% In addition, we limit the maximum generations to 15 for GA so that GA can
% terminate in a reasonable amount of time. We are interested in measuring
% the time taken by GA so that we can compare it to the parallel GA
% evaluation. Note that running GA requires Global Optimization Toolbox.
try
    gaAvailable = false;
    nvar = 4;
    gaoptions = gaoptimset('Generations',15,'Display','iter');
    startTime = tic;
    ga(@expensive_objfun,nvar,[],[],[],[],[],[],[],gaoptions);
    time_ga_sequential = toc(startTime);
    fprintf('Serial GA optimization takes %g seconds.\n',time_ga_sequential);
    gaAvailable = true;
catch ME
    warning('optimdemos:optimparfor:gaNotFound', ... 
        ['GA function requires a license for Global Optimization Toolbox; ', ...
        'skipping a call to the GA in this demo.']);
end

%% Setting Parallel Computing Toolbox
% The finite differencing used by the functions in Optimization Toolbox to
% approximate derivatives is done in parallel using the PARFOR feature if
% Parallel Computing Toolbox is available and MATLABPOOL is running.
% Similarly, GA, GAMULTIOBJ, and PATTERNSEARCH solvers in Global Optimization 
% Toolbox evaluate functions in parallel. To use the PARFOR feature, we can 
% use the MATLABPOOL function to setup the parallel environment. MATLABPOOL 
% will start four MATLAB(R) workers on the local machine by default. The 
% computer on which this demo is published has four cores so we will start 
% only four workers. When you run this demo, if MATLABPOOL is already open
% we will use the available number of workers; see documentation for
% MATLABPOOL for more information.
needNewWorkers = (matlabpool('size') == 0);
if needNewWorkers
    % Open a new MATLAB pool with 4 workers.
    matlabpool open 4
end

%% Minimizing Using Parallel FMINCON
% To minimize our expensive optimization problem using the parallel FMINCON
% function, we need to explicitly indicate that our objective and
% constraint functions can be evaluated in parallel and that we want
% FMINCON to use its parallel functionality wherever possible. Currently,
% finite differencing can be done in parallel. We are interested in
% measuring the time taken by FMINCON so that we can compare it to the
% serial FMINCON run.
options = optimset(options,'UseParallel','always');
startTime = tic;
fmincon(@expensive_objfun,startPoint,[],[],[],[],[],[],@expensive_confun,options);
time_fmincon_parallel = toc(startTime);
fprintf('Parallel FMINCON optimization takes %g seconds.\n',time_fmincon_parallel);

%% Minimizing Using Parallel Genetic Algorithm
% To minimize our expensive optimization problem using the GA function, we
% need to explicitly indicate that our objective function can be evaluated
% in parallel and that we want GA to use its parallel functionality
% wherever possible. To use the parallel GA we also require that the
% 'Vectorized' option be set to the default (i.e., 'off'). We are again
% interested in measuring the time taken by GA so that we can compare it to
% the serial GA run. Though this run may be different from the serial one
% because GA uses a random number generator, the number of expensive
% function evaluations is the same in both runs. Note that running GA
% requires Global Optimization Toolbox. 
if gaAvailable
    gaoptions = gaoptimset(gaoptions,'UseParallel','always');
    startTime = tic;
    ga(@expensive_objfun,nvar,[],[],[],[],[],[],[],gaoptions);
    time_ga_parallel = toc(startTime);
    fprintf('Parallel GA optimization takes %g seconds.\n',time_ga_parallel);
end

%%
% Utilizing parallel function evaluation via PARFOR improved the efficiency
% of both FMINCON and GA. The improvement is typically better for expensive
% objective and constraint functions. Also, using more than two workers
% and/or using dedicated clusters with MATLABPOOL gives better performance.
% At last we close the parallel environment by calling MATLABPOOL.
if needNewWorkers
    matlabpool close
end

displayEndOfDemoMessage(mfilename)
