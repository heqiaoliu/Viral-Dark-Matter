function updatestats(h)

% Copyright 2004-2005 The MathWorks, Inc.

tsdata = h.Timeseries.Data;
tableData =  cell(size(tsdata,2),6);
for k=1:size(tableData,1)
    I = find(~isnan(tsdata(:,k)));
    if ~isempty(I)
        tableData(k,:) = {sprintf('%d',k),num2str(mean(tsdata(I,k))), ...
            num2str(median(tsdata(I,k))),...
            num2str(std(tsdata(I,k))),...
            num2str(min(tsdata(I,k))),...
            num2str(max(tsdata(I,k)))};
    else
        tableData(k,:) = {sprintf('%d',k),'','','','',''};
    end
end
h.Handles.statsTable.getModel.setDataVector(tableData,...
    {xlate('Column #'),xlate('Mean'),xlate('Median'),xlate('STD'),xlate('Min'),xlate('Max')},...
    h.Handles.statsTable);