function pil_demo_verify_callback(block)
% PIL_DEMO_VERIFY_CALLBACK - Open function callback for the "Verification Example"
% block in pil_demo_lib.
%
% pil_demo_verify_callback(block)
%
% block - The "Verification Example" block
%

% Copyright 2006-2007 The MathWorks, Inc.

error(nargchk(1, 1, nargin, 'struct'));

% obtain parameters from the block
simulationBlock = get_param(block,'simulationBlock');
targetBlock = get_param(block,'targetBlock');
% call target_block_verify
verify_function = 'target_block_verify';
nl = sprintf('\n');
disp(['** This is an EXAMPLE verification process. **' nl nl ...
      'Typically, the user will use the "' ...
      targets_hyperlink_manager('new', verify_function, ['help ' verify_function]) ...
      '" command ' ...
      'to obtain simulation and target results, and then ' ...
      'apply their own comparison method.' nl nl ...
      'In this example, we apply a simple comparison method, which includes ' ...
      'a basic comparison plot.' nl nl ...
      'Additionally, results are saved to a .MAT file.' nl nl]);
verify_return_args = '[simResults, targetResults] = ';
spacing = char(ones(1, (1 + length([verify_return_args verify_function]))) * double(' '));
verify_args = ['(''' simulationBlock ''', ... ' sprintf('\n') ...
               spacing '''' targetBlock ''')' sprintf('\n')];
command = [verify_function verify_args];
disp(['Running: ' sprintf('\n') ...
      verify_return_args ...
      targets_hyperlink_manager('new', verify_function, ['help ' verify_function]) ...
      verify_args]);
[simResults, targetResults] = eval(command);
algResName = 'simResults';
targetResName = 'targetResults';
% save results to a .MAT file
saveName = 'verification_results.mat';
save(saveName, algResName, targetResName);
disp(['Saved results to: ' saveName sprintf('\n')]);
%
% turn off Time Series Tool warning about data conversion
% the original datatypes are preserved in the .MAT file
tsWarning = 'tstool:nondoubledata';
tsWarnState = warning('off', tsWarning);
%
try 
   % use the Time Series Tool to plot the results
   tstool(simResults, 'replace');
   tstool(targetResults, 'replace');
   % get a handle to the Time Series Tool
   tsToolHandle = tsguis.tsviewer;
   % plot the differences for each port
   fnames = fieldnames(simResults);
   for i=1:length(fnames)
      fname = fnames{i};
      % only operate on port fields
      if strcmp(class(simResults.(fname)), ...
                 'Simulink.Timeseries')
         rdiff = simResults.(fname) - targetResults.(fname);
         tsName = [fname ': simulation - target results'];
         rdiff.Name = tsName;
         % check for an existing time series entry
         tsnode = tsToolHandle.SimulinkTSnode.getChildren('Label', tsName);
         if isempty(tsnode)
             % add as normal
             tstool(rdiff);
         else
             % update the content
             tsnode.Timeseries.TsValue = rdiff;
             % Tell the tstool about the change
             tsnode.timeseries.fireDataChangeEvent;
         end
      end
   end
catch e
   % restore the warning state
   warning(tsWarnState);
   rethrow(e);
end
% restore the warning state
warning(tsWarnState);

disp(['Successfully executed: ' sprintf('\n') ...
      verify_return_args ...
      targets_hyperlink_manager('new', verify_function, ['help ' verify_function]) ...
      verify_args]);
  