function buildPanel(this)
% BUILDPANEL - Build the design plot configuration panel

%   Author(s): C. Buhr
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.9 $  $Date: 2008/12/04 22:22:03 $

import javax.swing.border.*;
import javax.swing.*;
import java.awt.*;
import com.mathworks.toolbox.control.sisogui.*;

% Build the main panel
DesignPlotsPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel', ...
    BorderLayout(0, 10)); % MainPanel

% Build the Plot Selection Panel
ConfigurePlotsPanel =  javaObjectEDT('com.mathworks.mwswing.MJPanel', ...
    BorderLayout(0, 10)); % Configure Design Plots
title = javaMethodEDT('createTitledBorder', 'javax.swing.BorderFactory', ...
    sprintf('Design plots configuration'));
javaObjectEDT(title);
ConfigurePlotsPanel.setBorder(title);
DesignPlotsPanel.add(ConfigurePlotsPanel, BorderLayout.CENTER);

% Determine the entries that are open loop
tunedloops = this.SISODB.LoopData.L;
FeedbackFlag = get(tunedloops,{'Feedback'});
isOpenLoop = [FeedbackFlag{:}];

if isempty(isOpenLoop);
    isOpenLoop = true;
end
 
% Create the table panel
TablePanel = javaObjectEDT('com.mathworks.toolbox.control.sisogui.EditorViewTablePanel', ...
    this.DesignViewsTableData,this.TunedLoopTableData(:,1),isOpenLoop);

% Configure the show design plot button
TablePanel.addDesignPlotButton;
DesignPlotButton = javaObjectEDT(TablePanel.getDesignPlotButton);
h = handle(DesignPlotButton, 'callbackproperties' );
h.ActionPerformedCallback  = {@LocalDesignPlotButtonClicked,this};

% Configure the SelectNewLoopButton
SelectNewLoopButton = javaObjectEDT(TablePanel.getSelectNewLoopButton);
h = handle(SelectNewLoopButton, 'callbackproperties' );
h.ActionPerformedCallback  = {@LocalSelectNewLoopButtonClicked,this};

ConfigurePlotsPanel.add(TablePanel,BorderLayout.CENTER);
TunedLoopTableDataJava = matlab2java(slcontrol.Utilities,this.TunedLoopTableData);
javaMethodEDT('setSummaryTableData',TablePanel,TunedLoopTableDataJava,isOpenLoop);

% Create the callbacks
SummaryTableModel = TablePanel.getSummaryTableModel;
MATLABSummaryTableModel = handle(SummaryTableModel,'callbackproperties');
MATLABSummaryTableModelListener = handle.listener(MATLABSummaryTableModel,...
                            'tableChanged',{@LocalSummaryTableModelCallback,this});

this.Handles = struct('Panel', DesignPlotsPanel, ...
                      'TablePanel', TablePanel, ...
                      'TableModel', TablePanel.getViewTableModel, ...
                      'MATLABSummaryTableModelListener',MATLABSummaryTableModelListener);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Local Functions
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalSummaryTableModelCallback(es,ed,this)

if ~isempty(this.SISODB.LoopData.L) && (this.Handles.TablePanel.getSummaryTable.getSelectedColumn ~= -1)
    % Get the selected row
    row = ed.JavaEvent.getFirstRow;
    value = es.getValueAt(row,0);
    
    % Check if new string value is unique
    isInvalidChange = isempty(value) || any(strcmp(value,get(this.SISODB.LoopData.L(1:end~=(row+1)), {'Name'})));
    if isInvalidChange
        % Show Error Message
        awtinvoke('com.mathworks.mwswing.MJOptionPane', ...
            'showMessageDialog(Ljava/awt/Component;Ljava/lang/Object;Ljava/lang/String;I)', ...
            slctrlexplorer, xlate('The loop names must be unique and nonempty.'), ...
            xlate('SISO Design Task'), com.mathworks.mwswing.MJOptionPane.ERROR_MESSAGE);
        LoopName = java.lang.String(this.SISODB.LoopData.L(row+1).Name);
        awtinvoke(java(es),'setValueAt(Ljava/lang/Object;II)',LoopName,row,0);
    else
        % Set the new value in the LoopData object
        this.SISODB.LoopData.L(row+1).Name = value;

        % Get the table panel
        TablePanel = this.Handles.TablePanel;
        AvailableLoops = cell(TablePanel.getAvailableLoops);
        oldvalue = AvailableLoops{row+1};

        % Get the new list of available loops
        AvailableLoops{row+1} = value;
        AvailableLoopJava = matlab2java1d(slcontrol.Utilities,AvailableLoops,'java.lang.String');

        % Set the view table data to account for the name changes
        ViewTableData = cell(TablePanel.getViewTableData);
        ind = find(strcmp(ViewTableData(:,2),oldvalue));
        if ~isempty(ind)
            ViewTableData(ind,2) = repmat({value},size(ind));
        end
        ViewTableDataJava = matlab2java(slcontrol.Utilities,ViewTableData);
        javaMethodEDT('setViewTableData',TablePanel,ViewTableDataJava,AvailableLoopJava);
      
        % Send the config changed event
        this.SISODB.LoopData.send('ConfigChanged')
    end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdateLoops(this)

% Set the CETM to be blocked with a GlassPane
CETMFrame = slctrlexplorer;
CETMFrame.setBlocked(false,[])

% Disable the table model listener
this.Handles.MATLABSummaryTableModelListener.Enabled = 'off';

% Display
this.setTunedLoopTableData;

% Disable the table model listener
drawnow
this.Handles.MATLABSummaryTableModelListener.Enabled = 'on';

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalSelectNewLoopButtonClicked(es,ed,this)

% Set the CETM to be blocked with a GlassPane
CETMFrame = slctrlexplorer;
CETMFrame.setBlocked(true,[])

% Get the loopdata
loopdata = this.SISODB.LoopData;

% Set the updatefcn
updatefcn = {@LocalUpdateLoops,this};

if (loopdata.getconfig == 0);
    % Get the currently selected node in the CETM
    selectednode = handle(getObject(getSelected(slctrlexplorer)));
    % Create the dialog
    jDialogs.SelectNewLoopDlg(updatefcn,loopdata,CETMFrame,selectednode);
else
    % Create the dialog
    sisogui.SelectNewLoopDlg(updatefcn,loopdata,CETMFrame);
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalDesignPlotButtonClicked(es,ed,this)

if isa(this.SISODB.Figure,'figure')
    doUpdate = strcmp(get(this.SISODB.Figure,'Visible'),'off');
    figure(double(this.SISODB.Figure));
    
    if doUpdate
        isActive = strcmp(get(this.SISODB.PlotEditors,'Visible'),'on');
        ActivePlotEditors = find(isActive);
        NumActive = length(ActivePlotEditors);
        for ct = 1:NumActive
            this.SISODB.PlotEditors(ActivePlotEditors(ct)).updateview;
        end
    end
end
