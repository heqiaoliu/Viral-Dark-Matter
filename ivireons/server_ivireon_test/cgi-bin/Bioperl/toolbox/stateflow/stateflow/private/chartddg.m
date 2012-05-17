function dlgstruct = chartddg(h, name) %#ok

% Copyright 2002-2010 The MathWorks, Inc.

% We ignore name here
isEMLBased = is_eml_based_chart(h.Id);
isSFBasedChart = ~isEMLBased;
editable = is_object_editable(h);

% IMPORTANT:
% Please follow the following important rules when modifying chartddg.m
%
% 1. Every item which needs to be placed should always delcare its RowSpan
%    property to be [row, row]. Anything else and we will have items with
%    emtpy space between them or running into each other. If you want a
%    single item to contain multiple lines, then create a panel which
%    contains nested items. See nonTerminalSpecsUI below for details.
%
% 2. Be careful of the .Mode settings. For example, the value returned by
%    executeAtInitializationUI is a structure with the field .Mode set to
%    one. You must always set this to 1 if there are other chart properties
%    which change this value as a side-effect. To be more clear:
%
%    The stateMachineType property of a chart when set to Moore sets the
%    executeAtInitialization property to 1. Moreover, the stateMachineType
%    UI returns an item with Mode=1. In this case, the
%    executeAtInitialization property should also have Mode=1. Otherwise,
%    the order in which the changes are applied is different from the order
%    in which the user actually set things in the UI, leading to very
%    confusing UI behavior.
% 
% 3. Also be very careful not to set chart properties while creating the
%    items. For example, do not put a statement like
%           h.ExecuteAtInitialization = true;
%    in the function which can get called from chartddg.m Otherwise, the
%    function chartddg.m becomes recursive and the place method which
%    contains a persistent variable begins doing really bad things. If you
%    need to do things like that, do it in C++ land (chart.cpp)
%
%    If this doesn't make sense, please see Srinath.
place([]);
items = {
    place(@hyperPanelUI), ...
    place(@stateMachineTypeUI),...
    place(@sampleTimeUI),...
    place(@enableZeroCrossingsUI),...
    place(@derivativesFormatStringUI),...
    place(@bitopsUI),...
    place(@execOrderUI),...
    place(@exportChartUI),...
    place(@strongDataTypingUI),...
    place(@executeAtInitializationUI),...
    place(@initializeOutputUI),...
    place(@enableNonTerminalStatesUI),...
    place(@nonTerminalSpecsUI),...
    place(@variableSizingUI),...
    place(@statesWhenEnablingUI),...
    place(@debuggerPanelUI,0),...
    place(@embeddedMatlabPropertiesUI),...
    place(@pnlDebuggerAndEditUI),...
    place(@signalConversionUI), ...
    place(@descriptionUI), ...
    place(@panelDocUI)...
    };

I = 1:numel(items);
for i = I
    if ~isempty(items{i})
       I(i) = -1;
    end
end
items(I>0) = [];

%%%%%%%%%%%%%%%%%%%%%%%
% Main dialog
%%%%%%%%%%%%%%%%%%%%%%%
title = get_chart_title_l(h);
% if the developer feature is on append the id to the title
if sf('Feature','Developer')
    id_str = strcat('#',sf_scalar2str(h.Id));
    dlgstruct.DialogTitle = strcat(title,id_str);
else
    dlgstruct.DialogTitle = title;
end
dlgstruct.Items = items;

dlgstruct.LayoutGrid = [length(items) 3];
dlgstruct.ColStretch = [0 0 1];
dlgstruct.RowStretch = zeros([1, length(items)]); 
dlgstruct.RowStretch(end-2) = 1;

dlgstruct.CloseCallback = 'sf';
dlgstruct.CloseArgs = {'SetDynamicDialog', h.Id, []};
dlgstruct.DialogTag = get_chart_properties_tag(h);

dlgstruct.HelpMethod = 'sfhelp';
dlgstruct.HelpArgs = {h,'CHART_DIALOG'};
dlgstruct.DialogRefresh = 1;

    function item = place(fhandle, skip)
        persistent n
        if isempty(fhandle)
            n = 1;
        end
        if nargin < 2 || isempty(skip)
            skip = 1;
        end
        
        if ~isempty(fhandle)
            item = fhandle(n);
            if ~isempty(item)
                n = n + skip;
            end
        end
    end

