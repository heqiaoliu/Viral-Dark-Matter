function all_editors = sf_debug_collect_all_unified_editors_related_to(chartId)

assert(sf('get',chartId,'.isa') == 1);
all_editors = [];

subchartIds = sf('SubchartsIn', chartId);
sfIds = [chartId subchartIds];

for i = 1:length(sfIds)
    editors = sf_debug_get_unified_editor(sfIds(i));
    if(~isempty(editors))
       all_editors = [all_editors editors];  %#ok<AGROW>
    end
end

chartObj = idToHandle(sfroot, chartId);
slContainerObj = chartObj.getParent;
slContainerName = slContainerObj.getFullName;

slEditors = GLUE2.Util.findAllEditors(slContainerName);

if(~isempty(slEditors))
    all_editors = [all_editors slEditors];
end

end

% EOF
