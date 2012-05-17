%
%
%
function importViewsCallback(h, callbackArgs)

%   Copyright 2009 The MathWorks, Inc.

if strcmp(callbackArgs, 'ok')
    viewsToImport = h.VMProxy.BufferedViews;
    for i = 1:length(viewsToImport)
        importedView = viewsToImport(i);
        view = find(h.VMProxy, '-isa','DAStudio.MEView','Name', importedView.Name);       
        if isempty(view)
            % No conflict. Create a new one.
             newView = DAStudio.MEView(importedView.Name, importedView.Description);            
        else
            % Create a unique name. Start with Copy (%d) pattern.
            count = 1;
            while ~isempty(view)
                newViewName = sprintf('%s (%d)', importedView.Name, count);
                view = find(h.VMProxy, '-isa','DAStudio.MEView','Name', newViewName);
                count = count + 1;
            end
            newView = DAStudio.MEView(newViewName, importedView.Description);            
        end
        h.VMProxy.addView(newView);
        % Do we need this?
        h.disableLiveliness;
        newView.Properties = importedView.Properties;            
        h.enableLiveliness;        
    end
    % Refresh dialog.        
    dlg = DAStudio.ToolRoot.getOpenDialogs(h);

    for i = 1:length(dlg)
       if strcmp(dlg(i).dialogTag, 'me_view_manager_dialog_ui')
            dlg(i).refresh;
            break;
       end
    end
end