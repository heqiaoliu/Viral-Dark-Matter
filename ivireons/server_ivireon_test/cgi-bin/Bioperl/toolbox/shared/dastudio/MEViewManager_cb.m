function varargout = MEViewManager_cb(dlg, fcn, varargin)

%   Copyright 2009-2010 The MathWorks, Inc.

manager = dlg.getSource();

switch (fcn)
    case 'doExpandCollapse'
        manager.IsCollapsed = ~manager.IsCollapsed;
    
    case 'doViewChange'
        index = varargin{1} + 1;
        views = manager.getAllViews;
        
        manager.ActiveView = views(index);
        manager.save(manager);
    
    case 'doDetails'        
        if ~isempty(manager.getActiveView)
            % extract some useful information
            visible     = varargin{1};
            possible    = varargin{2};
            fPropsStr   = varargin{3};            
            settingsStr = calculateSettingsString(manager);
            hidden = possible - visible;
            
            % construct the message to display
            message = DAStudio.message('Shared:DAS:ViewDetails',...
                visible, possible, hidden, settingsStr);
            im = DAStudio.imExplorer(manager.Explorer);
            filterString = im.getListFilterString();
            if ~isempty(filterString)
               filterMessage = DAStudio.message('Shared:DAS:FilterDetails', filterString);               
               message = sprintf('%s\n\n%s', message, filterMessage);
            end
            view = manager.getActiveView;
            % display
            msgbox(message, view.Name, 'help', 'replace');            
        end        
        
    case 'doSuggestion'        
      % Get suggested view.
      suggestedView = manager.getSuggestedView();
      if ~isempty(suggestedView)
          manager.ActiveView = suggestedView;
        end
                
    case 'doCopyView'
        row = dlg.getSelectedTableRow('view_manager_table');
        viewName = dlg.getTableItemValue('view_manager_table', row, 0);        
        
        % Create a unique name. Start with Copy (%d) pattern.        
        newViewName = sprintf('%s (1)', viewName);      
        view = manager.VMProxy.getView(newViewName);
        count = 1;
        while ~isempty(view)
            newViewName = sprintf('%s (%d)', viewName, count);
            view = manager.VMProxy.getView(newViewName);
            count = count + 1;
        end        
        % Copy this view
        [newView message] = manager.VMProxy.copyView(viewName, newViewName); 
        if isempty(message)
            % Give it to the proxy.
            manager.VMProxy.addView(newView);
            refreshViewManagementDialog(dlg);
            % Select its row
            dlg.selectTableRow('view_manager_table', length(manager.VMProxy.getAllViews) - 1);
        end
        
    case 'doNewView'        
         allViews = manager.VMProxy.getAllViews;
         newViewName = 'New View';
         view = find(allViews, 'Name', newViewName);
         if isempty(view)
             % No conflict. Create a new one.
              view = DAStudio.MEView(newViewName, 'Description');              
         else
             % Create a unique name. Start with Copy (%d) pattern.
             count = 1;
             tempName = newViewName;
             while ~isempty(view)
                 newViewName = sprintf('%s (%d)', tempName, count);
                 view = manager.VMProxy.getView(newViewName);
                 tempName = 'New View';
                 count = count + 1;
             end
             view = DAStudio.MEView(newViewName, 'Description');        
         end
         % Give it to the proxy.
         manager.VMProxy.addView(view);
         refreshViewManagementDialog(dlg);
         % Select its row
         dlg.selectTableRow('view_manager_table', length(allViews));
         
    case 'doDeleteView'                        
        % TODO: If all views are selected, do not allow deletion.
        row = dlg.getSelectedTableRows('view_manager_table');
        if canDeleteView(dlg)
        for i = 1:length(row)
            viewName = dlg.getTableItemValue('view_manager_table', row(i), 0);
            if ~isempty(viewName)
                manager.VMProxy.removeView(viewName);
            end
        end     
        refreshViewManagementDialog(dlg);
        end
        
    case 'doExportView';
        % Avoid dialog if we have only one view to export.
        rows  = dlg.getSelectedTableRows('view_manager_table');
        viewsToExport = [];
        for i = 1:length(rows)
            viewName = dlg.getTableItemValue('view_manager_table', rows(i), 0);
            view = manager.VMProxy.getView(viewName);
            if isempty(viewsToExport)
                viewsToExport = view;
            else
                viewsToExport(end + 1) = view;
            end
        end
        if ~isempty(viewsToExport)
            manager.VMProxy.BufferedViews = viewsToExport;
            showDialog(manager, 'export', 'me_view_manager_export_dialog_ui');
        end
    
    case 'doImportView'
        % Get file name and import views.
        [filename, pathname] = uigetfile({'*.mat','MAT-files (*.mat)';}, ...
            DAStudio.message('Shared:DAS:ImportViewsDialogTitle'));
        fullFile = [pathname filename];
        if ~isequal(filename, 0) && ~isequal(pathname, 0)
            try
                manager.VMProxy.BufferedViews = manager.import(fullFile, '');                
                showDialog(manager, 'import', 'me_view_manager_import_dialog_ui');
            catch loadError
                disp(['Import error: ' loadError]);                
            end
        end
        
    case 'doViewUp'
        % Move view up in the list.
        rows = dlg.getSelectedTableRows('view_manager_table');
        % Before continuing, validate if we will have correct thing
        % afterwards or not.
        % Start from begining
        tempRows = int32(rows) - 1;                
        if isempty(find(tempRows < 0, 1))            
            % We can move.
            viewsToMove = {};            
            allViews = manager.VMProxy.getAllViews;
            for i = 1:length(rows)
                viewToMove = allViews(rows(i) + 1).Name;                
                rowToMoveBefore = rows(i) - 1;
                if ~isempty(find(rows == rowToMoveBefore))
                    rowToMoveBefore = rows(1) - 1;
                end
                viewToMoveBefore = allViews(rowToMoveBefore + 1).Name;
                viewsToMove{i,1} = viewToMove;
                viewsToMove{i,2} = viewToMoveBefore;
                rowToSelect = rowToMoveBefore;
            end
            % Move
            if length(rows) == 1
                manager.VMProxy.moveBefore(viewsToMove{1}, viewsToMove{2});
                rowToSelect = rows(1) - 1;
            else
                num = length(viewsToMove);
                for i = 1:num
                    manager.VMProxy.moveBefore(viewsToMove{i,1}, viewsToMove{i,2});
                end
            end
            refreshViewManagementDialog(dlg);
            rowsToSelect = double(rows - 1);
            dlg.selectTableRows('view_manager_table', rowsToSelect);
            MEViewManager_cb(dlg, 'doEnableDisableButtons');
        end

    case 'doViewDown'
        % Move view down in the list.        
        rows = dlg.getSelectedTableRows('view_manager_table');
        % Before continuing, validate if we will have correct thing
        % afterwards or not.
        % Start from end
        tempRows = rows(end:-1:1);
        % Moving down so add 1 to each row.
        tempRows = tempRows + 1;
        allViews = manager.VMProxy.getAllViews;
        % If we do not have invalid row, move.
        if isempty(find(tempRows > (length(allViews) - 1), 1))
            % We can move.
            viewsToMove = {};            
            for i = 1:length(rows)
                viewToMove = allViews(rows(i) + 1).Name;
                rowToMoveAfter = rows(i) + 1;
                if ~isempty(find(rows == rowToMoveAfter))
                    rowToMoveAfter = rows(end) + 1;
                end
                viewToMoveAfter = allViews(rowToMoveAfter+1).Name;
                viewsToMove{i,1} = viewToMove;
                viewsToMove{i,2} = viewToMoveAfter;
            end
            % Move
            if length(rows) == 1
                manager.VMProxy.moveAfter(viewsToMove{1}, viewsToMove{2});
            else
                num = length(viewsToMove);
                for i = 1:num
                    manager.VMProxy.moveAfter(viewsToMove{num-i+1,1}, viewsToMove{num-i+1,2});
                end
            end
            refreshViewManagementDialog(dlg);
            rowsToSelect = double(rows + 1);
            dlg.selectTableRows('view_manager_table', rowsToSelect);
            MEViewManager_cb(dlg, 'doEnableDisableButtons');
        end
        
    case 'doEnableDisableButtons'
        rows = dlg.getSelectedTableRows('view_manager_table');        
        allViews = manager.VMProxy.getAllViews;
        dlg.setEnabled('delete_view_button', canDeleteView(dlg));        
        % Enable disable up/down buttons
        % Use same logic which we used for up and down move.
        tempRows = int32(rows) - 1; 
        dlg.setEnabled('up_view_button', isempty(find(tempRows < 0, 1)))
        tempRows = rows + 1;
        dlg.setEnabled('down_view_button', isempty(find(tempRows > (length(allViews) - 1), 1)));        
                
    otherwise
        error('DAStudio:UnknownAction', 'unknown action');
