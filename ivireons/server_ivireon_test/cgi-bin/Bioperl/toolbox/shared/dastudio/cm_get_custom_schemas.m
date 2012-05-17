function schemas = cm_get_custom_schemas( tag )

% Copyright 2005-2010 The MathWorks, Inc.

    cm = DAStudio.CustomizationManager;
    fcns = cm.getCustomMenuFcns( tag );
    
    schemas = cell(0);
    
    for i=1:length(fcns)
        try
            items = fcns{i}();
        
            if isempty(items)
                continue;
            end

            schemas{end+1} = 'separator'; %#ok<AGROW>
        
            for k=1:length(items)
                schemas{end+1} = items{k}; %#ok<AGROW>
            end
        catch me
            warning(me.identifier, '%s', me.message)
        end
    end
end
