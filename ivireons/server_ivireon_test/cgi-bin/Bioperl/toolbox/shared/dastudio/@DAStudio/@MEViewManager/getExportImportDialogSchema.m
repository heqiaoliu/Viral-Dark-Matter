function dlg = getExportImportDialogSchema(h, type)

%   Copyright 2009 The MathWorks, Inc.

exportType = false;
if strcmp(type, 'export')
    exportType = true;
end
% Get all views which are currently with export-import manager.
if exportType
    meViews = h.VMProxy.getAllViews;
else
    meViews = h.VMProxy.BufferedViews;
end

selectedRow = 0;
data = {};
for i = 1:length(meViews)
    data{i, 1}.Type = 'checkbox';
    if exportType && ~isempty(h.VMProxy.BufferedViews)
        isSelected = find(h.VMProxy.BufferedViews, '-isa', 'DAStudio.MEView', ...
                            'Name', meViews(i).Name);
        data{i, 1}.Value = ~isempty(isSelected);
        if ~isempty(isSelected)
            selectedRow = i - 1;
        end
    else
        data{i, 1}.Value = true;
    end
    data{i, 2} = meViews(i).Name;
    data{i, 3} = meViews(i).Description;
end

exportImportTable.Type             = 'table';
if exportType
    exportImportTable.Tag          = 'view_export_table';
else
    exportImportTable.Tag          = 'view_import_table';
end
exportImportTable.Source           = h;
exportImportTable.Graphical        = true;
exportImportTable.Grid             = true;
if exportType
    exportImportTable.ColHeader    = {DAStudio.message('Shared:DAS:ExportID'), ...
                                        DAStudio.message('Shared:DAS:ViewID'), ...
                                        DAStudio.message('Shared:DAS:DescriptionID')};
else
    exportImportTable.ColHeader    = {DAStudio.message('Shared:DAS:ImportID'), ...
                                        DAStudio.message('Shared:DAS:ViewID'), ...
                                        DAStudio.message('Shared:DAS:DescriptionID')};
end
exportImportTable.HeaderVisibility = [0 1 1];
exportImportTable.ReadOnlyColumns  = [1 2];
exportImportTable.MultiSelect      = false;
exportImportTable.Editable         = true;
exportImportTable.Data             = data;
exportImportTable.Size             = size(data);
if exportType
    exportImportTable.ValueChangedCallback  = @onExportTableValueChanged;
else
    exportImportTable.ValueChangedCallback  = @onImportTableValueChanged;
end
exportImportTable.RowSpan          = [1 1];
exportImportTable.ColSpan          = [1 1];
exportImportTable.SelectionBehavior= 'Row';
exportImportTable.SelectedRow      = selectedRow;
        
exportImportTablePanel.Type     = 'panel';
exportImportTablePanel.Items    = {exportImportTable};
exportImportTablePanel.LayoutGrid = [1 1];
exportImportTablePanel.RowSpan    = [1 1];
exportImportTablePanel.ColSpan    = [1 1];

% TODO: Button bar and apply button.
if exportType
    dlg.DialogTitle         = DAStudio.message('Shared:DAS:ExportViewsID');
    dlg.DialogTag           = 'me_view_manager_export_dialog_ui';
    dlg.CloseCallback       = 'exportViewsCallback';    
else
    dlg.DialogTitle         = DAStudio.message('Shared:DAS:ImportViewsID');
    dlg.DialogTag           = 'me_view_manager_import_dialog_ui';
    dlg.CloseCallback       = 'importViewsCallback';
end
dlg.CloseArgs           = {h, '%closeaction'};
dlg.StandaloneButtonSet = {'Ok', 'Cancel'};
dlg.IsScrollable        = true;
dlg.Items               = {exportImportTablePanel};
dlg.DefaultOk           = false;
dlg.Sticky              = true;

% 
% Handle changes in export dialog.
%
function onExportTableValueChanged(dlg, r, ~, value)

h = dlg.getSource();
export    = dlg.getTableItemValue('view_export_table', r, 0);
viewName  = dlg.getTableItemValue('view_export_table', r, 1);

if strcmp(export, '0')
    % Remove it from the list.
    view = find(h.VMProxy.BufferedViews, '-isa','DAStudio.MEView', 'Name', viewName);
    if ~isempty(view)
        for i=1:length(h.VMProxy.BufferedViews)
            if strcmp(h.VMProxy.BufferedViews(i).Name, viewName)
                h.VMProxy.BufferedViews(i) = [];
                break;
            end
        end
    end
else
    % Add it in the list.
    if ~isempty(h.VMProxy.BufferedViews)
        view = h.VMProxy.getView(viewName);
        if ~isempty(view)            
            h.VMProxy.BufferedViews = [h.VMProxy.BufferedViews; view;];
        end
    else
        h.VMProxy.BufferedViews = h.VMProxy.getView(viewName);
    end
end

%
% Handle changes in import dialog.
%
function onImportTableValueChanged(dlg, r, ~, value)
h = dlg.getSource();
import    = dlg.getTableItemValue('view_import_table', r, 0);
viewName  = dlg.getTableItemValue('view_import_table', r, 1);

if strcmp(import, '0')
    % Remove it from the list.
    view = find(h.VMProxy.BufferedViews, '-isa','DAStudio.MEView', 'Name', viewName);
    if ~isempty(view)
        for i=1:length(h.VMProxy.BufferedViews)
            if strcmp(h.VMProxy.BufferedViews(i).Name, viewName)
                h.VMProxy.BufferedViews(i) = [];
                break;
            end
        end
    end
else
    if ~isempty(h.VMProxy.BufferedViews)
        % Add it in the list.
        view = find(h.VMProxy.BufferedViews, '-isa','DAStudio.MEView', 'Name', viewName);
        if ~isempty(view)
            % Add at correct location
            h.VMProxy.BufferedViews = [h.VMProxy.BufferedViews(1:r); view; h.VMProxy.BufferedViews(r+1:end)];
        end
    else
        h.VMProxy.BufferedViews = find(h.VMProxy, '-isa', 'DAStudio.MEView', 'Name', viewName);
    end
end