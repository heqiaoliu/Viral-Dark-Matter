function dlgstruct = dataddg(h, ~)
    % Copyright 2002-2010 The MathWorks, Inc.
    
    [~, isChartParented, isMachineParented,...
        isEmlParented, isEmlChartParented, isEmlTruthTableParented] = get_parent_info_l(h);
    
    %%%% General Tab %%%%
    [scopeCombo, scopeValue] = create_combo(h, 'Scope');
    scopeLabel = create_label(scopeCombo, [commonMessage('Scope') ':'], 'Scope');
    
    isConstant = false;
    isChartOutput = false;
    isChartInput = false;
    isIO = false;
    isLocal = false;
    isDSM = false;
    isExternalDSM = false;
    isChartLocalDSM = false;
    isParameter = false;    
    switch lower(scopeValue)
        case 'constant'
            isConstant = true;
        case 'parameter'
            isParameter = true;
        case 'output'
            isIO = logical(isChartParented);
            isChartOutput = isIO;
        case 'input'
            isIO = logical(isChartParented);
            isChartInput = true;
        case 'local'
            isLocal = true;
        case 'data store memory'
            isDSM = true;
            isChartLocalDSM = sf('feature', 'subchartComponents') && h.isChartLocalDSM;
            isExternalDSM = isDSM && ~isChartLocalDSM;
    end
    
    canBeContinuous = sf('CanDataBeContinuous', h.Id);
    isContinuousUpdate = sf('IsDataContinuous', h.Id);
    
    bindToSignalApply = (isChartOutput || (isLocal && ~isMachineParented) || isChartLocalDSM) && ~isContinuousUpdate; % only for chart local/output data
    isBindToSignal = bindToSignalApply && h.Props.ResolveToSignalObject;
    
    isTypeML = ~isBindToSignal && strcmpi(h.Props.Type.Method, 'built-in') && strcmpi(h.Props.Type.Primitive, 'ml');
    isOpaqueSize = isExternalDSM || isTypeML;
    
    isTypeModeBus = ~isBindToSignal && strcmpi(h.Props.Type.Method, 'bus object');
    isTypeModeEnum = ~isBindToSignal && strcmpi(h.Props.Type.Method, 'enumerated');
    
    %%%% Type Widget %%%%
    typeWidget = create_unified_type_widget(h);
    
    if isBindToSignal || isContinuousUpdate
        typeWidget.Visible = false;
    elseif (isExternalDSM)
        typeWidget.Enabled = false;
    end
    %%%% Type Widget %%%%
    
    %%%% Top Panel %%%%
    deadWidgets = {};
    
    nameEdit = create_edit(h, 'Name', [], true);
    nameLabel = create_label(nameEdit, [commonMessage('Name') ':'], 'Name');
    
    tunableCheck = create_check(h, 'Tunable', message('Tunable'));
    
    isDynamicMatrixCheck = create_check(h, 'Props.Array.IsDynamic', message('VariableSize'));
    
    sizesEdit = create_edit(h, 'Props.Array.Size');
    sizesDoesNotApply = isOpaqueSize || isBindToSignal || isExternalDSM;
    if isTypeModeBus && ~sf('feature', 'Bus Arrays')
        sizesDoesNotApply = true;
    end

    [sizesEdit, deadWidgets] = create_dead_widget(deadWidgets, sizesEdit, sizesDoesNotApply);
    if(isExternalDSM)
        sizesEdit.Value = '-1';
    end
    sizesLabel = create_label(sizesEdit, [message('Size') ':'], 'Size');
    
    generalTopLayout = {...
        nameLabel,  nameEdit,   nameEdit,       nameEdit; ...
        scopeLabel, scopeCombo, [],             []; ...
        [],         [],         [],             []; ...   % reserved for local data update method
        [],         [],         [],             []; ...   % reserved for bind to signal checkbox
        sizesLabel, sizesEdit,  [],             []; ...
        };
    
    if canBeContinuous
        [timingSemanticsCombo, timingSemanticsValue] = create_combo(h, 'UpdateMethod'); %#ok<NASGU>
        timingSemanticsLabel = create_label(timingSemanticsCombo, [message('UpdateMethod') ':'], 'UpdateMethod');
        generalTopLayout(3,:) = {timingSemanticsLabel, timingSemanticsCombo, [], []};
    end
    
    if bindToSignalApply
        signalBindingCheck = create_check(h, 'Props.resolveToSignalObject', message('SignalBindingCheck'));
        signalBindingCheck.Mode = 1; % immediate update
        signalBindingCheck.DialogRefresh = true;
        generalTopLayout(4,:) = {signalBindingCheck, signalBindingCheck, signalBindingCheck, signalBindingCheck};
    end
    
    if isIO
        portCombo = create_combo(h, 'Port');
        portLabel = create_label(portCombo, [commonMessage('Port') ':'], 'Port');
        generalTopLayout{2,3} = portLabel;
        generalTopLayout{2,4} = portCombo;
    end
    
    isVariableSizingEnabled = sf('IsVariableSizingON', h.Id);
    if(isEmlChartParented || isEmlTruthTableParented)
        % Inputs, outputs and parameters in EML block or EML TT can be dynamic.
        % Non-tunable parameters can not be dynamic, this is checked in dataddg_preapply_callback.m
        showDynamicMatrixCheck = isVariableSizingEnabled;
    else
        % In a Stateflow chart, dynamic data are limited
        % to inputs, outputs, locals and EML-parented data.
        % That is, SF graphical functions an not contain dynamic data.
        %
        % For 10A, we have levels of support for dynamic matrices
        % in Stateflow. Level 1 support is merely passthrough
        % where we do not allow any local data to be variable
        % sized.
        if sf('feature', 'Dynamic Matrices') > 2
            showDynamicMatrixCheck = isVariableSizingEnabled && (isIO || isLocal || isEmlParented);
        else
            showDynamicMatrixCheck = isVariableSizingEnabled && (isIO || isEmlParented);
        end
    end
    showDynamicMatrixCheck = showDynamicMatrixCheck && ~isContinuousUpdate && ~isBindToSignal && ~sizesDoesNotApply && ~isConstant;
    
    if(showDynamicMatrixCheck)
        % Variable size arrays and parameters is currently not
        % implemented
        if isParameter || isTypeModeBus
            isDynamicMatrixCheck.Enabled = 0;
            isDynamicMatrixCheck.Value = 0;
        end
        generalTopLayout{5,3} = isDynamicMatrixCheck;
        generalTopLayout{5,4} = isDynamicMatrixCheck;
    else
        deadWidgets = append_dead_widget(deadWidgets, isDynamicMatrixCheck);
    end
    
    if isParameter && isEmlParented && isChartParented
        generalTopLayout{2,3} = tunableCheck;
        generalTopLayout{2,4} = tunableCheck;
    else
        deadWidgets = append_dead_widget(deadWidgets, tunableCheck);
    end
    
    if ~isTypeModeBus && ~isContinuousUpdate && ~isTypeModeEnum
        complexCombo = create_combo(h, 'Props.Complexity');
        complexCombo.Enabled = ~isBindToSignal && ~isTypeModeBus && ~isExternalDSM ...
            && ~isConstant;
        complexLabel = create_label(complexCombo, [message('Complexity') ':'], 'Complexity');
        generalTopLayout{6,1} = complexLabel;
        generalTopLayout{6,2} = complexCombo;
    end
    
    if isChartOutput && isEmlParented && ~isTypeModeBus
        frameCombo = create_combo(h, 'Props.Frame');
        frameCombo.Enabled = ~isBindToSignal && ~isTypeModeBus;
        frameLabel = create_label(frameCombo, [message('FrameLabel') ':'], 'FrameLabel');
        generalTopLayout{7,1} = frameLabel;
        generalTopLayout{7,2} = frameCombo;
    end
    
    if isDSM && ~isEmlParented && sf('feature', 'Allow Chart Local DSMs')
        chartLocalDsmCheck = create_check(h, 'isChartLocalDSM', 'Create a chart local DSM (do not import from container)');
        chartLocalDsmCheck.Mode = 1; % immediate update
        chartLocalDsmCheck.DialogRefresh = true;
        
        generalTopLayout(8,:) = {chartLocalDsmCheck, chartLocalDsmCheck, chartLocalDsmCheck, chartLocalDsmCheck};
    end
    
    generalTopPanel = create_panel('General Top');
    generalTopPanel.ColStretch = [0 1 0 1];
    generalTopPanel = layout_ddg_items(generalTopPanel, generalTopLayout);
    generalTopPanel.Items = [generalTopPanel.Items deadWidgets];
    %%%% Top Panel %%%%
    
    %%%% InitVal Panel %%%%
    deadWidgets = {};
    
    initValDoesNotApply = (isParameter || isDSM || isChartInput || isEmlChartParented);
    
    [initialCombo, initialValue] = create_combo(h, 'InitializeMethod');
    [initialCombo, deadWidgets] = create_dead_widget(deadWidgets, initialCombo, initValDoesNotApply);
    initialLabel = create_label(initialCombo, [message('InitialValue') ':'], 'InitialValue');
    
    initialEdit = create_edit(h, 'Props.InitialValue', 'Initial value');
    initialEdit.HideName = true; % IMPORTANT: the hidden name is used by unified data type widget.    
    [initialEdit, deadWidgets] = create_dead_widget(deadWidgets, initialEdit, initValDoesNotApply);
    initialEdit.Enabled = strcmp(initialValue, 'Expression');
    
    initialLabel.Enabled = initialCombo.Enabled || initialEdit.Enabled;
        
    initValLayout = {initialLabel, initialCombo, initialEdit};
    initValPanel = create_panel('General InitVal');
    initValPanel.ColStretch = [0 1 1];
    initValPanel = layout_ddg_items(initValPanel, initValLayout);
    initValPanel.Items = [initValPanel.Items deadWidgets];
    
    if(initValDoesNotApply)
        initValPanel.Visible = false;
    end    
    %%%% InitVal Panel %%%%
    
    %%%% Limit Groupbox %%%%
    deadWidgets = {};
    
    minMaxDoesntApply = isOpaqueSize || isConstant || isParameter || isTypeModeBus || isTypeModeEnum || isBindToSignal;
    
    minEdit = create_edit(h, 'Props.Range.Minimum', 'Minimum:');
    minEdit.HideName = true; % IMPORTANT: the hidden name is used by unified data type widget.
    [minEdit, deadWidgets] = create_dead_widget(deadWidgets, minEdit, minMaxDoesntApply);
    minLabel = create_label(minEdit, [message('Minimum') ':'], 'Minimum');
    
    maxEdit = create_edit(h, 'Props.Range.Maximum', 'Maximum:');
    maxEdit.HideName = true; % IMPORTANT: the hidden name is used by unified data type widget.
    [maxEdit, deadWidgets] = create_dead_widget(deadWidgets, maxEdit, minMaxDoesntApply);
    maxLabel = create_label(maxEdit, [message('Maximum') ':'], 'Maximum');
    
    limitLayout = {minLabel, minEdit, maxLabel, maxEdit};
    limitGroup = create_group(message('LimitRange'), 'LimitRange');
    limitGroup = layout_ddg_items(limitGroup, limitLayout);
    limitGroup.Items = [limitGroup.Items deadWidgets];
    
    if(minMaxDoesntApply)
        limitGroup.Visible = false;
    end
    %%%% Limit Groupbox %%%%
    
    %%%% Check Panel %%%%
    deadWidgets = {};
    
    isTestPointCheck = create_check(h, 'TestPoint', true);
    isTestPointDoesNotApply = ~isLocal || isMachineParented || isOpaqueSize || isTypeModeBus || isEmlChartParented;
    [isTestPointCheck, deadWidgets] = create_dead_widget(deadWidgets, isTestPointCheck, isTestPointDoesNotApply);
    
    watchInDebuggerCheck = create_check(h, 'Debug.Watch', 'Watch in debugger');
    watchInDebuggerCheckDoesNotApply = isEmlChartParented;
    [watchInDebuggerCheck, deadWidgets] = create_dead_widget(deadWidgets, watchInDebuggerCheck, watchInDebuggerCheckDoesNotApply);
    
    checkLayout = {isTestPointCheck, watchInDebuggerCheck};
    checkPanel = create_panel('General Check');
    checkPanel = layout_ddg_items(checkPanel, checkLayout);
    checkPanel.Items = [checkPanel.Items deadWidgets];
    
    if(isEmlChartParented)
        checkPanel.Visible = false;
    end
    %%%% Check Panel %%%%
        
    generalLayout = {generalTopPanel; ...
        typeWidget; ...
        initValPanel; ...
        limitGroup; ...
        checkPanel; ...
        spacer('general')};    
    
    generalTab = create_tab(message('GeneralTab'));
    generalTab = layout_ddg_items(generalTab, generalLayout);
    generalTab = stretch_row_end(generalTab);
    %%%% General Tab %%%%
    
    %%%% Descriptions Tab %%%%
    %%%% SaveWS Panel %%%%
    deadWidgets = {};
    
    saveToWorkspaceCheck = create_check(h, 'SaveToWorkspace', message('SaveToWorkspace'));
    saveToWorkspaceDoesNotApply = isConstant || isParameter || isDSM;
    [saveToWorkspaceCheck, deadWidgets] = create_dead_widget(deadWidgets, saveToWorkspaceCheck, saveToWorkspaceDoesNotApply);
    
    saveWsLayout = {saveToWorkspaceCheck, saveToWorkspaceCheck,   saveToWorkspaceCheck};
    
    saveWsPanel = create_panel('Descriptions SaveWs');
    saveWsPanel = layout_ddg_items(saveWsPanel, saveWsLayout);
    saveWsPanel = stretch_column_end(saveWsPanel);
    saveWsPanel.Items = [saveWsPanel.Items deadWidgets];
    %%%% SaveWS Panel %%%%
    
    %%%% Junk Panel %%%%
    deadWidgets = {};
    
    unitsEdit = create_edit(h, 'Props.Type.Units');
    unitsDoesNotApply = isDSM || isEmlParented;
    [unitsEdit, deadWidgets] = create_dead_widget(deadWidgets, unitsEdit, unitsDoesNotApply);
    unitsLabel = create_label(unitsEdit);
    
    firstIndexEdit = create_edit(h, 'Props.Array.FirstIndex');
    firstIndexDoesNotApply = isOpaqueSize || isEmlParented || isTypeModeBus || isTypeModeEnum;
    [firstIndexEdit, deadWidgets] = create_dead_widget(deadWidgets, firstIndexEdit, firstIndexDoesNotApply);
    firstIndexLabel = create_label(firstIndexEdit);
    
    junkLayout = {  ...
        firstIndexLabel,    firstIndexEdit, spacer('junk');...
        unitsLabel,         unitsEdit,      spacer('junk')};
    
    junkPanel = create_panel('Descriptions Junk');
    junkPanel = layout_ddg_items(junkPanel, junkLayout);
    junkPanel = stretch_column_end(junkPanel);
    junkPanel.Items = [junkPanel.Items deadWidgets];
    
    if(isEmlParented)
        junkPanel.Visible = false;
    end
    %%%% Junk Panel %%%%
    
    %%%% Desc Panel %%%%
    deadWidgets = {};
        
    description = create_editarea(h, 'Description', [commonMessage('Description') ':']);
    documentHyper = create_hyper([commonMessage('DocumentLink') ':'], 'dlg_goto_document', h.Id, 'DocumentLink');
    documentEdit = create_edit(h, 'Document');
    
    descLayout = {description,    description; ...
                    documentHyper,  documentEdit};
    descPanel = create_panel('Descriptions Desc');
    descPanel = layout_ddg_items(descPanel, descLayout);
    descPanel.Items = [descPanel.Items deadWidgets];
    %%%% Desc Panel %%%%
    
    descLayout = {   saveWsPanel;...
        junkPanel;...
        descPanel;...
        spacer('attributes')};
    
    descTab = create_tab(message('DescriptionTab'));
    descTab = layout_ddg_items(descTab, descLayout);
    descTab = stretch_row_end(descTab);
    
    %%%% Descriptions Tab %%%%
    
    tabContainer = create_tab_set('Tabs');
    if isempty(descTab)
        tabContainer.Tabs = {generalTab};
    else
        tabContainer.Tabs = {generalTab, descTab};
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%
    % Main dialog
    %%%%%%%%%%%%%%%%%%%%%%%
    
    % if the developer feature is on append the id to the title
    if sf('Feature','Developer')
        id = sprintf('%0.5g', h.Id);
        dlgstruct.DialogTitle = strcat('Data#',id);
    else
        dlgstruct.DialogTitle = [commonMessage('Data') ' ' h.name];
    end
    dlgstruct.SmartApply = false;
    dlgstruct.DialogTag = create_unique_dialog_tag(h);
    dlgstruct.CloseCallback = 'sf';
    dlgstruct.CloseArgs = {'Private', 'dataddg_preclose_callback', '%dialog'};
    dlgstruct.PreApplyCallback = 'sf';
    dlgstruct.PreApplyArgs     = {'Private', 'dataddg_preapply_callback', '%dialog'};
    dlgstruct.Items =  {tabContainer};
    dlgstruct.HelpMethod = 'sfhelp';
    dlgstruct.HelpArgs = {h,'DATA_DIALOG'};
    dlgstruct.DisableDialog = ~is_object_editable(h);
    
    %--------------------------------------------------------------------------
