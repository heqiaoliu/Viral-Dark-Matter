function [columns icons] = getHeaderLabels(h)

%   Copyright 2009 The MathWorks, Inc.

columns = {};
icons   = {};

% no need to do any work if the view has no properties
if ~isempty(h.Properties)
    props   = find(h.Properties, 'isVisible', true);
    columns = get(props, 'Name');
    
    if ~isempty(columns) && ~iscell(columns)
        columns = {columns};
    end

    % Find some efficient way of doing this. Some m-tricks.
    icons = cell(size(columns));
    for i = 1:length(columns)
       if (props(i).isMatching)
        if slfeature('ModelExplorerPropertyFilter')
            icons{i} = [matlabroot '/toolbox/shared/dastudio/resources/PropMatch.png'];
        else
            icons{i} = '';
        end
       end
    end
end

% ensure 'Name' is the first column header
if isempty(columns)
    columns = {'Name'};
    icons   = {''};
else
    columns = ['Name'; columns];
    icons   = [ {''}; icons];
end