%------------------------------------------------------------------------------
    function P = hyperPanelUI(row)
        %Chart Name
        nameLabel.Name = [commonMessage('Name') ':'];
        nameLabel.RowSpan = [1 1];
        nameLabel.ColSpan = [1 1];
        nameLabel.Type = 'text';
        nameLabel.Tag = 'sfChartdlg_Name:';

        chartName.Name = get_chart_name_l(h);
        chartName.RowSpan = [1 1];
        chartName.ColSpan = [2 2];
        chartName.Type = 'hyperlink';
        chartName.MatlabMethod = 'sf';
        chartName.Tag = 'chartHyperNameTag';
        chartName.MatlabArgs = {'Private', 'dlg_goto_object', h.Id};
        
        % parent widget
        parent.Name = [commonMessage('Machine') ':'];
        parent.RowSpan = [3 3];
        parent.ColSpan = [1 1];
        parent.Type = 'text';
        parent.Tag = 'sfChartdlg_Machine:';

        %parent hyper
        parentHyper.Name = get_parent_name_l(h);
        parentHyper.RowSpan = [3 3];
        parentHyper.ColSpan = [2 2];
        parentHyper.Type = 'hyperlink';
        parentHyper.MatlabMethod = 'sf';
        parentHyper.Tag = 'parentHyperTag';
        parentHyper.MatlabArgs = {'Private', 'dlg_goto_parent', h.Id};

        hyperPanel.Type = 'panel';
        hyperPanel.RowSpan = [row row];
        hyperPanel.LayoutGrid = [3 2];
        hyperPanel.ColStretch = [0 1];
        hyperPanel.Items = {nameLabel, chartName };
        if isSFBasedChart
            hyperPanel.Items = [hyperPanel.Items {parent, parentHyper}];
        end

        P = hyperPanel;

    end
%------------------------------------------------------------------------------
    function G = sampleTimeUI(row)

        update_popup.Name = [message('UpdateMethod') ':'];
        update_popup.Type = 'combobox';
        update_popup.RowSpan = [1 1];
        update_popup.ColSpan = [1 1];
        update_popup.ObjectProperty = 'ChartUpdate';
        update_popup.Mode = 1;
        update_popup.DialogRefresh = 1;
        update_popup.Entries = {'Inherited', 'Discrete', 'Continuous'};
        update_popup.Tag = 'sfChartdlg_Update method:';
        update_popup.Enabled = editable;
        update_popup.WidgetId = 'Stateflow.Chart.ChartUpdate';

        % Sample time
        updateMethod = sf('get',h.Id,'.updateMethod');
        sample.Name = [message('SampleTime') ':'];
        sample.Type = 'edit';
        sample.RowSpan = [1 1];
        sample.ColSpan = [2 2];
        sample.ObjectProperty = 'SampleTime';
        if updateMethod == 0
            sample.Enabled = 0;
            sample.InitialValue = '-1';
        elseif updateMethod == 2
            sample.Enabled = 0;
            sample.InitialValue = '';
        else
            sample.Enabled = editable;
        end
        sample.Tag = 'sfChartdlg_Sample Time:';
        sample.WidgetId = 'Stateflow.Chart.SampleTime';
        
        G.Name = '';
        G.Type = 'panel';
        G.RowSpan = [row row];
        G.ColSpan = [1 3];
        G.LayoutGrid = [1 2];
        G.ColStretch = [0 1];
        G.Items = {update_popup, sample };
        G.Tag = 'sfChartdlg_sample_group';
        
    end
