function save(h, viewsToSave, fileName)
% save
% This method writes all the views in the preference file.
%


% Copyright 2009-2010 The MathWorks, Inc.

views = [];

switch nargin
    case 2
        % Find all the views.
        views = find(h, '-isa', 'DAStudio.MEView');
        fileName = h.getFileName();
    case 3
        views = viewsToSave;
        fileName = fileName;       
end

allDomains = h.Domains;
% Start filling attributes.
for i = 1:length(views)
    meViews(i).Name = views(i).Name; 
    meViews(i).Domain = '';
    meViews(i).Description = views(i).Description;    
    % fill domain name for this view if any.
	for j = 1:length(allDomains)
		domainActView = allDomains(j).getActiveView();
		
		if ~isempty(domainActView) && strcmp(domainActView.Name, views(i).Name)
			meViews(i).Domain = allDomains(j).Name;
        end
    end
    meViews(i).Properties = [];
    if ~isempty(views(i).Properties)
        meViews(i).Properties = find(views(i).Properties, 'isVisible', true);
        meViews(i).GroupName = views(i).GroupName;
        meViews(i).SortName = views(i).SortName;
        meViews(i).SortOrder = views(i).SortOrder;        
    end
    if ~isempty(views(i).InternalName)
        meViews(i).InternalName = views(i).InternalName;
    end
end

try
    % Save as meViews.
    save(fileName, 'meViews');
    % These are preferences if filename is same.
    if strcmp(h.getFileName, fileName)
        % Save active view.
        activeView = h.ActiveView.Name;
        save(h.getFileName(), 'activeView', '-append');
        % Save suggestions settings.
        suggestionMode = h.SuggestionMode;
        save(h.getFileName(), 'suggestionMode', '-append');
        % Save release version.
        viewsVersion = release_version;
        save(h.getFileName(), 'viewsVersion', '-append');
    end
catch ME    
    warningID = 'Shared:DAS:ErrorWritingViewDefinitions';
    warning(DAStudio.message('Shared:DAS:ErrorWritingViewDefinitions'), warningID);
end
