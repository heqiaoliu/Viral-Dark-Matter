%% Speeding Up Frequency Response Estimation Using Parallel Computing
% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2010/03/22 04:25:52 $
%
% This demo illustrates how to use parallel computing for speeding up frequency
% response estimation of Simulink(R) models. In some scenarios, the command 
% FRESTIMATE performs multiple Simulink(R) simulations to estimate the
% frequency response of a Simulink(R) model. You can
% distribute these simulations to a pool of MATLAB(R) workers by
% using Parallel Computing Toolbox(TM).
%
% This demo requires Parallel Computing Toolbox(TM). You can optionally use
% MATLAB Distributed Computing Server(TM) to run simulations on a computer
% cluster. This demo uses the local worker functionality available in
% Parallel Computing Toolbox(TM).

%% Speeding up Simulink(R) Simulations Performed by FRESTIMATE
% When you compute frequency response using the FRESTIMATE
% command, the majority of computation time is usually spent in Simulink(R) simulations. To
% reduce the total simulation time, you can:
%
% *1.* Use rapid accelerator mode. See the <scdskyhoggpad.html
% "linearization validation demonstration"> as an example of using rapid
% accelerator mode with the FRESTIMATE command. Use this method when
% FRESTIMATE performs only one Simulink(R) simulation.
%
% *2.* Distribute simulations among workers in a MATLAB(R) pool. Use
% this method when FRESTIMATE performs multiple Simulink(R) simulations.
% FRESTIMATE performs more than one Simulink(R) simulation when you specify
% the following:
%
% * A Sinestream input signal with "SimulationOrder" parameter set to
% "OneAtATime". In this case, each frequency in the Sinestream signal is
% simulated separately.
%
% * Linearization I/O points with more than one input point or a non-scalar input
% point. In this case, each linearization input point or each channel in a
% non-scalar linearization input point yields a separate Simulink(R)
% simulation.
%
% Note that FRESTIMATE command using parallel computing option also supports
% normal, accelerator and rapid accelerator modes.



%% Configuring a MATLAB(R) Pool
% To use parallel computing to speed up frequency response estimation,
% configure and start a pool of MATLAB(R) workers before you run the FRESTIMATE command.
%
% Use the |matlabpool| command to check if a MATLAB(R)
% pool is open, and then open a local pool on your multicore desktop. This
% requires Parallel Computing Toolbox(TM).

if matlabpool('size') == 0
   %The matlabpool is not open, so open one
   matlabpool open local
end

%% Distributing Simulink(R) Simulations for Each Frequency in Sinestream Input
% When you use a Sinestream input signal with FRESTIMATE command and you
% set the "SimulationOrder" parameter to "OneAtATime", each
% frequency in the Sinestream signal simulates in a separate
% Simulink(R) simulation. If you enable the parallel computing option, the simulations
% corresponding to individual frequencies are distributed among workers in
% the MATLAB(R) pool. 

scdengine
mdl = 'scdengine';
io = getlinio(mdl);
in = frest.Sinestream('Frequency',logspace(-1,1,50),'Amplitude',1e-3,...
    'SimulationOrder','OneAtATime');

%%
% In the engine model above, there is a single linearization input point and
% a single linearization output point. There are 50
% frequencies in the Sinestream signal and the FRESTIMATE command performs
% 50 separate Simulink(R) simulations, because the "SimulationOrder" parameter is
% set to "OneAtATime". To enable the parallel computing option for FRESTIMATE to
% distribute these simulations among workers, create a frequency
% response estimation options object using the command |frestimateOptions|
% and set the "UseParallel" parameter to "on". Use this object as input
% argument for FRESTIMATE.

opt = frestimateOptions('UseParallel','on');
sysest = frestimate(mdl,io,in,opt);
bode(sysest,'r*')

%%
% The time it takes for the FRESTIMATE command to run to completion with
% and without parallel computing option enabled is shown below. A PC with
% Intel(R) Core(TM)2 Quad 2.4GHz processor and 4GB of RAM is used.
%
% <html>
% <table border=1><tr BGCOLOR="#CCCCCC"><td>Parallel Computing Option</td><td>Time(secs)</td><td>Speedup</td></tr>
% <tr><td>Disabled</td><td align="center">43.69</td><td align="center">1</td></tr>
% <tr><td>Enabled with 2 workers</td><td align="center">25.34</td><td align="center">1.72</td></tr>
% <tr><td>Enabled with 3 workers</td><td align="center">15.46</td><td align="center">2.83</td></tr>
% <tr><td>Enabled with 4 workers</td><td align="center">11.52</td><td align="center">3.79</td></tr>
% </table>
% </html>
% 
% Parallel computing significantly speeds up the frequency response
% estimation. The imperfect speedup can be caused by various factors
% including the overhead from data and code transfer between client and
% workers and resource competition between worker processes and OS
% processes. For first simulation (i.e. immediately after opening the pool
% of MATLAB(R) workers), Simulink(R) start-up time can add to the overhead.

bdclose(mdl);

%% Distributing Simulink(R) Simulations for Input Channels
% When the number of linearization input points or the number of channels
% in a linearization input point is greater than one, the FRESTIMATE command distributes
% individual Simulink(R) simulations corresponding to these input channels
% among workers in the MATLAB(R) pool.
scdmechconveyor
mdl = 'scdmechconveyor';

io(1) = linio('scdmechconveyor/Constant',1,'in');
io(2) = linio('scdmechconveyor/Position Controller',1,'in');
io(3) = linio('scdmechconveyor/Joint Sensor',1,'out');

% Find the steady state operating point
op = findop(mdl,20);
% Linearize the system and create input signal using linearization result
sys = linearize(mdl,io,op);
in = frest.Sinestream(sys);

%%
% With the |linio| commands, you specify two linearization input
% points, which are both located on scalar Simulink(R) signals. If you
% run the FRESTIMATE command to estimate the frequency response for this
% model, two Simulink(R) simulations occur, one for each input. If you
% enable the parallel computing option, the simulations are distributed among
% workers. Run FRESTIMATE command with parallel computing option enabled and
% plot the estimation result against analytical linearization:
opt = frestimateOptions('UseParallel','on');
sysest = frestimate(mdl,io,in,op,opt);
bodeopts = bodeoptions;
bodeopts.PhaseMatching = 'on';
bodeplot(sys,sysest,'r*',bodeopts)


%%
% The time it takes for the FRESTIMATE command to run to completion with
% and without parallel computing option enabled is shown below. A PC with
% Intel(R) Core(TM)2 Quad 2.4GHz processor and 4GB of RAM is used.
%
% <html>
% <table border=1><tr BGCOLOR="#CCCCCC"><td>Parallel Computing Option</td><td>Time(secs)</td><td>Speedup</td></tr>
% <tr><td>Disabled</td><td align="center">56.99</td><td align="center">1</td></tr>
% <tr><td>Enabled with 2 workers</td><td align="center">31.94</td><td align="center">1.78</td></tr>
% </table>
% </html>
%
% As in the case of distributing simulations for frequencies, the table
% shows nearly a two-fold speedup with the parallel computing option
% enabled. As mentioned before, several factors may contribute to imperfect
% speedup including data and code transfer between client and workers and
% resource competition between worker processes and OS processes.

%%
% Close the model and the MATLAB(R) pool:
bdclose(mdl);
matlabpool close;
displayEndOfDemoMessage(mfilename)