%------------------------------------------------------------------------------
    function P = stateMachineTypeUI(row)

        if isSFBasedChart
            statemachine_popup.Name = [message('StateMachineType') ':'];
            statemachine_popup.Type = 'combobox';
            statemachine_popup.RowSpan = [row row];
            statemachine_popup.ColSpan = [1 1];
            statemachine_popup.ObjectProperty = 'StateMachineType';
            statemachine_popup.Mode = 1;
            statemachine_popup.DialogRefresh = 1;
            statemachine_popup.Entries = {'Classic', 'Mealy', 'Moore'};
            statemachine_popup.Tag = 'sfChartdlg_State Machine Type:';
            statemachine_popup.Enabled = editable;
            statemachine_popup.WidgetId = 'Stateflow.Chart.StateMachineType';
            P = statemachine_popup;
        else
            P = [];
        end
        
    end

    function P = statesWhenEnablingUI(row)

        chartBlockH = sfprivate('chart2block', h.Id);
        triggerH = Stateflow.SLUtils.findSystem(chartBlockH, 'BlockType', 'TriggerPort');
        if sf('feature', 'StatesWhenEnablingOption') && isSFBasedChart && ~isempty(triggerH)
            P.Name = [message('StatesWhenEnabling') ':'];
            P.Type = 'combobox';
            P.RowSpan = [row row];
            P.ColSpan = [1 1];
            P.ObjectProperty = 'StatesWhenEnabling';
            
            triggerUddH = get_param(triggerH, 'Object');
            
            P.Source = triggerUddH;
            P.Mode = 0;
            P.DialogRefresh = 1;
            P.Entries = {'Inherit', 'Held', 'Reset'};
            P.Tag = 'sfChartdlg_States When Enabling:';
            
            isReadOnly = triggerUddH.isReadonlyProperty('StatesWhenEnabling');
            P.Enabled = ~isReadOnly;
            P.WidgetId = 'Stateflow.Chart.StatesWhenEnabling';
        else
            P = [];
        end
        
    end

    function nonterminal = enableNonTerminalStatesUI(row)

        if isSFBasedChart && ~is_plant_model_chart(h.Id)
            nonterminal.Name = message('EnableSuperStepSemantics');
            nonterminal.RowSpan = [row row];
            nonterminal.ColSpan = [1 3];
            nonterminal.Type = 'checkbox';
            nonterminal.ObjectProperty = 'EnableNonTerminalStates';
            nonterminal.Tag = 'sfChartdlg_Enable Super Step Semantics';   
            nonterminal.DialogRefresh = 1;
            nonterminal.Mode = 1;
			nonterminal.Enabled = editable;
        else
            nonterminal = [];
        end
            
    end


    function maxSteps = nonTerminalSpecsUI(row)

        enableNTS = sf('get',h.Id,'.enableNonTerminalStates');
        
        if isSFBasedChart && enableNTS && ~is_plant_model_chart(h.Id)

            spc = '        ';
            
            maxStepsL.Name = [spc, message('NonTerminalMaxCounts') ': '];
            maxStepsL.Type = 'text';
            maxStepsL.RowSpan = [1 1];
            maxStepsL.ColSpan = [1 1];
            maxStepsL.Tag = 'sfChartdlg_label_Maximum Iterations in each Super Step';

            maxStepsE.Name = '';
            maxStepsE.Type = 'edit';
            maxStepsE.RowSpan = [1 1];
            maxStepsE.ColSpan = [2 2];
            maxStepsE.ObjectProperty = 'NonTerminalMaxCounts';
            maxStepsE.Tag = 'sfChartdlg_edit_';
            maxStepsE.WidgetId = 'Stateflow.Chart.NonTerminalMaxCounts';
            maxStepsE.InitialValue = '100';

            ntbl.Name = [spc, message('NonTerminalUnstableBehavior') ': '];
            ntbl.Type = 'text';
            ntbl.RowSpan = [2 2];
            ntbl.ColSpan = [1 1];
            ntbl.Mode = 1;
            ntbl.Tag = 'sfChartdlg_Behavior after too many iterations:';

            ntbc.Name = '';
            ntbc.Type = 'combobox';
            ntbc.RowSpan = [2 2];
            ntbc.ColSpan = [2 2];
            ntbc.ObjectProperty = 'NonTerminalUnstableBehavior';
            ntbc.Mode = 1;
            ntbc.DialogRefresh = 1;
            ntbc.Entries = {'Proceed', 'Throw Error'};
            ntbc.Tag = 'sfChartdlg_';
            ntbc.WidgetId = 'Stateflow.Chart.NonTerminalUnstableBehavior';

            maxSteps.Type = 'panel';
            maxSteps.RowSpan = [row row];
            maxSteps.ColSpan = [1 2];
            maxSteps.LayoutGrid = [1 2];
            maxSteps.ColStretch = [0 1];
            maxSteps.Items = {maxStepsL, maxStepsE, ntbl, ntbc};
            maxSteps.Tag = 'sfChartdlg_panel';
			maxSteps.Enabled = editable;
        else
            maxSteps = [];
        end

    end

    function enableZC = enableZeroCrossingsUI(row)

        updateMethod = sf('get', h.Id, '.updateMethod');
        if isSFBasedChart && updateMethod == 2
            enableZC.Name = message('EnableZeroCrossings');
            enableZC.Type = 'checkbox';
            enableZC.ObjectProperty = 'EnableZeroCrossings';
            enableZC.Mode = 1;
            enableZC.RowSpan = [row row];
            enableZC.ColSpan = [1 3];
            enableZC.Tag = 'sfChartdlg_Enable zero-crossing detection';
            enableZC.Enabled = editable;
            enableZC.WidgetId = 'Stateflow.Chart.EnableZeroCrossings';
            enableZC.DialogRefresh = 1;


        else
            enableZC = [];
        end
        
    end

    function derivName_edit = derivativesFormatStringUI(row)

        if isSFBasedChart && is_plant_model_chart(h.Id) && false
            derivName_edit.Name = message('DerivativesFormatString');
            derivName_edit.Type = 'edit';
            derivName_edit.RowSpan = [row, row];
            derivName_edit.ColSpan = [1 3];
            derivName_edit.ObjectProperty = 'DerivativesFormatString';
            derivName_edit.Mode = 1;
            derivName_edit.DialogRefresh = 1;
            derivName_edit.Enabled = editable;
            derivName_edit.WidgetId = 'Stateflow.Chart.DerivativesFormatString';

        else
            derivName_edit = [];
        end
        
    end
 
