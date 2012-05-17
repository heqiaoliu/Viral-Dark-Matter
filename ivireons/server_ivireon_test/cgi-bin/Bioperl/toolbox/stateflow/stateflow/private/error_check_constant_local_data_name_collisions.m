function error_check_constant_local_data_name_collisions(machineId,linkMachines)

% Copyright 2005 The MathWorks, Inc.

usedCharts = compute_all_used_charts_in_main_machine(machineId,linkMachines);

constData = [];
localData = [];
for i=1:length(usedCharts)
    chartId = usedCharts(i);
    allData = sf('DataIn',chartId);
    constData = [constData,sf('find',allData,'data.scope','CONSTANT_DATA')];
    localData = [localData,sf('find',allData,'data.scope','LOCAL_DATA')];
end

errorOccurred = 0;
for i=1:length(constData)
    constDataName = sf('get',constData(i),'data.name');
    collidingLocalData = sf('find',localData,'data.name',constDataName);
   for j = 1:length(collidingLocalData)
       errorStr = sprintf(['Local data name "%s" (#%d) collides with a constant data (#%d) of the same name.',...
               'This can cause uncompilable code to be generated.',...
               'Please rename one of them to avoid this collision.'],constDataName,collidingLocalData(j),constData(i));
       construct_error(machineId, 'Build', errorStr, 0);
       errorOccurred = 1;
   end
end
if(errorOccurred)
   construct_error(machineId, 'Build', 'Name collisions detected. Cannot continue code generation', 1);    
end

