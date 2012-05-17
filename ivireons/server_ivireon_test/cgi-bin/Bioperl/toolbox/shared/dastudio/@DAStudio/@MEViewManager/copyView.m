function [newView message] = copyView(h, source, target)
% Check message if newView is empty.

%   Copyright 2009 The MathWorks, Inc.

newView = [];
message = '';
% Check if source exists, if not return false.
sourceView = find(h, '-isa', 'DAStudio.MEView', 'Name', source);
if isempty(sourceView)
    message = 'Source view does not exist.';
    return;
end
% Check if view with target name already exists, if it exists return false
targetView = find(h, '-isa', 'DAStudio.MEView', 'Name', target);
if ~isempty(targetView)
    message = 'Target view already exists.';
    return;
end
% Create a new view.
newView = DAStudio.MEView(target, sourceView.Description);
% Set properties.
if ~isempty(sourceView.Properties)
	h.disableLiveliness;
	newView.Properties = copy(sourceView.Properties);
	if ~isempty(sourceView.Properties)
	    % Set matching properties.
	    properties = find(sourceView.Properties, 'isMatching', true);
	    % Any shortcut?
	    for i = 1:length(properties)
	        prop = find(newView.Properties, 'Name', properties(i).Name);
	        prop.isMatching = true;
	    end
	end
	h.enableLiveliness;
end

