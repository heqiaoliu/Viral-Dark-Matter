function result = chart_executes_at_initialization(chartIdOrHandle)
% Return whether chart has "ExecuteAtInitialization" turned on

chartId = chartIdOrHandle;

if ~is_sf_id(chartIdOrHandle)
    chartId = block2chart(chartIdOrHandle);
end

result = sf('ChartHasExecAtInit', chartId);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = is_sf_id(mId)

result = 0;

if ~isempty(mId) && ((floor(mId) - mId) == 0)
    result = sf('ishandle', mId);
end
