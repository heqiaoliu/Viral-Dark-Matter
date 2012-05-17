%       Copyright 1995-2009 The MathWorks, Inc.

function outVal = construct_chart_ir_for_rtw(blockH,S,auxiliaryInfo)

    outVal = 1;
    mainModelH = bdroot(blockH);
    mainMachineId = sf('find','all','machine.simulinkModel',mainModelH);
    
    chartBlk = get_param(blockH,'parent');
    hChart = get_param(chartBlk, 'handle');
    chartId = block2chart(chartBlk);
    currMachineId = sf('get',chartId,'chart.machine');
    targetId = sf('find',sf('TargetsOf',currMachineId),'.name','rtw');
    
    if(mainMachineId~=currMachineId) 
        parentTargetId = sf('find',sf('TargetsOf',mainMachineId),'.name','rtw');
    else
        parentTargetId = targetId;
    end

    sf('SetChartSimStruct', chartId, S);
    errorOccurred = targetman('construct_chart_ir_for_rtw', targetId, false, false, parentTargetId,chartId,mainMachineId,auxiliaryInfo,hChart);
    sf('ClearChartSimStruct', chartId);

    if(errorOccurred)
        error('Stateflow:CodeConstructionError','Errors occurred during code construction');
    end
