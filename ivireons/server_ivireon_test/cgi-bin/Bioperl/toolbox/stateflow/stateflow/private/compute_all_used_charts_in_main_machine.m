function usedCharts = compute_all_used_charts_in_main_machine(machineId,linkMachines)
%   Copyright 1995-2005 The MathWorks, Inc.

if(nargin<2)
    linkMachines = [];
end

usedCharts = sf('get',machineId,'machine.charts');

allLinks = sf('get',machineId,'machine.sfLinks');
linkedCharts = zeros(length(allLinks),1);
for i=1:length(allLinks)
    linkedCharts(i) = block2chart(allLinks(i));
end
linkedCharts= unique(linkedCharts);

usedCharts = [usedCharts,linkedCharts(:)'];

