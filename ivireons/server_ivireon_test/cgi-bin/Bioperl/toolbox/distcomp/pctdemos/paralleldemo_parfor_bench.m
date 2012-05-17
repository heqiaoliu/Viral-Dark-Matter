%% Simple Benchmarking of Parfor Using Blackjack
% This demo benchmarks the |parfor| construct by repeatedly playing the
% card game of blackjack, also known as 21.  We use |parfor| to play the
% card game multiple times in parallel, varying the number of MATLAB(R)
% workers, but always using the same number of players and hands.
%
% Related demos:
%
% * <paralleldemo_distribjob_bench.html Benchmarking Distributed Jobs on the Cluster> 
% * <paralleldemo_resource_bench.html Resource Contention in Task Parallel Problems> 

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/01/20 15:31:32 $

%% Parallel Version
% The basic parallel algorithm uses the |parfor| construct to execute
% independent passes through a loop.  It is a part of the MATLAB(R)
% language, but behaves essentially like a regular |for|-loop if you do not
% have access to the Parallel Computing Toolbox(TM) product.  Thus, our
% initial step is to convert a loop of the form
%%
%   for i = 1:numPlayers
%      S(:, i) = playBlackjack();
%   end
%%
% into the equivalent |parfor| loop:
%%
%   parfor i = 1:numPlayers
%      S(:, i) = playBlackjack();
%   end
%%
% We modify this slightly by specifying an optional argument to |parfor|,
% instructing it to limit to |n| the number of workers it uses for the
% computations.  The actual code is as follows:
dbtype pctdemo_aux_parforbench

%% Check the Status of the MATLAB(R) Pool
% We will use the MATLAB(R) pool to allow the body of the |parfor| loop to
% run in parallel, so we start by checking whether the pool is open.  We
% will then run the benchmark using anywhere between 2 and |poolSize|
% workers from this pool.
poolSize = matlabpool('size');
if poolSize == 0
    error('distcomp:demo:poolClosed', ...
        'This demo needs an open MATLAB pool to run.');
end

%% Run the Benchmark: Weak Scaling
% We time the execution of our benchmark calculations using 2 to |poolSize|
% workers.  We use weak scaling, that is, we increase the problem size with
% the number of workers.
numHands = 2000;
numPlayers = 6;
fprintf('Simulating each player playing %d hands.\n', numHands);
t1 = zeros(1, poolSize);
for n = 2:poolSize
    tic;
        pctdemo_aux_parforbench(numHands, n*numPlayers, n);
    t1(n) = toc;
    fprintf('%d workers simulated %d players in %3.2f seconds.\n', ...
            n, n*numPlayers, t1(n));
end
%%
% We compare this against the execution using a regular |for|-loop in
% MATLAB(R). 
tic;
    S = zeros(numHands, numPlayers);
    for i = 1:numPlayers
        S(:, i) = pctdemo_task_blackjack(numHands, 1);
    end
t1(1) = toc;
fprintf('Ran in %3.2f seconds using a sequential for-loop.\n', t1(1));

%% Plot the Speedup
% We compare the speedup using |parfor| with different numbers of workers
% to the perfectly linear speedup curve.  The speedup achieved by using
% |parfor| depends on the problem size as well as the underlying hardware
% and networking infrastructure.
speedup = (1:poolSize).*t1(1)./t1;
fig = pctdemo_setup_blackjack(1.0);
set(fig, 'Visible', 'on');
ax = axes('parent', fig);
x = plot(ax, 1:poolSize, 1:poolSize, '--', ...
    1:poolSize, speedup, 's', 'MarkerFaceColor', 'b');
t = get(ax, 'XTick');
t(t ~= round(t)) = []; % Remove all non-integer x-axis ticks.
set(ax, 'XTick', t);
legend(x, 'Linear Speedup', 'Measured Speedup', 'Location', 'NorthWest');
xlabel(ax, 'Number of MATLAB workers participating in computations');
ylabel(ax, 'Speedup');

%% Measure the Speedup Distribution
% To get reliable benchmark numbers, we need to run the benchmark multiple
% times.  We therefore run the benchmark multiple times for |poolSize|
% workers to allow us to look at the spread of the speedup.
numIter = 100;
t2 = zeros(1, numIter);
for i = 1:numIter
    tic;
        pctdemo_aux_parforbench(numHands, poolSize*numPlayers, poolSize);
    t2(i) = toc;
end

%% Plot the Speedup Distribution
% We take a close look at the speedup of our simple parallel program when
% using the maximum number of workers.  The histogram of the speedup allows 
% us to distinguish between outliers and the average speedup.  
speedup = t1(1)./t2*poolSize;
clf(fig);
ax = axes('parent', fig);
hist(speedup, 5);
a = axis(ax); 
a(4) = 5*ceil(a(4)/5); % Round y-axis to nearest multiple of 5.
axis(ax, a)
xlabel(ax, 'Speedup');
ylabel(ax, 'Frequency');
title(ax, sprintf('Speedup of parfor with %d workers', poolSize));
m = median(speedup);
fprintf(['Median speedup is %3.2f, which corresponds to '...
    'efficiency of %3.2f.\n'], m, m/poolSize);

displayEndOfDemoMessage(mfilename)
