function retVal = sf_is_unified_editor_visible(chartOrSubchartID)

% Note that the diagram for chartOrSubchartID might be present and seen on
% the parent editor. Although the name fo this function talks about editor
% we check for the diagram. 
% xxx TODO: sramaswa, change the names of the functions to be more
% meaningful.
retVal = ~isempty(StateflowDI.SFDomain.id2Diagram(chartOrSubchartID));

end

% [EOF]
