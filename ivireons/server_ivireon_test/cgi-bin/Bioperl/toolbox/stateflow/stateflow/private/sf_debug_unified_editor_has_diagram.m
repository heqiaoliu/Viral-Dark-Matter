function retVal = sf_debug_unified_editor_has_diagram(chartOrSubchartID)

diagram = StateflowDI.SFDomain.id2Diagram(chartOrSubchartID);

retVal = diagram.isvalid;

% [EOF]
