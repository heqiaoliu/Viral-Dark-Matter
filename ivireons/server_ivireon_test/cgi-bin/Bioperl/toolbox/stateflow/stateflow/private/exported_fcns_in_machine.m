function exportedFcnInfo = exported_fcns_in_machine(machineId,linkedChartsInMainMachine,linkHndlsInMainMachine)
%   Copyright 1995-2010 The MathWorks, Inc.
%   $Revision: 1.3.2.11 $  $Date: 2010/05/20 03:36:06 $

if(nargin<2)
    linkedChartsInMainMachine = [];
    linkHndlsInMainMachine = [];
end

machineName = sf('get',machineId,'machine.name');
machineIsLibrary = sf('get',machineId,'machine.isLibrary');
charts = sf('get',machineId,'machine.charts');
charts = sf('find',charts,'chart.exportChartFunctions',1);
exportedFcnInfo = [];
errorCount =0;
for i=1:length(charts)
    chart = charts(i);
    if(machineIsLibrary)
        % G133588. consider only those charts that are linked to the
        % main-machine
        idx = find(linkedChartsInMainMachine == chart, 1);
        linkHndl = linkHndlsInMainMachine(idx);
        doit = ~isempty(idx);
    else
        linkHndl = chart2block(chart);
        doit = true;
    end
    if(doit)
        chartName = sf('FullNameOf',chart,'/');
        exportedFunctions  = sf('find',sf('AllSubstatesOf',chart),'state.type','FUNC_STATE');
        for j=1:length(exportedFunctions)
            [thisInfo,errorCount] = get_exported_fcn_info(exportedFunctions(j),machineName,chartName,errorCount,linkHndl);
            exportedFcnInfo = [exportedFcnInfo,thisInfo];
        end
    end
end
if(errorCount>0)
    construct_error(machineId, 'Build', 'Errors occurred during processing of exported graphical functions', 1);
end    
exportedFcnInfo = sort_exported_fcns_info(exportedFcnInfo);

for i=1:length(exportedFcnInfo)
    if(i~=1)
        if(strcmp(exportedFcnInfo(i-1).name,exportedFcnInfo(i).name))
            errorStr = ['Multiple exported graphical functions with the',10,...
                        'same name "',exportedFcnInfo(i).name,'" exist in charts:',10,...
                        '"',exportedFcnInfo(i-1).chartName,'"',10,...
                        '"',exportedFcnInfo(i).chartName,'"'];
            construct_error(machineId, 'Build', errorStr, 1);
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [thisInfo,errorCount] = get_exported_fcn_info(exportedFcnId,machineName,chartName,errorCount,linkHndl)

thisInfo.machineName = machineName;
thisInfo.chartName = chartName;

thisInfo.name = sf('get',exportedFcnId,'.name');
allData = sf('DataOf',exportedFcnId);
inputData = sf('find',allData,'data.scope','FUNCTION_INPUT_DATA');
outputData = sf('find',allData,'data.scope','FUNCTION_OUTPUT_DATA');
thisInfo.inputDataInfo = [];
for i=1:length(inputData)
    [inputDataInfo,errorCount] = get_data_info(exportedFcnId,inputData(i),errorCount,linkHndl);
    thisInfo.inputDataInfo = [thisInfo.inputDataInfo,inputDataInfo];
end
thisInfo.outputDataInfo = [];
for i=1:length(outputData)
    [outputDataInfo,errorCount] = get_data_info(exportedFcnId,outputData(i),errorCount,linkHndl);
    thisInfo.outputDataInfo = [thisInfo.outputDataInfo,outputDataInfo];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [dataInfo,errorCount] = get_data_info(exportedFcnId,dataId,errorCount,linkHndl)
    dataInfo.id = dataId;
    dataParsedInfo = sf('DataParsedInfo',dataId,linkHndl);
    dataInfo.size = dataParsedInfo.size;
    dataInfo.type = dataParsedInfo.type.baseStr;
    if(strcmp(dataInfo.type,'fixpt'))
        dataInfo.isSigned = dataParsedInfo.type.fixpt.isSigned;
        dataInfo.wordLength = dataParsedInfo.type.fixpt.wordLength;
        dataInfo.bias = dataParsedInfo.type.fixpt.bias;
        dataInfo.slope = dataParsedInfo.type.fixpt.slope;
        dataInfo.exponent = dataParsedInfo.type.fixpt.exponent;
    else
        dataInfo.isSigned = [];
        dataInfo.wordLength = [];
        dataInfo.bias = [];
        dataInfo.slope = [];
        dataInfo.exponent = [];
    end

    if(strcmp(dataInfo.type,'structure'))
        fcnName = sf('get',exportedFcnId,'.name');
        dataName = sf('get',dataId,'.name');
        errorStr = sprintf('Chart level exported graphical function ''%s'' (#%d)',fcnName,exportedFcnId);
        errorStr = sprintf('%s cannot have input or output data ''%s'' (#%d) of bus type',errorStr, dataName,dataId);
        
        construct_error(sf('get',exportedFcnId,'.chart'), 'Parse', errorStr, 0);
        errorCount = errorCount+1;
    end
    
    if(strcmp(dataInfo.type, 'enumerated'))
        
        % disallow enumerated types and just throw an error for now
        fcnName = sf('get',exportedFcnId,'.name');
        dataName = sf('get',dataId,'.name');
        errorStr = sprintf('Chart level exported graphical function ''%s'' (#%d)',fcnName,exportedFcnId);
        errorStr = sprintf('%s cannot have input or output data ''%s'' (#%d) of enumerated type',errorStr, dataName,dataId);
        construct_error(sf('get',exportedFcnId,'.chart'), 'Parse', errorStr, 0);
        errorCount = errorCount+1;        
    end

    if dataParsedInfo.complexity == 1
        fcnName = sf('get',exportedFcnId,'.name');
        dataName = sf('get',dataId,'.name');
        errorStr = sprintf('Chart level exported graphical function ''%s'' (#%d)',fcnName,exportedFcnId);
        errorStr = sprintf('%s cannot have input or output data ''%s'' (#%d) of complex type',errorStr, dataName,dataId);
        
        construct_error(sf('get',exportedFcnId,'.chart'), 'Parse', errorStr, 0);
        errorCount = errorCount+1;        
    end

    if (~isempty(dataInfo.wordLength) && dataInfo.wordLength > 32)
        % Multi-word fixpt. g598361
        fcnName  = sf('get', exportedFcnId, '.name');
        dataName = sf('get', dataId, '.name');
        errorStr = sprintf('Chart level exported graphical function ''%s'' (#%d)', fcnName, exportedFcnId);
        errorStr = sprintf(['%s cannot have input or output data ''%s'' (#%d) of ' ...
            'multi-word fixed-point type'], errorStr, dataName, dataId);
        construct_error(sf('get', exportedFcnId, '.chart'), 'Parse', errorStr, 0);
        errorCount = errorCount + 1;
    end
    
    isVardim = sf('IsVariableSizingON', exportedFcnId) && sf('get', dataId, '.props.array.isDynamic');
    if(isVardim)
        % g575069
        fcnName  = sf('get', exportedFcnId, '.name');
        dataName = sf('get', dataId, '.name');
        errorStr = sprintf('Chart level exported graphical function ''%s'' (#%d)', fcnName, exportedFcnId);
        errorStr = sprintf(['%s cannot have input or output data ''%s'' (#%d) of ' ...
            'dynamic matrix type'], errorStr, dataName, dataId);
        construct_error(sf('get', exportedFcnId, '.chart'), 'Parse', errorStr, 0);
        errorCount = errorCount + 1;
    end
    