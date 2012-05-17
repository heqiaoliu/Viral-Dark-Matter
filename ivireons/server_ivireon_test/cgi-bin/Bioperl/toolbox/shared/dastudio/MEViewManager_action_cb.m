function MEViewManager_action_cb(id)

%   Copyright 2009 The MathWorks, Inc.

root   = DAStudio.Root;
action = find(root, '-isa', 'DAStudio.Action', 'id', id);

if isempty(action) || isempty(action.callbackData{2})
    return;
end;

% extract needed callback data from the action
fcn = action.callbackData{1};
h = action.callbackData{2};

% execute whatever action is being requested
switch (fcn)      
    case 'customizeView'       
        if strcmp(action.on, 'on')
            h.customizeView(true);
        else
            h.customizeView(false);
        end
        
    case 'manageView'        
        h.VMProxy = h.createProxy();        
        showDialog(h, 'manage', 'me_view_manager_dialog_ui');     
        
    case 'resetToFactory'
        message = DAStudio.message('Shared:DAS:ResetToFactorySettings');        
        dp = DAStudio.DialogProvider;
        dp.questdlg(message, DAStudio.message('Shared:DAS:ResetToFactorySettingsTitle'), ...
            {'Yes', 'No'}, 'No', {@resetViewCallback, h, ''});
        
    case 'hideApplySuggestions'
        if strcmp(action.on, 'on')
            h.SuggestionMode = 'auto';            
            dlg = DAStudio.ToolRoot.getOpenDialogs(h);        
            for i = 1:length(dlg)
                if strcmp(dlg(i).dialogTag, 'me_view_manager_ui')                    
                    dlg(i).setVisible('views_suggestion_panel', 0);  
                    break;
                end
            end
            % Apply view too
            view = h.getSuggestedView();            
            if ~isempty(view)
                h.ActiveView = view;
            end
        else
            h.SuggestionMode = 'show';
        end
        
    case 'resetAllToFactory'
        message = DAStudio.message('Shared:DAS:ResetAllToFactorySettings');        
        dp = DAStudio.DialogProvider;
        dp.questdlg(message, DAStudio.message('Shared:DAS:ResetToFactorySettingsTitle'), ...
            {'Yes', 'No'}, 'No', {@resetViewCallback, h, 'all'});        
    
    case 'hideSuggestion'
        dlg = DAStudio.ToolRoot.getOpenDialogs(h);        
        for i = 1:length(dlg)
            if strcmp(dlg(i).dialogTag, 'me_view_manager_ui')
                dlg(i).setVisible('views_suggestion_panel',0);                
                break;
            end
        end

    case 'exportView'
        [filename, pathname] = uiputfile({'*.mat','MAT-files (*.mat)';}, ...
            DAStudio.message('Shared:DAS:ExportViewsDialogTitle'));        
        if ~isequal(filename, 0) && ~isequal(pathname, 0)
            fullFile = [pathname filename];    
            % Get file name and export all views.
            h.export(h.ActiveView, fullFile);
        end
        
    case 'suggestionsWhatIsThis'
        helpview([docroot '/toolbox/simulink/helptargets.map'], 'ModelExplorer_Suggestions_WhatsThis');
    otherwise
        error('DAStudio:UnknownAction', 'unknown action');
end

%
% Reset single or all views to factory settings.
%
function resetViewCallback(h, all, proceed)
if strcmp(proceed, 'Yes')
    if isempty(all)
        h.resetView;
    else
        % Fill Proxy
        delete(find(h.VMProxy, '-isa', 'DAStudio.MEView'));
        factoryViews = h.VMProxy.getFactoryViews();
        for i = 1:length(factoryViews)
            h.VMProxy.addView(factoryViews(i));
        end
        % Reset active view domain information.
        domain = find(h.VMProxy.Domains, 'Name', h.ActiveDomainName);
        h.VMProxy.ActiveView = domain.getFactoryView();        
        % Refresh
        dlg = DAStudio.ToolRoot.getOpenDialogs(h);        
        for i = 1:length(dlg)
           if strcmp(dlg(i).dialogTag, 'me_view_manager_dialog_ui')
                dlg(i).refresh;
                break;
           end 
        end
    end
end


