function editors = sf_debug_get_unified_editor(chartOrSubchartID)

udi = idToHandle(sfroot, chartOrSubchartID);

name = udi.getFullName();
editors = GLUE2.Util.findAllEditors(name);

end

% EOF