function [parentName, isChartParented, isMachineParented,...
        isEmlParented, isEmlChartParented, isEmlTruthTableParented] = get_parent_info_l(h)
    isChartParented = false;
    isMachineParented = false;
    
    parent = sf('get',h.Id,'data.linkNode.parent');
    
    isEmlParented = is_eml_parented_data(h.Id);
    isEmlChartParented = is_eml_chart(parent);
    
    [MACHINE,CHART,STATE] = sf('get','default','machine.isa','chart.isa','state.isa');
    
    switch sf('get',parent,'.isa')
        case MACHINE
            isMachineParented = true;
            parentName = commonMessage('LowerMachine');
        case CHART
            isChartParented = true;
            if is_sf_chart(parent)
                parentName = commonMessage('LowerChart');
            else
                parentName = '';
            end
        case STATE
            type = sf('get',parent,'.type');
            if type==3 %GROUP_STATE
                parentName = commonMessage('LowerBox');
            elseif(type==2)
                parentName = commonMessage('LowerFunction');
            else
                parentName = commonMessage('LowerState');
            end
        case EVENT
            parentName = commonMessage('LowerEvent');
        otherwise
            parentName = sprintf('#%d',parent);
    end
    if isempty(parentName)
        parentName = sprintf('%s',sf('FullNameOf',parent,'.'));
    else
        parentName = sprintf('(%s) %s',parentName,sf('FullNameOf',parent,'.'));
    end
    
    isEmlTruthTableParented = isChartParented && is_eml_truth_table_chart(parent);
    
    %--------------------------------------------------------------------------
