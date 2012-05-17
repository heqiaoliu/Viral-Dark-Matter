%% Error Rate Test Console - IEEE 802.11b Physical Layer Simulation
% This demonstration shows how to use the Communications Toolbox(TM) Error
% Rate Test Console to simulate a system that implements the physical layer
% of the IEEE(R) 802.11b standard.

% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2010/02/17 18:43:39 $

%% IEEE 802.11b Communications System
% The file <matlab:edit([matlabroot,'\toolbox\comm\commdemos\IEEE80211b.m'])
% IEEE80211b.m> contains the definition of a communications system that
% implements DBPSK modulation, Barker code spreading, and pulse shaping over
% a flat fading Rayleigh channel with additive white Gaussian noise. This
% class definition uses the System Basic API (i.e. extends the
% testconsole.SystemBasicAPI class) and thus, can be attached to an Error
% Rate Test Console for analysis.

% Instantiate the 802.11b communications system
sys = IEEE80211b

%%
% We may change the system property values to change the pulse shaping
% filter order (FilterOrder) and roll-off factor (RollOffFactor), the
% samples per chip (SamplesPerChip), the energy per symbol to noise power
% spectral density ratio (EsNo), and the maximum Doppler shift (Doppler) of
% the Rayleigh channel. As will be explained shortly, these last two
% properties, EsNo and Doppler, are registered by the system as test
% parameters. Registered test parameters can be controlled by a test console
% to run parameterized simulations. 

%% 
% *Debug Mode*
%
% A system that uses the System Basic API can be run by itself (without the
% need to attach it to a test console), and this scenario is referred to as
% debug mode. The system does not generate any outputs in debug-mode.  This
% mode is useful to debug the system using break points before running
% simulations through a test console.  We run the system in debug mode and
% confirm that the system can be run without errors or warnings.

% Setup, reset, and run the system to check for errors or warnings
setup(sys)
reset(sys)
run(sys)


%% Error Rate Test Console
% We use an Error Rate Test Console to run parameterized simulations of the
% system to obtain error rate performance metrics. The Error Rate Test
% Console can sweep through a set of test parameter values and collect error
% rate data. The Error Rate Test Console automatically utilizes a parallel
% computing environment created by the Parallel Computing Toolbox(TM). If a
% Parallel Computing Toolbox license exists and a MATLAB(R) pool is created,
% the Error Rate Test Console automatically detects the pool and distributes
% the simulation among multiple workers. Otherwise, simulations are run on a
% single core. Simulation duration can be drastically reduced if multiple
% workers are utilized. 

%%
% *Starting an Error Rate Test Console*
%
% Error rate simulations can be run on the 802.11b system by instantiating a
% commtest.ErrorRate test console and attaching the IEEE80211b
% communications system to it. When instantiating, we will set the
% FrameLength property of the test console to 8192 symbols, which
% corresponds to the packet size of an 802.11b system (ignoring preamble and
% sync bits). The FrameLength property defines the length of the transmitted
% frame that will be used at each simulation iteration.
        
testConsole = commtest.ErrorRate(sys,'FrameLength',8192)
%% Test Console Configuration
% We need to configure the test console before running simulations.
% Configuration involves registering test points, setting test parameter
% sweep values, specifying the simulation stop and reset criteria, and the
% way we want the test console to combine the test parameter sweep values.
% We can get the information needed to configure the test console using the
% INFO method of the test console. 

% Get information about the test console and the attached system
info(testConsole)

%% Setting Test Parameter Sweep Values
%
% The INFO method shows that there are three registered test parameters,
% 'EsNo' (energy per symbol to noise power spectral density ratio), 'M'
% (modulation order), and 'Doppler' (maximum Doppler shift for the Rayleigh
% channel). Error rate simulations may be obtained for various combinations
% of values of these parameters.  
%
% Sweep values for each parameter can be specified by calling the
% setTestParameterSweepValues method of the test console. To see the valid
% ranges for test parameter values we first use the
% getTestParameterValidRanges method.

% Get test valid ranges for 'EsNo' test parameter
getTestParameterValidRanges(testConsole, 'EsNo')

%%
% We observe that the IEEE80211b system has not set any range limits for the
% 'EsNo' parameter.
%%

% Get test valid ranges for 'Doppler'
getTestParameterValidRanges(testConsole, 'Doppler')

