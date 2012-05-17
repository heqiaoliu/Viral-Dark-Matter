function dlg = getDialogSchema(h,~)
    % 
    
	% Construct the dialog panel for selected signal viewer
    
    %  Author(s): Erman Korkut
    %  Revised:
    % Copyright 1986-2010 The MathWorks, Inc.
    % $Revision: 1.1.8.2 $ $Date: 2010/03/26 17:54:13 $
    
    % Get options
    opts = h.TCPeer.getOptions;
    % Create filtering toolbar if filter visible
    if opts.FilterVisible
        %% Filter
        % Text
        filterText.Type = 'text';
        filterText.Name = DAStudio.message('Slcontrol:sigselector:FilterByName');
        filterText.RowSpan = [1 1];
        filterText.ColSpan = [1 1];
        filterText.Tag = 'filterLabel';
        % Edit Field
        filterEdit.Type = 'edit';
        filterEdit.RowSpan = [1 1];
        filterEdit.ColSpan = [2 2];
        filterEdit.Graphical = true;
        filterEdit.Mode = true;
        filterEdit.ObjectMethod = 'applyFilter';
        filterEdit.MethodArgs = {'%dialog'};
        filterEdit.ArgDataTypes = {'handle'};
        filterEdit.Tag = 'selsigview_filterEdit';
        filterEdit.RespondsToTextChanged = true;
        % Button
        clearButton.Name = DAStudio.message('Slcontrol:sigselector:ClearFilter');
        clearButton.Type = 'pushbutton';
        clearButton.RowSpan = [1 1];
        clearButton.ColSpan = [3 3];
        clearButton.Enabled = ~isempty(h.TCPeer.getFilterText);
        clearButton.ObjectMethod = 'clearFilter';
        clearButton.MethodArgs = {'%dialog'};
        clearButton.ArgDataTypes = {'handle'};
        clearButton.Tag = 'selsigview_filterClear';
    end    
    %% Signal Tree
    [items,name] = constructTreeItems(h);    
    sigsTree.Name = name;
    sigsTree.ObjectMethod = 'selectSignal';
    sigsTree.MethodArgs = {'%dialog'};
    sigsTree.ArgDataTypes = {'handle'};
    sigsTree.Type = 'tree';
    sigsTree.Graphical = true;
    sigsTree.TreeItems = items;
    sigsTree.TreeMultiSelect = opts.TreeMultipleSelection;
    sigsTree.MinimumSize = h.MinimumSize;
    sigsTree.Tag = 'selsigview_signalsTree';
    sigsTree.ExpandTree = ~isempty(h.TCPeer.getFilterText); %Expand the tree only when filtered
    
    %% Enclosing panel
    % Place widgets according to filter visibility
    dlg.Type       = 'panel';
    if opts.FilterVisible
        sigsTree.RowSpan = [2 2];
        sigsTree.ColSpan = [1 3];        
        dlg.Items      = {filterText filterEdit clearButton sigsTree};
        dlg.LayoutGrid = [2 3];
        dlg.RowStretch = [0 1];
        dlg.ColStretch = [0 1 0];
    else
        % Filter invisible case
        sigsTree.RowSpan = [1 1];
        sigsTree.ColSpan = [1 1];
        dlg.Items      = {sigsTree};
        dlg.LayoutGrid = [1 1];
        dlg.RowStretch = [1];
        dlg.ColStretch = [1];
    end
end