function widget = stretch_row_end(widget)
    widget.RowStretch(widget.LayoutGrid(1)) = 1;
    
    %--------------------------------------------------------------------------
function widget = stretch_column_end(widget)
    widget.ColStretch(widget.LayoutGrid(2)) = 1;
    
    %--------------------------------------------------------------------------
function s = spacer(label)
    s = create_widget('panel', [label '_spacer'], false);
    
    %--------------------------------------------------------------------------
function labelWidget = create_label(widget, label, tag)
    if nargin == 1
        label = label_for_widget(widget, true);
        tag = label;
    end
    labelWidget = create_widget('text', tag);
    labelWidget.Name = label;
    labelWidget.Enabled = widget.Enabled;
    labelWidget.Alignment = 0;
    
    %--------------------------------------------------------------------------
function [editWidget, editValue] = create_edit(h, property, label, dialogRefresh)
    editWidget = create_widget('edit', property);
    editWidget = set_widget_property(h, editWidget, property);
    if nargin > 2 && ~isempty(label)
        editWidget = label_widget(editWidget, label, true);
    end
    if nargin > 3 && ~isempty(dialogRefresh) && dialogRefresh
        editWidget.DialogRefresh = 1;
        editWidget.Mode = 1;
        editValue = '';
    end
    
    %--------------------------------------------------------------------------