%%
% The IEEE80211b system has set limits on the maximum Doppler shift of the
% Rayleigh channel 'Doppler' parameter so that it remains inside the [0 500]
% Hz interval.
%%

% Get test valid ranges for 'M'
getTestParameterValidRanges(testConsole, 'M')
%%
% The system has set limits on modulation order 'M' such that it remains
% constant and equal to 2 since it implements a DBPSK modulation scheme. In
% this case 'M' has been registered as a test parameter not to enable
% simulations for different modulation orders but to enable the system to
% use a 'RandomIntegerSource' source data available at the test console as a
% test input.
%% 
% Let us obtain simulation results for a range of EsNo values and for two
% different Doppler values. To do this, we set the sweep values for each
% test parameter using the setTestParameterSweepValues method.

% Set EsNo sweep values from -2 to 8 dB
setTestParameterSweepValues(testConsole,'EsNo',-2:2:8)

% Set maximum Doppler shift sweep values to 0 and 200
setTestParameterSweepValues(testConsole,'Doppler',[0 200])


%%
% To verify that the sweep values have been set call the
% getTestParameterSweepValues method of the test console. Observe how 'M' is
% set to its default value of 2. When we do not specify sweep values for a
% test parameter, the test console runs simulations using the parameter's
% registered default value. 

% Get sweep values for test parameter 'EsNo'
getTestParameterSweepValues(testConsole,'EsNo')
%%

% Get sweep values for test parameter 'Doppler'
getTestParameterSweepValues(testConsole,'Doppler')

%%

% Get sweep values for test parameter 'M'
getTestParameterSweepValues(testConsole,'M')

%% Registering Test Points
% Test points are used to pair two data probes that were previously
% registered to the test console by the communications system. A test point
% contains two probes, and if desired, a handle to a user-defined error
% calculator function. The IEEE80211b system registered two test probes
% named 'TxInputSymbols', and 'RxOutputSymbols' when it was attached to the
% test console, as can be seen in the information displayed by the INFO
% method. In this demo, a single test point named 'SymbolErrorRate' will be
% registered and will contain the two aforementioned test probes and a
% handle to a user-defined error calculator function,
% errorCalculatorFunction80211b.m, defined specifically for the IEEE80211b
% system. Error rates will be calculated by comparing data available in the
% two probes using the user-defined error calculator function. In this demo,
% a user-defined error calculator function is necessary since error
% calculation needs to account for transmitter and receiver delays caused by
% the root raised cosine pulse shaping filters and the differential
% modulation. The default error calculator function available in the Error
% Rate Test Console performs simple one-to-one comparisons of the data in
% the probes and does not account for transmitter-receiver delays. Test
% points will hold error and transmission counts for each sweep point
% simulation.

registerTestPoint(testConsole,'SymbolErrorRate','TxInputSymbols', ...
    'RxOutputSymbols',@IEEE80211bErrorCalculator)

%% 
% We can review all the test console simulation settings by calling the INFO
% method again
info(testConsole)

%% Setting the Simulation Stop Criteria
% The simulation for a particular EsNo value may be stopped in different
% ways. You can control the stop mechanism using the SimulationLimitOption
% property of the test console. Simulations may be stopped when a specified
% number of transmissions, or errors has been reached. In this demo
% simulations will be stopped when at least 100 errors are counted for each
% EsNo value, or when 5 packets have been transmitted, whichever happens
% first (we choose only 5 packet transmissions to keep the simulation time
% short, longer simulation results will be presented shortly). For this
% purpose the SimulationLimitOption property is set to 'Number of errors or
% transmissions', the MinNumErrors property is set to 100, and the
% MaxNumTransmissions property is set to 5*testConsole.FrameLength. The
% TransmissionCountTestPoint, and ErrorCountTestPoint properties are set to
% the name of the only available test point 'SymbolErrorRate'. This last
% property is used to tell the test console at which of the test points to
% look for the transmission and error counts. 

testConsole.SimulationLimitOption = 'Number of errors or transmissions';
testConsole.MaxNumTransmissions = 5*testConsole.FrameLength;
testConsole.MinNumErrors = 100;
testConsole.TransmissionCountTestPoint = 'SymbolErrorRate';
testConsole.ErrorCountTestPoint = 'SymbolErrorRate';
disp(testConsole)

