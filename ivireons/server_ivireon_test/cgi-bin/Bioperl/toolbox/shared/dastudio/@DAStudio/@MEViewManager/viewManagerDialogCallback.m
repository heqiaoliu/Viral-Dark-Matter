function viewManagerDialogCallback(h, callbackArgs)
%   Copyright 2009-2010 The MathWorks, Inc.
if strcmp(callbackArgs, 'ok')
%     message = sprintf('Do you want to reset this view to it''s factory settings?');
%     message = sprintf('%s \n\n Yes - resets this view to it''s factory settings.', message);
%     message = sprintf('%s \n No - do not reset this view to factory settings.', message);
%     dp = DAStudio.DialogProvider;
%     dp.questdlg(message, 'Close - Warning',{'Yes', 'No'}, 'No', {@viewChangesCallback, h});
    applyChanges(h);
end


%
% Reset single or all views to factory settings.
%
function viewChangesCallback(h, proceed)
if strcmp(proceed, 'Yes')    
    applyChanges(h);
end
% Clear it.
h.VMProxy = []; 


function applyChanges(h)
h.disableLiveliness;
activeViewName = h.VMProxy.ActiveView.Name;
% Replace everything from Proxy view manager.
delete(find(h, '-isa', 'DAStudio.MEView'));
h.ActiveView = [];
activeView = [];
% Get views from proxy.
allViews = find(h.VMProxy, '-isa', 'DAStudio.MEView');
for i = 1:length(allViews)
    view = DAStudio.MEView(allViews(i).Name, allViews(i).Description);
    if ~isempty(allViews(i).Properties)
        view.Properties = copy(allViews(i).Properties);
        % Set matching properties.
        properties = find(allViews(i).Properties, 'isMatching', true);
        % Any shortcut?
        for k = 1:length(properties)
            prop = find(view.Properties, 'Name', properties(k).Name);
            prop.isMatching = true;
        end
    end    
    view.InternalName = allViews(i).InternalName;
    view.GroupName = allViews(i).GroupName;
    view.SortName = allViews(i).SortName;
    view.SortOrder = allViews(i).SortOrder;
    h.addView(view);
    % Active view
    if strcmp(activeViewName, view.Name)        
         activeView = view;
    end
end
% Domain info. Domains updated above. So correct views.
h.Domains = copy(h.VMProxy.Domains);
% The views in these domains still refer to old views. Update.
for i = 1:length(h.Domains)
    domainInfo = h.Domains(i);
    if ~isempty(domainInfo)
        dView = domainInfo.getActiveView();
        if ~isempty(dView)
            % find actual view
            view = h.getView(dView.Name);
            if ~isempty(view)
                domainInfo.setActiveView(view);
            end
        end
    end
end

% Suggetion mode
h.SuggestionMode = h.VMProxy.SuggestionMode;
h.enableLiveliness;
% If active view was deleted, set first in the list?
if isempty(activeView)
    allViews = find(h, '-isa', 'DAStudio.MEView');
    h.ActiveView = allViews(1);
else
    h.ActiveView = activeView;
end

% Delete all proxy views
delete(h.VMProxy.getAllViews);
managerUI = DAStudio.ToolRoot.getOpenDialogs(h);
 
for i = 1:length(managerUI)
  managerUI(i).refresh;
end
   