function editareaWidget = create_editarea(h, property, label)
    editareaWidget = create_widget('editarea', property);
    editareaWidget = set_widget_property(h, editareaWidget, property);
    editareaWidget.WordWrap = true;
    if nargin > 2
        editareaWidget = label_widget(editareaWidget, label, true);
    end
    
    %--------------------------------------------------------------------------
function hyperWidget = create_hyper(linkText, hyperMethod, id, tag)
    hyperWidget = create_widget('hyperlink', tag);
    hyperWidget.Name = linkText;
    hyperWidget.MatlabMethod = 'sf';
    hyperWidget.MatlabArgs = {'Private', hyperMethod, id};
    
    %--------------------------------------------------------------------------
function [comboWidget, comboValue] = create_combo(h, property, label)
    comboWidget = create_widget('combobox', property);
    comboWidget = set_widget_property(h, comboWidget, property);
    if nargout > 1
        comboWidget.DialogRefresh = 1;
        comboWidget.Mode = 1;
    end
    
    [comboWidget.Entries, comboValue] = get_valid_data_property_values(h, property);
    
    comboWidget.Enabled = length(comboWidget.Entries) > 1;
    comboWidget = set_values_for_enums(comboWidget);
    if nargin > 2
        comboWidget = label_widget(comboWidget, label, true);
    end
    
    %--------------------------------------------------------------------------