%------------------------------------------------------------------------------
    function G = bitopsUI(row)

        if isSFBasedChart

            %Enable check box
            enable.Name = message('EnableBitOps');
            enable.Type = 'checkbox';
            enable.ObjectProperty = 'EnableBitOps';
            enable.Mode = 1;
            enable.RowSpan = [row row];
            enable.ColSpan = [1 3];
            enable.Tag = 'sfChartdlg_Enable C-bit operations';
            enable.Enabled = editable;
            enable.WidgetId = 'Stateflow.Chart.EnableBitOps';

            G = enable;
        else
            G = [];
        end
    end
%------------------------------------------------------------------------------
    function U = execOrderUI(row)

        if isSFBasedChart
            % Execorder
            execOrder.Name = message('UserSpecifiedStateTransitionExecutionOrder');
            execOrder.RowSpan = [row row];
            execOrder.ColSpan = [1 1];
            execOrder.Type = 'checkbox';
            execOrder.ObjectProperty = 'UserSpecifiedStateTransitionExecutionOrder';
            execOrder.Tag = 'sfChartdlg_User specified state/transition execution order';
            execOrder.Enabled = editable;
            execOrder.WidgetId = 'Stateflow.Chart.UserSpecifiedStateTransitionExecutionOrder';
            U = execOrder;
        else
            U = [];
        end

    end

%------------------------------------------------------------------------------
    function U = exportChartUI(row)

        if isSFBasedChart
            %exportChart check box
            exportChart.Name = message('ExportChartFunctions');
            exportChart.RowSpan = [row row];
            exportChart.ColSpan = [1 1];
            exportChart.Type = 'checkbox';
            exportChart.ObjectProperty = 'ExportChartFunctions';
            exportChart.Tag = 'sfChartdlg_Export Chart Level Graphical Functions (Make Global)';
                      
            if isMooreChart(h)
                h.ExportChartFunctions = false;                
                exportChart.Enabled = 0;
            else
                exportChart.Enabled = editable;
            end
            
            exportChart.WidgetId = 'Stateflow.Chart.ExportChartFunctions';
            U = exportChart;
        else
            U = [];
        end

    end
%------------------------------------------------------------------------------
    function U = strongDataTypingUI(row)

        if isSFBasedChart
            %Strong Data check box
            strong.Name = message('StrongDataTypingWithSimulink');
            strong.RowSpan = [row row];
            strong.ColSpan = [1 1];
            strong.Type = 'checkbox';
            strong.ObjectProperty = 'StrongDataTypingWithSimulink';
            strong.Tag = 'sfChartdlg_Use Strong Data Typing with Simulink I/O';
            strong.Enabled = editable;
            strong.WidgetId = 'Stateflow.Chart.StrongDataTypingWithSimulink';
            U = strong;
        else
            U = [];
        end

    end
%------------------------------------------------------------------------------
    function U = executeAtInitializationUI(row)

        if isSFBasedChart
            %execute check box
            execute.Name = message('ExecuteAtInitialization');
            execute.RowSpan = [row row];
            execute.ColSpan = [1 1];
            execute.Type = 'checkbox';
            execute.ObjectProperty = 'ExecuteAtInitialization';
            execute.Tag = 'sfChartdlg_Execute (enter) Chart At Initialization';           
            execute.Mode = 1;
            if isMooreChart(h)
                execute.Enabled = 0;
            else
                execute.Enabled = editable;
            end
            
            execute.WidgetId = 'Stateflow.Chart.ExecuteAtInitialization';
            U = execute;
        else
            U = [];
        end

    end

