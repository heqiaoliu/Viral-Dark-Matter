function this = SelectDesignViewsPanel(wizard)
% SELECTDESIGNVIEWSPANEL  Build the SISOTOOLView configuration
%
 
% Author(s): John W. Glass 10-Aug-2005
%   Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/12/04 23:27:56 $

this = jDialogs.SelectDesignViewsPanel;
this.wizard = wizard;

% Get the useful data
loopdata = wizard.loopdata;

% Create the panel
Panel = javaObjectEDT('com.mathworks.mwswing.MJPanel',false);
etchtype = javaObjectEDT('javax.swing.border.EtchedBorder');
loweredetched = javaMethodEDT('createEtchedBorder',...
    'javax.swing.BorderFactory',etchtype.LOWERED);
title = javaMethodEDT('createTitledBorder',...
            'javax.swing.BorderFactory',loweredetched, ...
                xlate('Step 1 of 2: Select the SISOTOOL Design Views'));
Panel.setBorder(title);
BorderLayout = javaObjectEDT('java.awt.BorderLayout',5,5);
Panel.setLayout(BorderLayout);

% Create the initial table data
if isempty(loopdata.L)
    Loop1 = 'None';
else
    Loop1 = loopdata.L(1).Name;
end

TableData = {'Plot 1',Loop1,'None';...
             'Plot 2',Loop1,'None';...
             'Plot 3',Loop1,'None';...
             'Plot 4',Loop1,'None';...
             'Plot 5',Loop1,'None';...
             'Plot 6',Loop1,'None'};

% Specify the choices of loops to view
FeedbackFlag = get(loopdata.L,{'Feedback'});
isOpenLoop = [FeedbackFlag{:}];
if isempty(isOpenLoop)
    isOpenLoop = true;
end

% Create the table panel
TablePanel = javaObjectEDT('com.mathworks.toolbox.control.sisogui.EditorViewTablePanel',...
                TableData,{'None'},isOpenLoop);
Panel.add(TablePanel,BorderLayout.CENTER);

% Store the data
this.Panel = Panel;
this.Handles.SelectSISOTOOLViews.TablePanel = TablePanel;

% Create the callbacks
updatefcn = {@LocalUpdateFcn,this};
NewLoopButton = TablePanel.getSelectNewLoopButton;
h = handle(NewLoopButton,'callbackproperties');
h.ActionPerformedCallback = {@LocalNewLoopFcn,this, updatefcn};                                

SummaryTableModel = TablePanel.getSummaryTableModel;
MATLABSummaryTableModel = handle(SummaryTableModel,'callbackproperties');
MATLABSummaryTableModelListener = handle.listener(MATLABSummaryTableModel,...
                            'tableChanged',{@LocalSummaryTableModelCallback,this});
this.Handles.SelectSISOTOOLViews.MATLABSummaryTableModelListener = MATLABSummaryTableModelListener;

% Update the data
LocalUpdateFcn(this);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Local Functions
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalNewLoopFcn(es,ed,this,updatefcn)

WizardFrame = this.wizard.Handles.Frame;
GlassPane = WizardFrame.getGlassPane;
javaMethodEDT('setVisible',GlassPane,true);
jDialogs.SelectNewLoopDlg(updatefcn,this.wizard.loopdata,WizardFrame,this.wizard.SISOTaskNode);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalSummaryTableModelCallback(es,ed,this)

% Get the selected row 
row = ed.JavaEvent.getFirstRow;
value = es.getValueAt(row,0);

% Set the new value in the LoopData object
this.wizard.loopdata.L(row+1).Name = value;

% Get the table panel
TablePanel = this.Handles.SelectSISOTOOLViews.TablePanel;
AvailableLoops = cell(TablePanel.getAvailableLoops);
oldvalue = AvailableLoops{row+1}; 

% Set the new list of available loops
AvailableLoops{row+1} = value;
AvailableLoopsJava = matlab2java1d(slcontrol.Utilities,AvailableLoops,'java.lang.String');

% Set the view table data to account for the name changes
ViewTableData = cell(TablePanel.getViewTableModel.data);
ind = find(strcmp(ViewTableData(:,2),oldvalue));
if ~isempty(ind)
    ViewTableData(ind,2) = repmat({value},size(ind));
end
ViewTableDataJava = matlab2java(slcontrol.Utilities,ViewTableData);
javaMethodEDT('setViewTableData',TablePanel,ViewTableDataJava,AvailableLoopsJava);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdateFcn(this)

% Get the table panel
TablePanel = this.Handles.SelectSISOTOOLViews.TablePanel;

% Determine the entries that are open loop
loopdata = this.wizard.loopdata;
tunedloops = loopdata.L;
nloops = length(tunedloops);

% Update the summary table.  This will update the available loop
% comboboxes.
if nloops ~= 0
    FeedbackFlag = get(loopdata.L,{'Feedback'});
    isOpenLoop = [FeedbackFlag{:}];
    
    % Update the view table data to include the first loop if there are
    % not any initial loops
    ViewTableData = cell(this.Handles.SelectSISOTOOLViews.TablePanel.getViewTableModel.data);
    if any(strcmp(ViewTableData(:,2),'None'))
        for ct = 1:6
            ViewTableData{ct,2} = loopdata.L(1).Name;
        end
    end
    
    % Get the existing available loops
    for ct = numel(tunedloops):-1:1
        AvailableLoops{ct} = loopdata.L(ct).Name;
    end
    AvailableLoopsJava = matlab2java1d(slcontrol.Utilities,AvailableLoops,'java.lang.String');
    ViewTableDataJava = matlab2java(slcontrol.Utilities,ViewTableData);
    % Create the summary table data
    SummaryTableData = cell(nloops,2);
    for ct = 1:numel(isOpenLoop)
        SummaryTableData{ct,1} = tunedloops(ct).Name;
        SummaryTableData{ct,2} = tunedloops(ct).Description;
    end
    this.Handles.SelectSISOTOOLViews.MATLABSummaryTableModelListener.Enabled = 'off';
    SummaryTableDataJava = matlab2java(slcontrol.Utilities,SummaryTableData);
    % Send the data over to Java in one shot
    javaMethodEDT('setTableData',TablePanel,ViewTableDataJava,AvailableLoopsJava,SummaryTableDataJava,isOpenLoop);

    drawnow;
    this.Handles.SelectSISOTOOLViews.MATLABSummaryTableModelListener.Enabled = 'on';
else
    javaMethodEDT('setEnabled',TablePanel.getViewTable,false)    
end