function checkWidget = create_check(h, name, label)
    checkWidget = create_widget('checkbox', name);
    checkWidget = set_widget_property(h, checkWidget, name);
    if nargin > 2
        checkWidget = label_widget(checkWidget, label, false);
    end
    
    %--------------------------------------------------------------------------
function groupWidget = create_group(name, tag)
    groupWidget = create_widget('group', tag, false);
    groupWidget.Name = name;
    
    %--------------------------------------------------------------------------
function panelWidget = create_panel(name)
    panelWidget = create_widget('panel', name, false);
    
    %--------------------------------------------------------------------------
function buttonWidget = create_button(name, tag)
    buttonWidget = create_widget('pushbutton', tag, true);
    buttonWidget.Name = name;
    
    %--------------------------------------------------------------------------
function tabWidget = create_tab(name)
    tabWidget.Name = name;
    
    %--------------------------------------------------------------------------
function tabSetWidget = create_tab_set(name)
    tabSetWidget = create_widget('tab', name, false);
    
    %--------------------------------------------------------------------------
function tag = construct_widget_tag(widgetType, uniqueTagString, delimiter)
    % "uniqueTagString" must be pure ASCII string
    if nargin < 3
        delimiter = '_';
    end
    uniqueTokens = regexpi(uniqueTagString, '[a-z]*', 'match');
    uniqueTokens = [{'sfDatadlg'} uniqueTokens];
    uniqueTokens = strcat(uniqueTokens, delimiter);
    uniqueTokens{end+1} = widgetType;
    tag = strcat(uniqueTokens{:});
    
    %--------------------------------------------------------------------------
