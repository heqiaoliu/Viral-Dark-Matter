function objs = callbackinfo_get_selection(h)

% Copyright 2004-2005 The MathWorks, Inc.

objs = [];
switch class(h.uiObject),
    %
    % Stateflow Editor cases
    %
    case 'Stateflow.Chart',
        objs = sf_get_selection_from_chart_l(h.uiObject.id);
    case 'Stateflow.State', % this should only happen for subcharts.
        if (h.uiObject.isSubchart),
            objs = sf_get_selection_from_chart_l(h.uiObject.chart.id);
        end;
        
    %
    % Simulink Editor cases
    %
    case {'Simulink.BlockDiagram', 'Simulink.SubSystem'},
        objs = find(h.uiObject, 'Selected','on','-depth', 1);
        objs (objs==h.uiObject) = []; % remove yourself as you are the context.
      
    %
    % Model Explorer
    %
    case 'DAStudio.Explorer'
        imME = DAStudio.imExplorer(h.uiObject);
        objs = imME.getSelectedListNodes;
end;


    
function objs = sf_get_selection_from_chart_l(chart),
       r = sfroot;
       selectedIds = sf('SelectedObjectsIn', chart);
       if ~isempty(selectedIds),
           objs = r.idToHandle(selectedIds);
       else,
           objs = [];
       end;
