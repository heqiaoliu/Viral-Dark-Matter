function view = getFactoryView(this)
% Get factory view for the domain.

%   Copyright 2009 The MathWorks, Inc.

% Returning empty view is fine as per specs and in that case there
% won't be any suggestion until and unless user makes explicit change
% in the view for an active domain.

% Return factory view for the given domain.
% Factory Suggestios and Domains map.
fSuggestions = {   'Simulink', 'Block Data Types'; ...
                   'Stateflow', 'Stateflow'; ...
                   'Workspace', 'Data Objects'; ...
                  };
% Default
viewName = 'Default';
if ~isempty(find(ismember(fSuggestions(:,1), this.Name) == 1))
    viewName = char(fSuggestions(ismember(fSuggestions(:,1), this.Name) == 1, 2));
end

view = find(this.ViewManager, '-isa', 'DAStudio.MEView', 'Name', viewName);
