function [machineName,chartFileNumber] = get_machine_and_chart_file_number(blockH)
%get_machine_and_chart_file_number(blockName) 
%   Used by runtime library to bind SF blocks to chart instances in the
%   generated code.

%   Copyright 1995-2006 The MathWorks, Inc.

parent = get_param(blockH,'parent');
chartId = block2chart(get_param(parent,'handle'));
chartFileNumber = sf('get',chartId,'chart.chartFileNumber');
machineId = sf('get',chartId,'chart.machine');
machineName = sf('get',machineId,'machine.name');



