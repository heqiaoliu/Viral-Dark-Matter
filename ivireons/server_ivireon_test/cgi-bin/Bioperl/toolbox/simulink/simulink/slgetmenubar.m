function schemas = slgetmenubar

% Copyright 2005 The MathWorks, Inc.

    cm = DAStudio.CustomizationManager;
    fcns = cm.getCustomToolsMenuFcns;
    
    schemas = cell(0);
    
    for i=1:length(fcns)
        items = fcns{i}();
        
        if isempty(items)
            continue;
        end

        schemas{end+1} = 'separator';
        
        for k=1:length(items)
            schemas{end+1} = items{k};
        end
    end
end