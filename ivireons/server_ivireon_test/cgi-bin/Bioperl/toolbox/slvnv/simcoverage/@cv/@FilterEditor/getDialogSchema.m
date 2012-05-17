function dlg = getDialogSchema(this, ~)

%   Copyright 2009-2010 The MathWorks, Inc.

dlg.DialogTitle  = ['Coverage Filter : ' this.covFilter];
dlg.DialogTag  = 'Coverage_Filter';
dlg.PostApplyMethod = 'postApply';
dlg.DialogRefresh = true;
dlg.HelpArgs    = {};
tag = 'Coverage_Filter_';
widgetId = 'Coverage.Filter.';

dlg.Items = {getPanelBuildFilter(this, tag, widgetId )};



%====================
function panel = getPanelBuildFilter(this, tag, widgetId )
       



filterProps.Name = 'Filter';
filterProps.Type    = 'combobox';

filterProps.Entries = this.getFilterPropertyNames;
filterProps.ObjectProperty = 'filterPropertyNameIdx';
filterProps.Mode = true;
filterProps.RowSpan = [1 1]; 
filterProps.ColSpan = [1 4]; 
filterProps.Graphical = true;
filterProps.DialogRefresh = true;

[tag desc] = this.getFilterPropertyValues;
filterValues.Name    = tag ;
filterValues.Type    = 'combobox';
filterValues.Entries = desc;
filterValues.Mode = true;
filterValues.ObjectProperty = 'filterPropertyValueIdx';
filterValues.RowSpan = [2 2]; 
filterValues.ColSpan = [1 4];
filterValues.Graphical = true;

filterAddItem.Name = 'Add';
filterAddItem.Type = 'pushbutton';
filterAddItem.RowSpan = [3 3]; 
filterAddItem.ColSpan = [1 1]; 
filterAddItem.ObjectMethod = 'filterAddCallback';
filterAddItem.DialogRefresh = true;



filterRemoveItem.Name = 'Remove';
filterRemoveItem.Type = 'pushbutton';
filterRemoveItem.RowSpan = [3 3]; 
filterRemoveItem.ColSpan = [2 2]; 
filterRemoveItem.ObjectMethod = 'filterRemoveCallback';
filterRemoveItem.DialogRefresh = true;

groupBuildFilter.Name = 'Edit filter';
groupBuildFilter.Type = 'group';
groupBuildFilter.LayoutGrid = [3 4];
groupBuildFilter.Items = {filterProps, filterValues, filterAddItem, filterRemoveItem};
 

filterState.Type    = 'listbox';
filterState.Entries = this.getFilterState;
filterState.Mode = true;
filterState.ObjectProperty = 'filterStateIdx';

groupFilterState.Type = 'group';
groupFilterState.Name = 'Filter Description';
groupFilterState.Items = {filterState};


filterFileName.Name = 'Filter filename:';
filterFileName.Type = 'edit';
filterFileName.RowSpan = [1 1]; 
filterFileName.ColSpan = [1 1]; 
filterFileName.ObjectProperty = 'covFilter';

filterFileBrowse.Name = 'Browse...';
filterFileBrowse.Type = 'pushbutton';
filterFileBrowse.RowSpan = [1 1]; 
filterFileBrowse.ColSpan = [2 2]; 
filterFileBrowse.ObjectMethod = 'filterFileBrowseCallback';

groupFile.Type = 'group';
groupFile.Items = {filterFileName, filterFileBrowse};
groupFile.LayoutGrid = [2 2];

filterModelName.Name = 'Model name:';
filterModelName.Type = 'edit';
filterModelName.RowSpan = [1 1]; 
filterModelName.ColSpan = [1 1]; 
filterModelName.ObjectProperty = 'modelName';

filterModelBrowse.Name = 'Browse...';
filterModelBrowse.Type = 'pushbutton';
filterModelBrowse.RowSpan = [1 1]; 
filterModelBrowse.ColSpan = [2 2]; 
filterModelBrowse.ObjectMethod = 'modelNameBrowseCallback';


filterSaveToModel.Name = 'Save into model';
filterSaveToModel.Type = 'checkbox';
filterSaveToModel.ObjectProperty = 'saveToModel';
filterSaveToModel.RowSpan = [3 3]; 
filterSaveToModel.ColSpan = [1 1]; 


groupModel.Type = 'group';
groupModel.Items = {filterModelName, filterModelBrowse, filterSaveToModel};
groupModel.LayoutGrid = [3 2];


panel.LayoutGrid = [3 2];
panel.Type = 'panel';
panel.Items = {groupFilterState, groupBuildFilter, groupFile, groupModel};