%% Setting the Simulation Reset Criteria
% The system reset criteria is controlled by the SystemResetMode property of
% the Error Rate Test Console. When this property is set to 'Reset at new
% simulation point' the system under test is reset only at the beginning of
% a new simulation point. When this property is set to 'Reset at every
% iteration' the system under test will be reset at every iteration. We
% choose the 'Reset at new simulation point' option.

testConsole.SystemResetMode = 'Reset at new simulation point';
%% Setting the Iteration Mode Criteria
% The iteration mode refers to the way in which the test console combines
% test parameter sweep values to perform simulations. The IterationMode
% property of the test console controls this behavior. When this property is
% set to 'Combinatorial', simulations are performed for all possible
% combinations of registered test parameter sweep values. When this property
% is set to 'Indexed', simulations are performed for all indexed sweep value
% sets. The ith sweep value set consists of the ith element of every sweep
% value vector of each registered test parameter. In the simulations at
% hand, we want to obtain results for all the combinations of EsNo and
% Doppler sweep values so we choose the 'Combinatorial' option. 

testConsole.IterationMode = 'Combinatorial';
%% Running 802.11b Error Rate Simulations
% The simulations for the specified EsNo and Doppler sweep values may be run
% by calling the run method of the Error Rate Test Console.

run(testConsole)

%% Getting and Plotting Results
% Results my be obtained by calling the getResults method of the error rate
% test console,

results80211b = getResults(testConsole);

%%
% In order to obtain more accurate results we increased MinNumErrors to 1000,
% MaxNumTransmissions to 200*testConsole.FrameLength, and ran the simulation
% again. Since the simulation takes a long time we saved the results object
% results80211b in IEEE80211bDemoResults.mat.

load IEEE80211bDemoResults.mat
disp(results80211b)

%%
% results80211b is a testconsole.Results object that contains all the
% results for all the specified test points and sweep values. In the
% simulation at hand only one test point called 'SymbolErrorRate' was
% registered. The resulting data and plots for this test point may be
% obtained by calling the getData and plot or semilogy methods of the
% results object results80211b. 
%
% If we want to obtain error rate results versus EsNo values for Doppler
% shifts of 0 and 200 Hz we configure the results80211b object to have
% 'EsNo' as TestParameter1 (parameter in control of the rows of the data
% matrix and of the x-axis of the plot) and 'Doppler' as TestParameter2
% (parameter in control of the columns of the data matrix and of the number
% of parametric curves in the plot). 

results80211b.TestParameter1 = 'EsNo';
results80211b.TestParameter2 = 'Doppler';
% Get results data
data = getData(results80211b)
%%

% Plot results in semi-log scale
semilogy(results80211b,'LineWidth',2)

%% 
% *Exploring Results For Different Metrics*
%
% Calling the INFO method allows us to see the test metrics available in the
% Error Rate Test Console: 'ErrorCount', 'TransmissionCount', 'ErrorRate'.
% To see the results for these metrics set the Metric property of the
% results80211b object accordingly and get the results data. 
%
% Get the error count from the results object:

results80211b.Metric = 'ErrorCount';
getData(results80211b)

%%
% Get the transmissions count from the results object:

results80211b.Metric = 'TransmissionCount';
getData(results80211b)

%%
% Recall that since TestParameter1 = 'EsNo', and TestParameter2 = 'Doppler',
% rows of the results data correspond to different 'EsNo' values while
% columns correspond to different 'Doppler' values. 


%% Summary
% We utilized the Error Rate Test Console to simulate an IEEE 802.11b
% physical layer system over a flat fading Rayleigh channel. The system was
% defined using the System Basic API. We specified sweep values for EsNo and
% maximum Doppler shift to obtain simulation results. We registered a test
% point to detect and count symbol errors. We obtained plots of symbol error
% rate versus EsNo for two different Doppler shifts. 

%% Further Exploration
% You can modify parts of this demo or the system definition, IEEE80211b.
%
% You can add more test parameters by registering these as test parameters
% in the register method of the IEEE80211b system. For example, you can
% register the RollOffFactor property as a test parameter to obtain
% simulations using different pulse shaping roll-off factor values. You can
% do the same with the FilterOrder property. 

%% Selected Bibliography
% # IEEE Std 802.11, "Part 11: Wireless LAN Medium Access Control (MAC) and
% Physical Layer (PHY) Specifications," 2007.

displayEndOfDemoMessage(mfilename)