%------------------------------------------------------------------------------
    function U = initializeOutputUI(row)

        if isSFBasedChart
            %execute check box
            initialize.Name = message('InitializeOutput');
            initialize.RowSpan = [row row];
            initialize.ColSpan = [1 1];
            initialize.Type = 'checkbox';
            initialize.ObjectProperty = 'InitializeOutput';
            initialize.Tag = 'sfChartdlg_Initialize Outputs Every Time Chart Wakes Up';
            initialize.Mode = 1;
            if isMooreChart(h) || isMealyChart(h)
                initialize.Enabled = 0;
            else
                initialize.Enabled = editable;
            end
            
            initialize.WidgetId = 'Stateflow.Chart.InitializeOutput';
            U = initialize;
        else
            U = [];
        end

    end

%------------------------------------------------------------------------------
    function U = debuggerPanelUI(row)

        if isSFBasedChart

            % Debugger widget
            debuggerLabel.Name = [message('DebuggerBreakpoint') ':'];
            debuggerLabel.Type = 'text';
            debuggerLabel.RowSpan = [1 1];
            debuggerLabel.ColSpan = [1 1];
            debuggerLabel.Tag = 'sfChartdlg_Debugger breakpoint:';

            % Debugger Checkbox
            debuggerCheck.Name = message('OnEntry');
            debuggerCheck.Type = 'checkbox';
            debuggerCheck.RowSpan = [1 1];
            debuggerCheck.ColSpan = [2 2];
            debuggerCheck.ObjectProperty = 'OnEntry';
            debuggerCheck.Tag = 'sfChartdlg_On chart entry';
            debuggerCheck.Enabled = editable;
            debuggerCheck.WidgetId = 'Stateflow.Chart.OnEntry';

            % pnlEntry panel
            pnlEntry.Type       = 'panel';
            pnlEntry.Source    = h.Debug.breakpoints;
            pnlEntry.RowSpan = [row row];
            pnlEntry.ColSpan = [1 2];
            pnlEntry.LayoutGrid = [1 2];
            pnlEntry.ColStretch = [0 1];
            pnlEntry.Items      = {debuggerLabel, debuggerCheck};
            pnlEntry.Tag = 'sfChartdlg_panel';

            U = pnlEntry;
        else
            U = [];
        end

    end
%------------------------------------------------------------------------------
    function editorCheck = pnlDebuggerAndEditUI(row)

        % Editor checkbox
        editorCheck.Name = message('Locked');
        editorCheck.Type = 'checkbox';
        editorCheck.RowSpan = [row row];
        editorCheck.ObjectProperty = 'Locked';
        editorCheck.Tag = 'sfChartdlg_Lock Editor';
        editorCheck.WidgetId = 'Stateflow.Chart.Locked';
        
        if isSFBasedChart
            editorCheck.ColSpan = [3 3];
        else
            editorCheck.ColSpan = [1 2];
        end

    end

%------------------------------------------------------------------------------
    function G = signalConversionUI(row)
        
        if isEMLBased
            G = eml_data_conversion_ddg(h,row,[1 3],false);
        else
            G = [];
        end

    end

%------------------------------------------------------------------------------
    function G = embeddedMatlabPropertiesUI(row)
        
       if isEMLBased
           G = eml_integer_overflow_ddg(row,[1 1]);
       else
           G = [];
       end

    end

%------------------------------------------------------------------------------
    function G = variableSizingUI(row)
        on = sf('IsVariableSizingFeatureON', isEMLBased);

        if ~on 
            G = [];
            return;
        end;

        % 'Support variable-size matrices' checkbox.

        G.Name = DAStudio.message('Stateflow:dialog:SupportVariableSizingName');
        G.Type = 'checkbox';

        G.ObjectProperty = 'supportVariableSizing';
        G.RowSpan = [row row];
        G.ColSpan = [1 3];      

        G.DialogRefresh = 1;
        G.Mode = 1;
    end

%------------------------------------------------------------------------------
    function description = descriptionUI(row)

        % description widget
        description.Name = [commonMessage('Description') ':'];
        description.Type = 'editarea';
        description.WordWrap = true;
        description.RowSpan = [row row];
        description.ColSpan = [1 3];
        description.ObjectProperty = 'Description';
        description.Tag = 'sfChartdlg_Description:';
        description.Enabled = editable;
        description.WidgetId = 'Stateflow.Chart.Description';
    end

