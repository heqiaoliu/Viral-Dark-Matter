function buildPanel(this)

%   Author(s): C. Buhr
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.7 $  $Date: 2009/08/08 01:09:10 $

import javax.swing.border.*;
import javax.swing.*;
import java.awt.*;

TaskMainPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel',BorderLayout(0, 10));
TaskTabbedPane = javaObjectEDT('com.mathworks.mwswing.MJTabbedPane',1);
TaskTabbedPane.setName('TaskTabbedPane');
TaskMainPanel.add(TaskTabbedPane,BorderLayout.CENTER);

%%
ArchitectureTab = javaObjectEDT('com.mathworks.mwswing.MJPanel',BorderLayout(0, 10));
ArchitectureTab.setName('ArchitectureTab');
TaskTabbedPane.addTab(sprintf('Architecture'), ArchitectureTab);

%%
ManualTuningTab = javaObjectEDT('com.mathworks.mwswing.MJPanel',BorderLayout(0, 10));
ManualTuningTab.setName('PZEditorTab');
TaskTabbedPane.addTab(sprintf('Compensator Editor'), ManualTuningTab);

%%
DesignPlotsTab = javaObjectEDT('com.mathworks.mwswing.MJPanel',BorderLayout(0, 10));
DesignPlotsTab.setName('DesignPlotsTab');
TaskTabbedPane.addTab(sprintf('Graphical Tuning'), DesignPlotsTab);

%%
AnalysisPlotsTab = javaObjectEDT('com.mathworks.mwswing.MJPanel',BorderLayout(0, 10));
AnalysisPlotsTab.setName('AnalysisPlotsTab');
TaskTabbedPane.addTab(sprintf('Analysis Plots'), AnalysisPlotsTab);

%%
AutomatedTuningTab = javaObjectEDT('com.mathworks.mwswing.MJPanel',BorderLayout(0, 10));
AutomatedTuningTab.setName('AutomatedTuningTab');
TaskTabbedPane.addTab(sprintf('Automated Tuning'), AutomatedTuningTab);

% listen for change in tab
h = handle(TaskTabbedPane, 'callbackproperties' );
h.StateChangedCallback = {@LocalRefreshTab, this};

% reset the minimal size of the tab panel
TaskMainPanel.setMinimumSize(java.awt.Dimension(200,380));

this.Handles = struct('TaskMainPanel', TaskMainPanel, ...
                      'TaskTabbedPane', TaskTabbedPane, ...
                      'ArchitectureTab', ArchitectureTab, ...
                      'DesignPlotsTab', DesignPlotsTab, ...
                      'AnalysisPlotsTab', AnalysisPlotsTab, ...
                      'ManualTuningTab', ManualTuningTab, ...
                      'AutomatedTuningTab', AutomatedTuningTab);

%% Initialize the panels
this.refreshArchitecture;
this.refreshManualTuning;
this.refreshDesignPlot;
this.refreshAnalysisPlot;
this.refreshAutomatedTuning;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalRefreshTab
function LocalRefreshTab(es,ed,this)

if ishandle(this)
    refreshTab(this)
end