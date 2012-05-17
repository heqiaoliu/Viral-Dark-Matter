function getdisp(obj)
% Create the property display for GET(OBJ).

%   Copyright 2010 The MathWorks, Inc.

    % Get a list of properties and their category information.
    propertyNames = fieldnames(obj);
    [categoryHeadings, categoryIndices] = getCategoryInfo(obj,propertyNames);
    
    % Capture the default getdisp display to provide us with a formatted 
    % display of some property values.
    getDisp = evalc('getdisp@hgsetget(obj)');
    
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
        
            propName = propertyNames{pi};
            propValue = get(obj, propName);
        
            % For strings, display the value to avoid having extra quotes.
            % For all other types, use the formated value display from 
            % the GET structure display. 
            if ~ischar(propValue)
                % Locate the start of the property's value in the display.
                propLabel = [propName ': '];
                startIndex = strfind(getDisp, propLabel) + length(propLabel);

                % Extract the property's value.
                propValue = strtok(getDisp(startIndex:end), sprintf('\n'));
            end
            fprintf('    %s = %s\n', propName, propValue);
        end
        
        % Blank line.
        fprintf('\n');
    end
end
        
