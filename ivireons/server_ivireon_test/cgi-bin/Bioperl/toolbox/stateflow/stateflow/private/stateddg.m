function dlgstruct = stateddg(h, name) %#ok<INUSD>
    
    % Copyright 2002-2010 The MathWorks, Inc.
    
    % The name argument is ignored
    
    % Setup some common data
    [isFunc, isNoteBox, isAndType, disableIfGroup, disableIfFuncOrGroup] = setup_common_data_l(h);
    isEmlBased = is_eml_based_fcn(h.Id);
    isCompState = (sf('get', h.Id, '.simulink.isComponent') == 1);
    
    itemsAndRowStretch = {
        {nameUI, 0}, ...
        {debuggerUI, 0}, ...
        {execOrderUI, 0}, ...
        {inlineOptionsUI, 0}, ...
        {emlDataConversionUI, 0}, ...
        {testPointAndStateActivityUI, 0}, ...
        {labelUI, ~isFunc && ~isCompState}};
    
    if ~isCompState
        itemsAndRowStretch = [
            itemsAndRowStretch, ...
            {
            {descriptionUI, 1}, ...
            {callbacksGroup, 1}, ...
            {documentUI, 0} ...
            }
            ];
    else
        spacer.Type = 'panel';
        spacer.Enabled = 0;
        
        itemsAndRowStretch = [
            itemsAndRowStretch, ...
            Stateflow.SLINSF.SubchartMan.getRTWWidgets(h), ...
            {{spacer, 1}}
            ];
    end
    [items, rowStretch] = splitItems(itemsAndRowStretch);
    
    title =  get_dialog_title_l(h);
    % if the developer feature is on append the id to the title
    if sf('Feature','Developer')
        id = strcat('#', sf_scalar2str(h.Id));
        dlgstruct.DialogTitle = strcat(title, id);
    else
        dlgstruct.DialogTitle = title;
    end
    
    if isCompState
        dlgstruct.CloseCallback = 'sfprivate';
        dlgstruct.CloseArgs = {'subchart_man', 'onDialogClosed', h.Id};
    else
        dlgstruct.CloseCallback = 'sf';
        dlgstruct.CloseArgs = {'SetDynamicDialog', h.Id, []};
    end
    dlgstruct.DialogTag = strcat('sfStatedlg_', dlgstruct.DialogTitle);
    dlgstruct.HelpMethod = 'sfhelp';
    dlgstruct.HelpArgs = { h, 'state_dialog' };
    dlgstruct.PreApplyCallback = 'sfprivate';
    dlgstruct.PreApplyArgs = {'stateddg_cb','%dialog','doApply'};
    dlgstruct.DisableDialog = ~is_object_editable(h);
   
    if ~isCompState
        dlgstruct.LayoutGrid = [length(items) 4];
        dlgstruct.ColStretch = [2 3 3 3];
        dlgstruct.RowStretch = rowStretch;
        dlgstruct.Items = items;
    else
        dlgstruct.PreRevertCallback = 'sfprivate';
        dlgstruct.PreRevertArgs = {'subchart_man', 'preRevertCallbackFcn', h.Id, '%dialog'};
        
        generalTab = create_tab('General');
        generalTab.LayoutGrid = [length(items) 4];
        generalTab.ColStretch = [2 3 3 3];
        generalTab.Items = items;
        generalTab.RowStretch = rowStretch;

        bindingTab = Stateflow.SLINSF.SubchartMan.getBindingTabSchema(h);
        
        % Also create a description tab.
        descTab = create_tab('Description');
        descTab.Name = 'Description';
        
        itemsAndRowStretch = {
            {descriptionUI, 1}, ...
            {callbacksGroup, 0}, ...
            {documentUI, 0} ...
            };
        [items, rowStretch] = splitItems(itemsAndRowStretch);
        descTab.Items = items;
        descTab.RowStretch = rowStretch;
        descTab.ColStretch = [2 3 3 3];
        descTab.LayoutGrid = [length(items) 4];
        
        tabContainer = create_tab('Tabs');
        tabContainer.Type = 'tab';
        tabContainer.Tabs = {generalTab, bindingTab, descTab};
        dlgstruct.Items = {tabContainer};
    end
    
    function [items, rowStretch] = splitItems(itemsAndRowStretch)
        items = {};
        rowStretch = [];
        row = 1;
        for ii=1:length(itemsAndRowStretch)
            if ~isempty(itemsAndRowStretch{ii}{1})
                items{end+1} = itemsAndRowStretch{ii}{1}; %#ok<AGROW>
                items{end}.RowSpan = [row, row]; %#ok<AGROW>
                rowStretch(end+1) = itemsAndRowStretch{ii}{2}; %#ok<AGROW>
                
                row = row + 1;
            end
        end
    end
    
    function nameArea = nameUI
        if ~isNoteBox
            % name Label
            nameLabel.Name = 'Name:';
            nameLabel.RowSpan = [1 1];
            nameLabel.ColSpan = [1 1];
            nameLabel.Type = 'text';
            nameLabel.Tag = strcat('sfStatedlg_', nameLabel.Name);
            
            %State Name
            stateName.Name = h.name;
            stateName.RowSpan = [1 1];
            stateName.ColSpan = [2 2];
            stateName.Type = 'hyperlink';
            stateName.MatlabMethod = 'sf';
            stateName.Tag = 'stateNameTag';
            stateName.MatlabArgs = {'Private', 'dlg_goto_object', h.Id};
            
            nameArea.Type = 'panel';
            nameArea.ColSpan = [1 4];
            nameArea.LayoutGrid = [2 2];
            nameArea.ColStretch = [0 1];
            nameArea.Items = {nameLabel, stateName};
        else
            nameArea = [];
        end
    end
    
    function pnlEntryExit = debuggerUI
        if ~isNoteBox
            %Debugger breakpoints
            debuggerLabel.Name = 'Breakpoints:';
            debuggerLabel.RowSpan = [1 1];
            debuggerLabel.ColSpan = [1 1];
            debuggerLabel.Type = 'text';
            debuggerLabel.Tag = strcat('sfStatedlg_', debuggerLabel.Name);
            
            %State During check box
            if(isFunc)
                stateDuring.Name = 'Function Call';
            else
                stateDuring.Name = 'State During';
            end
            
            stateDuring.RowSpan = [1 1];
            stateDuring.ColSpan = [2 2];
            stateDuring.Type = 'checkbox';
            if (has_state_field_l(h, 'Debug'))
                stateDuring.ObjectProperty = 'onDuring';
                stateDuring.Visible = disableIfGroup;
            else
                stateDuring.Visible = false;
            end
            if (~h.Chart.Locked)
                stateDuring.Mutable = true;
            end
            stateDuring.Mode = 1;
            stateDuring.Tag = strcat('sfStatedlg_', stateDuring.Name);
            
            %State Entry check box
            stateEntry.Name = 'State Entry';
            stateEntry.RowSpan = [1 1];
            stateEntry.ColSpan = [3 3];
            stateEntry.Type = 'checkbox';
            stateEntry.Visible = disableIfFuncOrGroup;
            if (~h.Chart.Locked)
                stateEntry.Mutable = true;
            end
            stateEntry.Mode = 1;
            if (has_state_field_l(h, 'Debug'))
                stateEntry.ObjectProperty = 'onEntry';
            end
            stateEntry.Tag = strcat('sfStatedlg_', stateEntry.Name);
            
            %State Exit check box
            stateExit.Name = 'State Exit';
            stateExit.RowSpan = [1 1];
            stateExit.ColSpan = [4 4];
            stateExit.Type = 'checkbox';
            stateExit.Visible = disableIfFuncOrGroup;
            if (~h.Chart.Locked)
                stateExit.Mutable = true;
            end
            stateExit.Mode = 1;
            if (has_state_field_l(h, 'Debug'))
                stateExit.ObjectProperty = 'onExit';
            end;
            stateExit.Tag = strcat('sfStatedlg_', stateExit.Name);
            
            if (stateExit.Visible || stateEntry.Visible || stateDuring.Visible)
                debuggerLabel.Visible = disableIfGroup;
            else
                debuggerLabel.Visible = false;
            end
            
            
            % pnlEntryExit panel
            pnlEntryExit.Type       = 'panel';
            if (has_state_field_l(h, 'Debug'))
                pnlEntryExit.Source    = h.Debug.Breakpoints;
            end
            pnlEntryExit.ColSpan = [1 4];
            pnlEntryExit.LayoutGrid = [1 4];
            pnlEntryExit.ColStretch = [2 3 3 3];
            pnlEntryExit.Items      = {debuggerLabel, stateDuring, stateEntry, ...
                stateExit};
            pnlEntryExit.Tag = 'sfStatedlg_pnlEntryExit';
        else
            pnlEntryExit = [];
        end
    end
    
    function inlineOption = inlineOptionsUI
        if ~isNoteBox && ~isCompState
            % Function Inline options
            inlineOption.Name = 'Function Inline Option:';
            inlineOption.Type = 'combobox';
            inlineOption.ColSpan = [1 4];
            % inlineOption.ColStretch = [2 3 3 3];
            inlineOption.ObjectProperty = 'InlineOption';
            inlineOption.Entries = {'Auto','Inline','Function'};
            inlineOption.Visible = disableIfGroup;
            inlineOption.Tag = strcat('sfStatedlg_', inlineOption.Name);
        else
            inlineOption = [];
        end
    end

    function emlDataConversion = emlDataConversionUI
        if ~isNoteBox && isEmlBased
            emlDataConversion.Type       = 'panel';
            emlDataConversion.ColSpan = [1 4];
            emlDataConversion.LayoutGrid = [2 4];
            emlDataConversion.ColStretch = [2 3 3 3];
            emlDataConversion.Items      = {eml_integer_overflow_ddg(1,[1 1]) eml_data_conversion_ddg(h,2,[1 4],true)};
        else
            emlDataConversion = [];
        end
    end
    
    function testPointAndStateActivity = testPointAndStateActivityUI
        if ~isNoteBox
            testPointAndStateActivity.Type       = 'panel';
            testPointAndStateActivity.ColSpan = [1 4];
            testPointAndStateActivity.LayoutGrid = [1 2];
            testPointAndStateActivity.ColStretch = [1 1];
            testPointAndStateActivity.Items      = {isTestPointUI, outputStateActivityUI};
        else
            testPointAndStateActivity = [];
        end
    end
    
    function isTestpoint = isTestPointUI
        if ~isNoteBox
            %State is test point
            isTestpoint.Name = 'Test point';
            isTestpoint.ColSpan = [1 1];
            isTestpoint.Type = 'checkbox';
            if (has_state_field_l(h, 'TestPoint'))
                isTestpoint.ObjectProperty = 'TestPoint';
            end
            isTestpoint.Visible = disableIfFuncOrGroup;
            isTestpoint.Tag = strcat('sfStatedlg_', isTestpoint.Name);
        else
            isTestpoint = [];
        end
    end
    
    function outputState = outputStateActivityUI
        if ~isNoteBox
            %Output State Activity widget
            outputState.Name = 'Output State Activity';
            outputState.ColSpan = [2 2];
            outputState.Type = 'checkbox';
            if (has_state_field_l(h, 'HasOutputData'))
                outputState.ObjectProperty = 'HasOutputData';
            end
            outputState.Visible = disableIfFuncOrGroup;
            outputState.Tag = strcat('sfStatedlg_', outputState.Name);
        else
            outputState = [];
        end
    end

    function execorder = execOrderUI
        if isAndType
            % Parentlabel widget
            execorderLabel.Name = 'Execution order:';
            execorderLabel.RowSpan = [1 1];
            execorderLabel.ColSpan = [1 1];
            execorderLabel.Type = 'text';
            execorderLabel.Tag = strcat('sfStatedlg_', execorderLabel.Name);
            
            %port pull down menu
            execorderPullDown.RowSpan = [1 1];
            execorderPullDown.ColSpan = [2 4];
            execorderPullDown.Type = 'combobox';
            
            execorderPullDown.ObjectProperty = 'ExecutionOrder';
            
            allowedValStr = h.getPropAllowedValues('ExecutionOrder');
            allowedValNum = NaN;
            for i=1:length(allowedValStr)
                allowedValNum(i) = str2double(allowedValStr{i});
            end
            execorderPullDown.Entries = allowedValStr';
            execorderPullDown.Values  = allowedValNum;
            chartId = sf('get',h.id, 'state.chart');
            if(~sf('get',chartId,'chart.userSpecifiedStateTransitionExecutionOrder'))
                execorderPullDown.Enabled  = 0;
            end
            
            execorder.Type       = 'panel';
            execorder.ColSpan = [1 4];
            execorder.LayoutGrid = [1 2];
            execorder.ColStretch = [1 1];
            execorder.Items      = {execorderLabel, execorderPullDown};
        else
            execorder = [];
        end
    end
    
    function label = labelUI
        % Label widget
        if isCompState
            label.Name = 'Name:';
        else
            label.Name = 'Label:';
        end
        if isFunc || isCompState
            label.Type = 'edit';
        else
            label.Type = 'editarea';
        end
        label.ColSpan = [1 4];
        if isNoteBox
            label.ObjectProperty = 'Text';
        elseif isCompState
            label.ObjectProperty = 'Name';
        else
            label.ObjectProperty = 'LabelString';
        end
        % This tag is explicitly used in stateddg_cb.m. Make sure that
        % changes here are reflected there as well. Do not use label.Name
        % here to construct the tag because that changes.
        label.Tag = 'sfStatedlg_Label:';
    end
    
    function description = descriptionUI
        % description widget
        description.Name = 'Description:';
        description.Type = 'editarea';
        description.WordWrap = true;
        description.ColSpan = [1 4];
        description.ObjectProperty = 'Description';
        description.Tag = strcat('sfStatedlg_', description.Name);
    end
    
    function callbacks = callbacksGroup
        
        if isNoteBox
            callbackNote.Name = DAStudio.message('Stateflow:dialog:StateNoteboxCallbackName');
            callbackNote.WordWrap = true;
            callbackNote.Type = 'text';
            callbackNote.RowSpan = [1 1];
            callbackNote.ColSpan = [1 1];
            
            useTextAsClickFcn.Name = DAStudio.message('Stateflow:dialog:StateNoteboxClickFcnName');
            useTextAsClickFcn.RowSpan = [2 2];
            useTextAsClickFcn.ColSpan = [1 1];
            useTextAsClickFcn.Type = 'checkbox';
            useTextAsClickFcn.ObjectProperty = 'UseDisplayTextAsClickCallback';
            useTextAsClickFcn.MatlabMethod = 'sfprivate';
            useTextAsClickFcn.MatlabArgs = {'stateddg_cb', '%dialog','doUseTextAsClickFcn'};
            useTextAsClickFcn.Tag = 'sfStatedlg_useTextAsClickFcn';
            
            clickFcnEdit.Name = '';
            clickFcnEdit.Type = 'editarea';
            clickFcnEdit.RowSpan = [3 3];
            clickFcnEdit.ColSpan = [1 1];
            clickFcnEdit.ObjectProperty = 'ClickFcn';
            clickFcnEdit.Tag = 'sfStatedlg_clickFcnEdit';
            if (has_state_field_l(h, 'ClickFcn'))
                clickFcnEdit.UserData = h.ClickFcn;
            end
            if (has_state_field_l(h, 'UseDisplayTextAsClickCallback') && h.UseDisplayTextAsClickCallback)
                clickFcnEdit.Enabled = 0;
            end
            
            callbacks.Name = 'ClickFcn';
            callbacks.Type = 'group';
            callbacks.ColSpan = [1 4];
            callbacks.LayoutGrid = [3 1];
            callbacks.Items = {callbackNote, useTextAsClickFcn, clickFcnEdit};
        else
            callbacks = [];
        end
    end
    
    function document = documentUI
        %Document hyperlink
        document1.Name = [commonMessage('DocumentLink') ':'];
        document1.RowSpan = [1 1];
        document1.ColSpan = [1 1];
        document1.Type = 'hyperlink';
        document1.Tag = 'documentTag';
        document1.MatlabMethod = 'sf';
        document1.MatlabArgs = {'Private', 'dlg_goto_document', h.Id};
        
        %Document edit area
        document2.Name = '';
        document2.RowSpan = [1 1];
        document2.ColSpan = [2 4];
        document2.Type = 'edit';
        document2.ObjectProperty = 'Document';
        document2.Tag = 'sfStatedlg_document1';

        document.Type       = 'panel';
        document.ColSpan = [1 4];
        document.LayoutGrid = [1 2];
        document.ColStretch = [0 1];
        document.Items      = {document1, document2};
    end
    
