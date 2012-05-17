function load(h)
% load
% Try to load views from preferences first then default to factory settings.
%

%   Copyright 2009-2010 The MathWorks, Inc.

% remove any existing views w/o side effects
h.disableLiveliness;
delete(find(h, '-isa', 'DAStudio.MEView'));
h.enableLiveliness;

if ~exist(h.getFileName(), 'file')
    h.reset;
else
    try
        % Read from file
        readData = load(h.getFileName);
        meViews  = readData.meViews;
        
        % Construct views w/o side effects
        h.disableLiveliness;
        for i = 1:length(meViews)
            % Create view
            view = DAStudio.MEView(meViews(i).Name, meViews(i).Description);
            view.Properties = meViews(i).Properties;            
            % Take care of domains.
            if ~isempty(meViews(i).Domain)
                domainName = meViews(i).Domain;
                % Create domain and make this view default view.
                domain = h.createDomain(domainName);
                % Make this view an active view for that domain.
                domain.setActiveView(view);
            end
            % New addition in this release. If prev release, default values
            % already set in constructor.
            if strcmp(readData.viewsVersion, release_version)
                view.GroupName = meViews(i).GroupName;
                view.SortName = meViews(i).SortName;
                view.SortOrder = meViews(i).SortOrder;            
            end
            % View construction completed. Give it to the view manager.
            h.addView(view);
            % Internal name
            if ~isempty(meViews(i).InternalName)
                view.InternalName = meViews(i).InternalName;
            end
        end
        h.enableLiveliness;
        if isempty(h.ActiveView)            
            h.ActiveView = h.getSuggestedView();
            % If domain stuff fails, just assing last view.
            if isempty(h.ActiveView)
                h.ActiveView = h.getView(readData.activeView);
            end
        end
        % Set autosuggest
        h.SuggestionMode = readData.suggestionMode;        
    catch ME
        % Default to factory views if the preferences are unavailable
        h.reset;
        warningID = 'Shared:DAS:ErrorReadingViewDefinitions';        
        warning(DAStudio.message('Shared:DAS:ErrorReadingViewDefinitions'), warningID);
    end
end
