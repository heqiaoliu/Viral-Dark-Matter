function setdisp(obj)
% Create the property display for SET(OBJ).

%   Copyright 2010 The MathWorks, Inc.

    % Get a list of settable properties and their category information.
    propertyNames = getSettableProperties(obj); 
    [categoryHeadings, categoryIndices] = getCategoryInfo(obj, propertyNames);
    
    % For each category.
    for ci=1:length(categoryIndices)
        % If no properties for this category, go to next.
        if isempty(categoryIndices{ci})
            continue;
        end
        
        % Heading
        fprintf('  %s:\n', categoryHeadings{ci}); 
        
        % Property names and values...
        for pi=categoryIndices{ci}
            
            % Print the property name and settable value (if enum or callback).
            propName = propertyNames{pi};
            propValue = set(obj, propName);
            assert(isempty(propValue) && isempty(strfind('Fcn ', [propName ' '])),...
                  'Must build an enum or callback string for setdisp');
            fprintf('    %s\n', propName);
        end
        
        % Blank line.
        fprintf('\n');
    end
end        