end

function [isFunc, isNoteBox, isAndType, disableIfGroup, disableIfFuncOrGroup] = setup_common_data_l(h)
    %-------------------------------------------------------------------------------
    % Sets up some booleans that are used to control visibility of some widgets
    % Parameters:
    %   h = handle to the state udi
    %-------------------------------------------------------------------------------
    
    AND_STATE     = 1;
    FUNC_STATE    = 2;
    GROUP_STATE   = 3;
    [type,isNoteBox] = sf('get', h.Id, '.type','.isNoteBox');
    
    isAndType = (type==AND_STATE);
    isGroup = (type==GROUP_STATE);
    isFunc = (type==FUNC_STATE);
    
    if isGroup
        disableIfGroup = 0;
    else
        disableIfGroup = 1;
    end
    if(isFunc || isGroup)
        disableIfFuncOrGroup = 0;
    else
        disableIfFuncOrGroup = 1;
    end
    
end

function title = get_dialog_title_l(h)
    %-------------------------------------------------------------------------------
    % Construct the title of the dialog
    % Parameters:
    %   h - Handle to the state udi
    %-------------------------------------------------------------------------------
    
    FUNC_STATE    = 2;
    GROUP_STATE   = 3;
    [type,isNoteBox,isTruthtable,isEML] = sf('get', h.Id, '.type','.isNoteBox', ...
        '.truthTable.isTruthTable','.eml.isEML');
    isGroup = (type==GROUP_STATE);
    isFunc = (type==FUNC_STATE);
    
    stateName = sf('get',h.Id,'.name');
    if isNoteBox
        title = ['Note ',stateName,' ... '];
    elseif isGroup
        title = ['Box ',stateName];
    elseif isTruthtable
        title = ['Truth Table ',stateName];
    elseif isEML
        title = 'Embedded MATLAB Function';
    elseif isFunc
        title = ['Function ',stateName];
    else
        title = ['State ',stateName];
    end
end

function result = has_state_field_l(h, field)
    %-------------------------------------------------------------------------------
    % Determine if the state udi has the specified field defined
    % Parameters:
    %   h - Handle to the state udi
    %   field - Name the field to check
    %-------------------------------------------------------------------------------
    
    result = true;
    try
        get(h, field);
    catch %#ok<CTCH>
        result = false;
    end
end

function s = commonMessage(id,varargin)
    
    s = DAStudio.message(['Stateflow:dialog:Common' id],varargin{:});
end

function tab = create_tab(name)
    % tab.Type = 'tab';
    tab.Name = name;
    tab.Tag = strcat('sfStatedlg_', tab.Name);
end