end
end

%
%
%
function settingsStr = calculateSettingsString(manager)
    settingsStr = '';
    if ishandle(manager.Explorer)
        actionArr = {'VIEW_ROOTCONFIGSET', DAStudio.message('Shared:DAS:ConfigPrefsID'); ...            
                     'VIEW_SHOWMASKEDSUBSYSTEMS', DAStudio.message('Shared:DAS:MaskedSubsystemsID'); ...                     
                     'VIEW_SHOWLINKEDSUBSYSTEMS', DAStudio.message('Shared:DAS:LibraryLinksID'); ...                     
                     'NEWLINESEPARATOR', '\n'; ...
                     'VIEW_SLBLOCKS', ''; ...
                     'VIEW_SLNAMEDLINES', ''; ...
                     'VIEW_SLLINES', ''; ...
                     'VIEW_SLANNOTATIONS', ''; ...
                     'NEWLINESEPARATOR', '\n';
                     'VIEW_SFSTATES', ''; ...
                     'VIEW_SFTRANSITIONS', ''; ...
                     'VIEW_SFJUNCTIONS', ''; ...
                     'VIEW_SFEVENTS', ''; ...
                     'VIEW_DATA', '';};

        outStr = '';
        ac = DAStudio.ActionManager;
        for i = 1:length(actionArr)
            action = [];
            if strcmp(char(actionArr{i,1}), 'NEWLINESEPARATOR')
                if ~isempty(outStr)
                    settingsStr = sprintf('%s\n   %s', settingsStr, outStr);
                    outStr = '';
        end
            else
                action = ac.createDefaultAction(manager.Explorer, char(actionArr{i,1}));
        end
            if ~isempty(action) && strcmp(action.on, 'off')                              
                if isempty(char(actionArr{i,2}))
            text = strrep(action.text, '&','');
                else
                   text = char(actionArr{i,2});
        end
                if isempty(outStr) && ~strcmp(text,'\n')
                    outStr = sprintf('%s', text);
                else                    
                    outStr = sprintf('%s, %s', outStr, text);                    
        end
        end
        end
        if ~isempty(outStr)
            settingsStr = sprintf('%s\n   %s', settingsStr, outStr);
        end
        % Set none if nothing is there
        if isempty(settingsStr)
            settingsStr = DAStudio.message('Shared:DAS:NoneID');
        end
    end
end

%
%
%
function refreshViewManagementDialog(dlg)
    manager = dlg.getSource();
    managerUI = DAStudio.ToolRoot.getOpenDialogs(manager);

    for i = 1:length(managerUI)
       if strcmp(dlg(i).dialogTag, 'me_view_manager_dialog_ui')
            dlg(i).refresh;
            break;
       end 
    end
end

%
% canDeleteView
%
% If all views are selected, they cannot be deleted.
% If it is the last view, it cannot be deleted.
%
function delete = canDeleteView(dlg)
delete = false;
manager = dlg.getSource();
rows = dlg.getSelectedTableRows('view_manager_table');        
allViews = manager.VMProxy.getAllViews;
if length(rows) ~= length(allViews)
    delete = true;
end
end