function widget = create_widget(widgetType, uniqueTagString, enable)
    % "uniqueTagString" must be pure ASCII string
    widget.Type = widgetType;
    widget.Tag = construct_widget_tag(widgetType, uniqueTagString);
    if nargin < 3
        enable = true;
    end
    if enable
        widget.Enabled = true;
    end
    
    %--------------------------------------------------------------------------
function widget = label_widget(widget, label, addColon)
    if ischar(label)
        widget.Name = label;
    else
        widget.Name = label_for_widget(widget, addColon);
    end
    
    %--------------------------------------------------------------------------
function label = label_for_widget(widget, addColon)
    property = regexpi(widget.Tag, '[a-z]*(?=_[a-z]*(_DEAD)?$)', 'match', 'once');
    words = regexp(property, '[A-Z][a-z]*', 'match');
    if length(words) == 1
        label = words{1};
    else
        words = [words(1) strcat({' '}, lower(words(2:end)))];
        label = strcat(words{:});
    end
    if addColon
        label = [label ':'];
    end
    
    %--------------------------------------------------------------------------
function widget = set_widget_property(h, widget, property)
    [widget.Source, widget.ObjectProperty] = refactor_object_and_property(h, property);
    widget.Enabled = true;
    
    %--------------------------------------------------------------------------
function [widget, deadWidgets] = create_dead_widget(deadWidgets, widget, killIt)
    if killIt
        deadWidgets = append_dead_widget(deadWidgets, widget);
        widget = rmfield(widget, {'Source', 'ObjectProperty'});
        widget.Tag = [widget.Tag '_DEAD'];
        widget.Enabled = false;
    end
    
    %--------------------------------------------------------------------------
function deadWidgets = append_dead_widget(deadWidgets, widget)
    widget.Visible = false;
    widget.Enabled = false;
    deadWidgets{end+1} = widget;
    
    %--------------------------------------------------------------------------
function comboWidget = set_values_for_enums(comboWidget)
    enumVals = comboWidget.Entries;
    vals = zeros(1, length(enumVals));
    switch comboWidget.ObjectProperty
        case 'Scope'
            for i=1:length(enumVals)
                switch lower(enumVals{i})
                    case 'local'
                        vals(i) = 0;
                    case 'input'
                        vals(i) = 1;
                    case 'output'
                        vals(i) = 2;
                    case 'workspace_data'
                        vals(i) = 3;
                    case 'imported'
                        vals(i) = 4;
                    case 'exported'
                        vals(i) = 5;
                    case 'temporary'
                        vals(i) = 6;
                    case 'constant'
                        vals(i) = 7;
                    case 'function input'
                        vals(i) = 8;
                    case 'function output'
                        vals(i) = 9;
                    case 'parameter'
                        vals(i) = 10;
                    case 'data store memory'
                        vals(i) = 11;
                end
            end
        case {'Props.Type.Method', 'Props.Type.Primitive'}
            for i=1:length(enumVals)
                switch lower(enumVals{i})
                    case 'built-in'
                        vals(i) = 0;
                    case 'boolean'
                        vals(i) = 1;
                    case 'state'
                        vals(i) = 2;
                    case 'uint8'
                        vals(i) = 3;
                    case 'int8'
                        vals(i) = 4;
                    case 'uint16'
                        vals(i) = 5;
                    case 'int16'
                        vals(i) = 6;
                    case 'uint32'
                        vals(i) = 7;
                    case 'int32'
                        vals(i) = 8;
                    case 'single'
                        vals(i) = 9;
                    case 'double'
                        vals(i) = 10;
                    case 'fixed point'
                        vals(i) = 15;
                    case 'ml'
                        vals(i) = 12;
                    case 'inherited'
                        vals(i) = 13;
                    case 'expression'
                        vals(i) = 14;
                    case 'custom integer'
                        vals(i) = 15;
                    otherwise
                        vals(i) = 0;
                end
            end
        case 'Port'
            vals = str2double(enumVals);
        otherwise
            return;
    end
    comboWidget.Values = vals;
    
    %--------------------------------------------------------------------------
