function exportedFcnInfo = update_exported_fcn_info(machineId,targetName,linkMachines)
%   Copyright 1995-2009 The MathWorks, Inc.
%   $Revision: 1.4.2.8 $  $Date: 2010/01/25 23:24:27 $


if(nargin<2)
    linkMachines = [];
end
exportedFcnInfo = exported_fcns_in_machine(machineId);

allLinks = sf('get',machineId,'machine.sfLinks');
linkedCharts = zeros(length(allLinks),1);
for i=1:length(allLinks)
    linkedCharts(i) = block2chart(allLinks(i));
end
[linkedCharts ii ~] = unique(linkedCharts);
linkHndls = allLinks(ii);

allLibsExportedFcnsInfo = [];
if(~isempty(linkMachines))
    for i=1:length(linkMachines)     
        linkMachineId = sf('find','all','machine.name',linkMachines{i});
        if(isempty(linkMachineId))
            error('Stateflow:UnexpectedError','Unexpected internal error loading library model %s',linkMachines{i});
        else
           libExportedFcnInfo = exported_fcns_in_machine(linkMachineId,linkedCharts,linkHndls);
        end
        check_for_multiple_links(machineId,libExportedFcnInfo);
        allLibsExportedFcnsInfo = [allLibsExportedFcnsInfo,libExportedFcnInfo];
    end
end
if(~isempty(allLibsExportedFcnsInfo))    
    exportedFcnInfo = [exportedFcnInfo,allLibsExportedFcnsInfo];
    exportedFcnInfo = sort_exported_fcns_info(exportedFcnInfo);
end

exportedFcnChecksum = exported_fcn_checksum(exportedFcnInfo);

sf('set',machineId...
    ,'machine.exportedFcnInfo',exportedFcnInfo...
    ,'machine.exportedFcnChecksum',exportedFcnChecksum);

    
function check_for_multiple_links(machineId,libExportedFcnInfo)

    if(isempty(libExportedFcnInfo))
        return;
    end
    libModelName = libExportedFcnInfo(1).machineName;
    chartNames = unique({libExportedFcnInfo.chartName});
    modelH = sf('get',machineId,'machine.simulinkModel');
    linkChartHandles = sf('get',machineId,'machine.sfLinks');
    %G517176: When using strcmp of the charts names, we should always use 
    %FullNameOf method to avoid getting tripped up by the newlines
    for i=1:length(linkChartHandles)
        linkChartSources{i} = sf('FullNameOf',block2chart(linkChartHandles(i)),'/');
    end
    for i=1:length(chartNames)
        sourceName = chartNames{i};
        instanceMatch = strcmp(sourceName,linkChartSources);
        badboys = linkChartHandles(instanceMatch);
        if(length(badboys)>1)
            % we found multiple link charts. yoohoo.
            msgStr = ['Library chart "',sourceName,'" exports graphical functions and can only',10,...
                      'have a single link-chart associated with it. ',10,...
                       'Detected the following multiple link-charts pointing to it:',10];
            for j=1:length(badboys)
                msgStr = [msgStr,...
                        '"',getfullname(badboys(j)),'"',10];
            end
            construct_error(machineId, 'Build', msgStr, 1);
        end
    end
        
