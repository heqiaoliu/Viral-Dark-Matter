%% Using Code Generation Verification
% This demonstration explores how to configure, execute, and compare a model in
% Normal and Software-in-the-Loop (SIL) simulations, showing the capabilities of code
% generation verification (CGV).
% Processor-in-the-Loop (PIL) modes are also available.

% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.6.3.2.1 $  $Date: 2010/06/14 14:28:17 $


%% Reviewing the Demo Model
% The <matlab:open_system('rtwdemo_cgv'); |rtwdemo_cgv|>  model uses buses, scalars,
% and vectorized data, and includes error injection to create differences between
% test executions.  To open the model, type the following commands in the MATLAB
% Command Window.
%

cgvModel = 'rtwdemo_cgv';
close_system(cgvModel,0);
open_system( cgvModel);

%%
% The model has a hierarchical bus across the top, with three nested buses. This
% arrangement of buses produces complex hierarchical data at the first logged output.
% The model injects errors in the signal at the second outport at fixed intervals.
% These errors are guaranteed to produce different results between any two runs,
% allowing for a better demonstration of the comparison code further down.
% The signal at the third outport is a vector of four values per sample.  Again, this
% is mainly to show the comparison support.
%
% NOTE:
% Before executing the code in this demo, change to a writable directory.
% The following code does this for you:
baseVars = who;  % For future cleanup.
OriginalFolder = pwd;
cd (tempdir);
save_system( cgvModel, fullfile( pwd, cgvModel)); % Save to the working directory
close_system( cgvModel, 0); % Avoid having the saved model shadowed by the original

%% Verifying the Model Configuration
% CGV provides a helper class to verify that models have the correct configuration in
% order to run in the SIL or PIL environments as an ert target.  
% For example, the rtwdemo_cgv model is saved with 32-bit processor word sizes, so if
% you run the model on a 64-bit machine, then cgv.Config modifies the configuration
% for the 64-bit processor word size.  The 'Savemodel' parameter saves the model, if
% it changes.
cgvCfg = cgv.Config( cgvModel, 'Connectivity', 'sil', 'Savemodel', 'on');
cgvCfg.configModel();
cgvCfg.displayReport();

%% 
% When the model changes, displayReport reports the changes and 'Savemodel' saves the
% changes.  If you run this model on 32-bit system, then it is likely that no changes
% are needed.

%% Executing under CGV
% The model executes in two modes under CGV: Normal and SIL simulations.
% In each case, the CGV object captures the output data, and writes it to
% a file. 
% See <matlab:doc('cgv.CGV'); |CGV Documentation|> for more details.
% To execute this model in Normal and SIL simulation modes, type the following:

cgvSim = cgv.CGV( cgvModel, 'Connectivity', 'sim');
cgvSim.addInputData(1, [cgvModel '_data']);
% This next CGV function, addPostLoadFiles(), allows you to specify MATLAB
% programs to execute, or mat-files to load, before execution of the model.
cgvSim.addPostLoadFiles({[cgvModel '_init.m']});
cgvSim.setOutputDir('cgv_output');
result1 = cgvSim.run();

cgvSil = cgv.CGV( cgvModel, 'Connectivity', 'sil');
cgvSil.addInputData(1, [cgvModel '_data']);
cgvSil.addPostLoadFiles({[cgvModel '_init.m']});
cgvSil.setOutputDir('cgv_output');
result2 = cgvSil.run();

%% 
% The run function returns a Boolean value: true for successful execution. Check the
% results of both the Normal and SIL simulation before accessing the data. Neither
% execution should fail, but for correctness, it is always best to check.  If an
% error occurs, CGV reports it.
if ~result1 || ~result2
    error('Execution of model failed.');
end

simData   = cgvSim.getOutputData(1);
silData   = cgvSil.getOutputData(1);

%% Comparing Results
% 
% Both executions are now complete.  Compare the results.
% Comparison code supports plot with filters.  Plots display both the data and, if
% there is one, the difference.
% 
% CGV helper functions include the display of all signals names (as used in the
% command window), and creating a file correlating tolerance information with signal
% names.
%
%%
% *Showing Signal Names from Normal Simulation*
%
% Display a list of signal names from the saved data:
cgv.CGV.getSavedSignals( simData);

%% 
% 
% NOTE: cgv.CGV.compare ignores any signals that appear in only one data set or the
% other. For example, a logged internal signal that appears in the output in a Normal
% simulation does not appear in the output in SIL simulation, and is ignored by the
% compare code.  Therefore, the simData.hi0.Data signals will not be in the
% comparison, further below, because the signals do not appear in silData.

%%
% *Creating a Tolerance File*
% 
% The CGV createToleranceFile function creates a file correlating tolerance
% information with signal names.  See
% <matlab:helpview(fullfile(docroot,'toolbox','ecoder','helptargets.map'),'ecoder_cgv_createToleranceFile') cgv.CGV.createToleranceFile>
% for the options available to configure tolerances.  By default, tolerances are
% zero, so signals must match exactly. This example allows a delta of 0.5 on the
% ErrorsInjected signal.
%
signalList = {'simData.ErrorsInjected.Data' };
toleranceList = { { 'absolute', 0.5}};
cgv.CGV.createToleranceFile( 'localtol', signalList, toleranceList );

%% 
% *Comparing All Signals*
%
% By default, the cgv.CGV.compare function looks at all signals that have a common
% name between both executions. A plot results from the mismatch on signal
% simData.ErrorsInjected.Data.
%
% The second and fourth return parameters of the compare function are for matched
% figures and mismatched figures. Tildes (~) represent these parameters because this
% example does not use the return values.

[matchNames, ~, mismatchNames, ~] = ...
    cgv.CGV.compare( simData, silData, 'Plot', 'mismatch', ...
    'Tolerancefile', 'localtol');
fprintf( '%d Signals match, %d Signals mismatch\n', ...
    length(matchNames), length(mismatchNames));
disp( 'Mismatched Signal Names:');
disp(mismatchNames);

%% 
% *Comparing Individual Signals*
%
% The cgv.CGV.compare function also compares only specified signals, ignoring the
% rest.  Here, the function compares only three signals.
%
[matchNames, ~, mismatchNames, ~ ] = ...
    cgv.CGV.compare( simData, silData, 'Plot', 'mismatch', ...
    'Signals', {'simData.BusOutputs.hi1.mid0.lo1.Data', 'simData.BusOutputs.hi1.mid0.lo2.Data', ...
    'simData.Vector.Data(:,3)'});
fprintf( '%d Signals match, %d Signals mismatch\n', ...
    length(matchNames), length(mismatchNames));
if ~isempty(mismatchNames)
    disp( 'Mismatched Signal Names:');
    disp(mismatchNames);
end

%% Getting Additional Plotting Support
% To create a plot of a list of signals in a similar form to the plots that the
% compare function provides, call cgv.CGV.plot.  For example:
%

[signalNames, signalFigures] = cgv.CGV.plot( simData, ...
    'Signals', {'simData.Vector.Data(:,1)'});

%% 
% *Clearing Your Workspace*
%
% Clear from the workspace the many variables that this demo creates:
% 
cd (OriginalFolder);
newBaseVars = who;
addedVars = setdiff( newBaseVars, baseVars);
clearCmd = ['clear ' sprintf( '%s ', addedVars{:})];
eval( clearCmd);
clear newBaseVars addedVars clearCmd 

%% For More Information 
% For information about SIL and PIL, see <matlab:showdemo('rtwdemo_sil_pil_script');
% |rtwdemo_sil_pil_script|>.
%

displayEndOfDemoMessage(mfilename)