function [busObjectEdit, editBusButton] = create_bus_widgets(h, forUDT)
    % forUDT: create widget for unified data type feature?
    
    if nargin < 2
        forUDT = false;
    end
    
    busObjectEdit = create_edit(h, 'Props.Type.BusObject', 'Bus object:');
    editBusButton = create_button(commonMessage('Edit'), 'EditBusObject');
    
    if forUDT
        % 1. Break the link between busEdit and data property for UDT
        busObjectEdit = rmfield(busObjectEdit, {'Source', 'ObjectProperty'});
        busObjectEdit.Graphical = 1;
        
        % 2. Populate the initial value of this edit
        rel = parse_data_type_string(h.Id);
        if strcmpi(rel.mode, 'bus object')
            if isempty(rel.type)
                busObjectEdit.Value = '<bus object name>';
            else
                busObjectEdit.Value = rel.type;
            end
        end
        
        % 3. Assign unique tags by prepend UDT tag prefix
        prefixStr = Simulink.DataTypePrmWidget.getUniqueTagPrefix(get_udt_tag);
        busObjectEdit.Tag = [prefixStr '_' get_bus_edit_tag];
        editBusButton.Tag = [prefixStr '_EditBusButton'];
        
        % 4. Add callback
        busObjectEdit.MatlabMethod = 'Simulink.DataTypePrmWidget.callbackDataTypeWidget';
        busObjectEdit.MatlabArgs = { 'valueChangeEvent', '%dialog', '%tag' };
    end
    
    editBusButton.MatlabMethod = 'sf';
    editBusButton.MatlabArgs = {'Private', 'dataddg_bus_edit_callback', h, busObjectEdit.Tag};
    
    %--------------------------------------------------------------------------
function enumTypeEdit = create_enum_widgets(h, forUDT)
    % forUDT: create widget for unified data type feature?
    
    if nargin < 2
        forUDT = false;
    end
    
    enumTypeEdit = create_edit(h, 'Props.Type.EnumType',[ message('EnumType') ':' ]);
    
    if forUDT
        % 1. Break the link between enumTypeEdit and data property for UDT
        enumTypeEdit = rmfield(enumTypeEdit, {'Source', 'ObjectProperty'});
        enumTypeEdit.Graphical = 1;
        
        % 2. Populate the initial value of this edit
        rel = parse_data_type_string(h.Id);
        if strcmpi(rel.mode, 'enumerated')
            if isempty(rel.type)
                enumTypeEdit.Value = '<enum type name>';
            else
                enumTypeEdit.Value = rel.type;
            end
        end
        
        % 3. Assign unique tag by prepend UDT tag prefix
        prefixStr = Simulink.DataTypePrmWidget.getUniqueTagPrefix(get_udt_tag);
        enumTypeEdit.Tag = [prefixStr '_' get_enum_edit_tag];
        
        % 4. Add callback
        enumTypeEdit.MatlabMethod = 'Simulink.DataTypePrmWidget.callbackDataTypeWidget';
        enumTypeEdit.MatlabArgs = { 'valueChangeEvent', '%dialog', '%tag' };
    end
    
    %--------------------------------------------------------------------------
function lockCheck = create_lock_scaling_check(h)
    
    lockCheck = create_check(h, 'Props.Type.Fixpt.Lock', message('LockOutputScaling'));
    
    %--------------------------------------------------------------------------
function value = bus_get_val(hDialog, tagPrefix)
    
    busEditTag = [tagPrefix '_' get_bus_edit_tag];
    value = hDialog.getWidgetValue(busEditTag);
    
    %--------------------------------------------------------------------------
function bus_set_val(hDialog, tagPrefix, val)
    
    busEditTag = [tagPrefix '_' get_bus_edit_tag];
    hDialog.setWidgetValue(busEditTag, val);
    
    %--------------------------------------------------------------------------
function value = enum_get_val(hDialog, tagPrefix)
    
    enumEditTag = [tagPrefix '_' get_enum_edit_tag];
    value = hDialog.getWidgetValue(enumEditTag);
    
    %--------------------------------------------------------------------------
function enum_set_val(hDialog, tagPrefix, val)
    
    enumEditTag = [tagPrefix '_' get_enum_edit_tag];
    hDialog.setWidgetValue(enumEditTag, val);
    
    %--------------------------------------------------------------------------
function propName = get_udt_prop_name
    % The property name of unified data type on UDData object
    
    propName = 'DataType';
    
    %--------------------------------------------------------------------------