%------------------------------------------------------------------------------
    function pnlDoc = panelDocUI(row)

        %Document hyperlink
        document.Name = [commonMessage('DocumentLink') ':'];
        document.RowSpan = [1 1];
        document.ColSpan = [1 1];
        document.Type = 'hyperlink';
        document.MatlabMethod = 'sf';
        document.Tag = 'documentHyperTag';
        document.MatlabArgs = {'Private', 'dlg_goto_document', h.Id};

        %Document edit area
        document1.Name = '';
        document1.RowSpan = [1 1];
        document1.ColSpan = [2 2];
        document1.Type = 'edit';
        document1.ObjectProperty = 'Document';
        document1.Tag = 'sfChartdlg_document';
        document1.Enabled = editable;
        document1.WidgetId = 'Stateflow.Chart.Document';

        pnlDoc.Type = 'panel';
        pnlDoc.LayoutGrid = [1 2];
        pnlDoc.RowSpan = [row row];
        pnlDoc.ColSpan = [1 3];
        pnlDoc.ColStretch = [0 1];
        pnlDoc.Items = {document, document1};

    end
end
%-------------------------------------------------------------------------------
% Construct the title of the dialog translated
% Parameters:
%   h - Handle to the state udi
%-------------------------------------------------------------------------------
function title = get_chart_title_l(h)
title = get_chart_title_prefix_l(h);
if strcmpi( title, 'Chart' )
    title = commonMessage( title );
else
    title = message( title );
end
title = [title ': ' get_chart_name_l(h)];
end

%--------------------------------------------------------------------------
% Construct the prefix to the title of the dialog untranslated
% Parameters:
%   h - Handle to the state udi
%--------------------------------------------------------------------------
function prefix = get_chart_title_prefix_l(h)
switch h.class
    case 'Stateflow.Chart'
        switch h.stateMachineType
            case 'Mealy'
                prefix = 'Mealy';
            case 'Moore'
                prefix = 'Moore';
            case 'Plant Model'
                prefix = 'PlantModel';
            otherwise
                prefix = 'Chart';
        end
    case 'Stateflow.EMChart'
        prefix = 'EMChart';
    case 'Stateflow.TruthTableChart'
        prefix = 'TruthTable';
    otherwise
        prefix = 'Unknown';
end    
end

%--------------------------------------------------------------------------
% Construct the dialog tag 
% Parameters:
%   h - Handle to the state udi
%--------------------------------------------------------------------------
function tag = get_chart_properties_tag(h)
tag = ['sfChartdlg_' get_chart_title_prefix_l(h)];
tag = [tag ': ' get_chart_name_l(h)];
end

%-------------------------------------------------------------------------------
% Construct the hyperlink string for the chart name
% Parameters:
%   h - Handle to the state udi
%-------------------------------------------------------------------------------
function name = get_chart_name_l(h)

name = h.Name;
name(regexp(name,'\s'))=' ';

end
%-------------------------------------------------------------------------------
% Construct the hyperlink string for the chart's parent name
% Parameters:
%   h - Handle to the state udi
%-------------------------------------------------------------------------------
function parentName = get_parent_name_l(h)

parent = sf('get',h.Id,'.machine');
[MACHINE,CHART,STATE] = sf('get','default','machine.isa','chart.isa','state.isa');
switch sf('get',parent,'.isa')
    case MACHINE
        parentName = commonMessage('LowerMachine');
    case CHART
        parentName = commonMessage('LowerChart');
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
        parentName = sprintf('(#%d) ',parent);
        warning('Stateflow:UnexpectedError','Bad parent type.'); 
end
parentName = sprintf('(%s) %s',parentName, sf('FullNameOf',parent,'.'));

end
%--------------------------------------------------------------------------
function mc = isMealyChart(h)

mc = strcmp(h.StateMachineType, 'Mealy');

end
%--------------------------------------------------------------------------
function mc = isMooreChart(h)

mc = strcmp(h.StateMachineType, 'Moore');

end

%--------------------------------------------------------------------------
function s = commonMessage(id,varargin)

s = DAStudio.message(['Stateflow:dialog:Common' id],varargin{:});

end

%--------------------------------------------------------------------------
function s = message(id,varargin)

s = DAStudio.message(['Stateflow:dialog:Chart' id],varargin{:});

end
