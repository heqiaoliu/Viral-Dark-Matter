function result = get_autoinheritance_info(machineName, mainMachineName, chartNumber) 

% Copyright 2004-2008 The MathWorks, Inc.

    result = [];

    mainMachineId = sf('find','all','machine.name',mainMachineName);
    rebuildMetaData = sf('get',mainMachineId,'machine.eml.rebuildMetaData');
    machineName0 = get_eml_metadata_machine_name(machineName);
    % If the chart is in the rebuild set, then the size information may be invalid for this
    % chart, and thus we return empty to indicate that this is the case.
    if ~isempty(rebuildMetaData) && isfield(rebuildMetaData, 'sfun') && isfield(rebuildMetaData.sfun, machineName0)
        if binsearch(rebuildMetaData.sfun.(machineName0).rebuildChartFiles,chartNumber) ~= 0
            result = [];
            return
        end
    end
    
    sfunName = [machineName '_sfun'];
    sfunFileName = [sfunName,'.',mexext];
    if (exist(sfunFileName,'file') == 3)
        try
            result = feval(sfunName, 'get_autoinheritance_info', chartNumber);
        catch
            result = [];
        end
    end
    
    if isempty(result)
        infoStruct = infomatman('load','binary',machineName,mainMachineName,'sfun');
        chartIndex = find(infoStruct.chartFileNumbers==chartNumber);
        if ~isempty(chartIndex) && isfield(infoStruct, 'chartInfo') && isfield(infoStruct.chartInfo, 'autoinheritanceInfo')
            result = infoStruct.chartInfo(chartIndex).autoinheritanceInfo;
        end
    end