function tag = get_udt_tag
    
    tag = construct_widget_tag('combobox', get_udt_prop_name, '');
    
    %--------------------------------------------------------------------------
function tag = get_bus_edit_tag
    
    tag = 'BusObjectEdit';
    
    %--------------------------------------------------------------------------
function tag = get_enum_edit_tag
    
    tag = 'EnumTypeEdit';
    
    %--------------------------------------------------------------------------
function dtaItems = install_sf_specific_type_mode_widgets(h, dtaItems)
    
    for i = 1:length(dtaItems.extras)
        switch dtaItems.extras(i).name
            case 'Bus Object'
                [busObjectEdit, editBusButton] = create_bus_widgets(h, true);
                busPanel = create_panel('Bus Edit Panel');
                busPanel = layout_ddg_items(busPanel, {busObjectEdit, editBusButton});
                busPanel.ColStretch = [1 0];
                
                dtaItems.extras(i).container = busPanel;
                dtaItems.extras(i).getval = @bus_get_val;
                dtaItems.extras(i).setval = @bus_set_val;
                
            case 'Enumerated'
                enumTypeEdit = create_enum_widgets(h, true);
                enumPanel = create_panel('Enum Edit Panel');
                enumPanel = layout_ddg_items(enumPanel, {enumTypeEdit});
                
                dtaItems.extras(i).container = enumPanel;
                dtaItems.extras(i).getval = @enum_get_val;
                dtaItems.extras(i).setval = @enum_set_val;
                
            otherwise
                error('Stateflow:UnexpectedError','Stateflow internal error: unsupported data type mode "%s".', dtaItems.extras(i).name);
        end
    end
    
    %--------------------------------------------------------------------------
function dtaItems = enable_set_scaling_tool(h, dtaItems)
    
    switch h.Scope
        case {'Parameter', 'Data Store Memory'}
            % No set scaling button for parameter/DSM data
        case 'Constant'
            % Set scaling based on constant value
            initValEditTag = construct_widget_tag('edit', 'Props.InitialValue');
            dtaItems.scalingValueTags = {initValEditTag};
        otherwise
            % For all other scope data, use min/max to set scaling
            minEditTag = construct_widget_tag('edit', 'Props.Range.Minimum');
            maxEditTag = construct_widget_tag('edit', 'Props.Range.Maximum');
            dtaItems.scalingMinTag = {minEditTag};
            dtaItems.scalingMaxTag = {maxEditTag};
    end
    
    %--------------------------------------------------------------------------
function typeWidget = install_lock_scaling_check(h, typeWidget)
    
    lockCheck = create_lock_scaling_check(h);
    
    rel = parse_data_type_string(h.Id);
    lockCheck.Visible = rel.showLockScalingCheck;
    
    nRow = typeWidget.LayoutGrid(1) + 1; % Append checkbox to last row
    nCol = typeWidget.LayoutGrid(2);
    
    lockCheck.RowSpan = [nRow nRow];
    lockCheck.ColSpan = [1 nCol];
    
    typeWidget.LayoutGrid = [nRow nCol];
    typeWidget.RowStretch = [typeWidget.RowStretch 0];
    typeWidget.Items = [typeWidget.Items lockCheck];
    
    %--------------------------------------------------------------------------
function typeWidget = make_type_widget_immediately_apply(typeWidget)
    
    typeWidget.Items{2}.Mode = 1;
    typeWidget.Items{2}.DialogRefresh = 1;
    
    %--------------------------------------------------------------------------
function typeWidget = create_unified_type_widget(h)
    
    dtName = get_udt_prop_name;
    dtPrompt = [message('Type') ':'];
    dtTag = get_udt_tag;
    dtVal = get(h, dtName);
    dtaOn = false;
    
    dtaItems = get_data_type_items(h);
    dtaItems = install_sf_specific_type_mode_widgets(h, dtaItems);
    dtaItems = enable_set_scaling_tool(h, dtaItems);
    
    typeWidget = Simulink.DataTypePrmWidget.getDataTypeWidget(h, dtName, dtPrompt, dtTag, dtVal, dtaItems, dtaOn);
    
    typeWidget = install_lock_scaling_check(h, typeWidget);
    typeWidget = make_type_widget_immediately_apply(typeWidget);
    typeWidget.Name = 'Type'; % Give panel a name. Used for testing.
    
function s = commonMessage(id,varargin)
    
    s = DAStudio.message(['Stateflow:dialog:Common' id],varargin{:});
    
function s = message(id,varargin)
    
    s = DAStudio.message(['Stateflow:dialog:Data' id],varargin{:});
