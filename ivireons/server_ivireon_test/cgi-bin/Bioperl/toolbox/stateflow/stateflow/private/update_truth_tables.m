function errorCount = update_truth_tables(machineId, ignoreError, modelName)
%   Copyright 1995-2005 The MathWorks, Inc.
%   $Revision: 1.5.4.6 $  $Date: 2009/12/28 04:52:40 $

if(~isempty(sf('get',machineId,'chart.id')))
    chartId = machineId;
    machineId = sf('get',chartId,'chart.machine');
else
    chartId = [];
end

if nargin < 2
    ignoreError = false;
end

if nargin < 3
    % model name and machine name could be different during save as.
    modelName = sf('get',machineId,'machine.name');
end

isLibrary = sf('get',machineId,'machine.isLibrary');
lockStatus = 'off';
if(isLibrary)
    % Must unlock and save lock status G146302
    lockStatus = get_param(modelName,'lock');
    set_param(modelName,'lock','off');
end
errorCount= 0;
if(~isempty(chartId))
    ttFcns = truth_tables_in(chartId);
else
    ttFcns = truth_tables_in(machineId);
end

for j = 1:length(ttFcns)
    errorCount = errorCount + update_truth_table_for_fcn(ttFcns(j),1);
end

if(isLibrary)
    % Restore lock status G146302
    set_param(modelName,'lock',lockStatus);
end

if (~ignoreError && errorCount > 0)
    construct_error( machineId, 'Parse', xlate('Errors occurred during truth table parsing'), 1);    
end
