function r = get_chart_testpoint_info(blockH)

r = [];

mainModelH = bdroot(blockH);
mainMachineId = sf('find','all','machine.simulinkModel',mainModelH);

sfunName = get_sfun_name(mainMachineId, 'sfun');
sfunFile = [sfunName '.' mexext];

if ~exist(sfunFile,'file')
    return;
end

chartBlk = get_param(blockH,'parent');
chartId = block2chart(chartBlk);
machineId = sf('get',chartId,'chart.machine');
machineName = sf('get',machineId,'machine.name');
chartFileNumber = sf('get',chartId, 'chart.chartFileNumber');

try
    r = feval(sfunName, 'get_testpoint_info', machineName, chartFileNumber);
catch
    r = [];
end
