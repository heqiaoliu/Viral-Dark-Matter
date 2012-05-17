function DialogPanel = getDialogSchema(this, manager)
%  BUILD  Construct the dialog panel

%  Author(s): John Glass
%  Revised:
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.28 $ $Date: 2009/03/31 00:23:00 $

% Add the settings pane to the frame
isResultSelectorEnabled = length(this.getChildren) > 1;
isDiagnosticsEnabled = ~isempty(this.DiagnosticMessages);

if ~isempty(this.InspectorNode)
    node = this.InspectorNode;
    
    DialogPanel = edtObject('com.mathworks.toolbox.slcontrol.GenericLinearizationObjects.AnalysisResultsPanel',...
                                node.getTreeNodeInterface,isResultSelectorEnabled);
    
    % Get the explorer panel
    panel = DialogPanel.getLinearizationInspectPanel;
    this.Handles.ExplorerTreeManager = explorer.ExplorerPanelTreeManager(node,panel);
    ExplorerTree = this.Handles.ExplorerTreeManager.ExplorerPanel.getExplorerTree;
    ExplorerTree.setName('LinearizationInspectorTreeName');
else
    DialogPanel = edtObject('com.mathworks.toolbox.slcontrol.GenericLinearizationObjects.AnalysisResultsPanel',isResultSelectorEnabled,isDiagnosticsEnabled);
end
this.Dialog = DialogPanel;

if isDiagnosticsEnabled
    % Get the Java handle
    DiagnosticsSummaryArea = DialogPanel.getLinearAnalysisDiagnosticsPanel.getSummaryArea;
    this.Handles.DiagnosticsSummaryArea = DiagnosticsSummaryArea;
    h = handle(DiagnosticsSummaryArea.getEditor, 'callbackproperties');
    h.HyperlinkUpdateCallback = {@LocalEvaluateHyperlinkUpdate, this};

    % Set the diagnostics filter selector callback
    SelectorCallback = DialogPanel.getLinearAnalysisDiagnosticsPanel.getSelectorComboCallback;
    h = handle(SelectorCallback,'callbackproperties');
    h.DelayedCallback = {@LocalDiagnosticSelectorCallback, this};

    % Store the Diagnostics Panel
    this.Handles.DiagnosticsPanel = DialogPanel.getLinearAnalysisDiagnosticsPanel;
    % Set the data
    updateDiagnosticsSummary(this);
end

if isResultSelectorEnabled
    % Selector ComboBox
    % Get the selected system combobox
    SelectorCombo = DialogPanel.getSelectorCombo;
    % Set the data model for the combobox
    SelectorCombo.setModel(this.getAnalysisResultsComboModel);
    this.Handles.SelectorCombo = SelectorCombo;
    % Set the data model for the combobox
    SelectorCombo.setModel(this.getAnalysisResultsComboModel);
    h = handle(SelectorCombo, 'callbackproperties');
    h.ActionPerformedCallback = {@LocalSelectorComboCallback,this};
end

% SummaryArea Text Area
% Get the Java handle
SummaryArea = DialogPanel.getLinearAnalysisSummaryPanel.getSummaryArea;
this.Handles.SummaryArea = SummaryArea;
h = handle(SummaryArea.getEditor, 'callbackproperties');
h.HyperlinkUpdateCallback = {@LocalEvaluateHyperlinkUpdate, this};

% Set the data
updateResultSummary(this);

% LTI Plot type combobox
% Get the Java handle
h = handle(DialogPanel.getLinearAnalysisSummaryPanel.getLTITypeCombo,...
                'callbackproperties');
h.ActionPerformedCallback = {@LocalUpdateResultSummary,this};
    
% Export model button
ExportButton = DialogPanel.getLinearAnalysisSummaryPanel.getExportButton;

% Set the callback
h = handle(ExportButton, 'callbackproperties');
h.ActionPerformedCallback = {@LocalExportAction,this};

% Configure a listener to the label changed event
this.addListeners(handle.listener(this,this.findprop('Label'),'PropertyPostSet',...
                        {@LocalLabelChanged,this}));

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   LOCAL FUNCTIONS

%% LocalLabelChanged
function LocalLabelChanged(es,ed,this)
% Get the parent node
parent = this.up;
if isa(parent,'ModelLinearizationNodes.ModelLinearizationSettings') ||...
        isa(parent,'BlockLinearizationNodes.BlockLinearizationSettings')
    %% Get all the analysis results
    ch = parent.getChildren;
    row = find(this == ch);
    eventData = ctrluis.dataevent(parent,'AnalysisLabelChanged',row);
    send(parent, 'AnalysisLabelChanged', eventData);
end

%% LocalDiagnosticSelectorCallback
function LocalDiagnosticSelectorCallback(es,ed,this)

updateDiagnosticsSummary(this);

%% LocalUpdateResultSummary
function LocalUpdateResultSummary(es,ed,this)

updateResultSummary(this)

%% LocalEvaluateHyperlinkUpdate
function LocalEvaluateHyperlinkUpdate(hSrc, hData,this)

% Evaluate the hyperlink
if strcmp(hData.getEventType.toString, 'ACTIVATED')
    Description = char(hData.getDescription);
    typeind = findstr(Description,':');
    identifier = Description(1:typeind(1)-1);
    switch identifier;
        case 'HighlightDiagnostic'
            diagnostictype = Description(typeind(1)+1:end);
            HiliteDiagBlocks(this,diagnostictype);
        case 'matlab'
            eval(Description(typeind+1:end))
        otherwise
            evalBlockSignalHyperLink(slcontrol.Utilities,hSrc,hData,this.Model);
    end
end

%% LocalSelectorComboCallback - Callback for the linearization selector combobox
function LocalSelectorComboCallback(es,ed,this)

% Get the inspector panel
panel = this.Dialog.getLinearizationInspectPanel;

if ~isempty(panel)
    % Get the selected node and update the block data
    selected = getSelected(panel);

    % Get the operating point combobox element
    combo_index = this.Dialog.getSelectedModelIndex;
    
    % Get the selected node
    node = handle(getObject(selected));
    
    % Update the block information depending on the linearization combo box
    for ct = 1:numel(node.Blocks)
        updateData(node.Blocks(ct),this.ModelJacobian(combo_index));
    end

    % Get the handle to the panel
    hout = slctrlguis.linearizationpanels.getBlockExplorePanel;
    updateSummary(hout);
end

% Update the results summary
updateResultSummary(this);

%% LocalExportAction - Callback for the export analysis button
function LocalExportAction(es,ed,this)

this.exportToWorkspace;
