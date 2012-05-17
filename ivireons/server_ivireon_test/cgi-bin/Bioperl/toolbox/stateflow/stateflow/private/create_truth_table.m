function errorCount = create_truth_table(fcnId, ignoreErrors)
%   Copyright 2002-2005 The MathWorks, Inc.
%   $Revision: 1.7.4.10 $  $Date: 2005/10/14 16:39:01 $

if (nargin < 2)
    ignoreErrors = 0;
end

% Remember dirty flag on the chart and machine
chartId = sf('get', fcnId, 'state.chart');
machineId = sf('get', chartId, 'chart.machine');
modelH = sf('get', machineId, 'machine.simulinkModel');
chartDirty = sf('get', chartId, 'chart.dirty');
machineDirty = sf('get', machineId, 'machine.dirty');
modelDirty = get_param(modelH, 'dirty');

if is_eml_truth_table_fcn(fcnId)
    errorCount = create_truth_table_eml_script(fcnId);
else
    errorCount = create_truth_table_diagram(fcnId);
end

% Restore dirty flag on the chart and machine
if ~machineDirty
    sf('set', machineId, 'machine.dirty', 0);
end
if ~chartDirty
    sf('set', chartId, 'chart.dirty', 0);
end
set_param(modelH, 'dirty', modelDirty);

if ~ignoreErrors
    % long jump
    construct_tt_error('add', fcnId, xlate('Errors occurred during truth table parsing'), 1);
end

return;
