function this = SelectAnalysisPlotsPanel(wizard)
% BUILDSELECTANALYSISPLOTS  Constructor to create the build select analysis
% plots panel
%
 
% Author(s): John W. Glass 08-Sep-2005
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/12/04 23:27:51 $

this = jDialogs.SelectAnalysisPlotsPanel;
this.wizard = wizard;

% Create the panel
Panel = javaObjectEDT('com.mathworks.mwswing.MJPanel',false);
etchtype = javaObjectEDT('javax.swing.border.EtchedBorder');
loweredetched = javaMethodEDT('createEtchedBorder',...
    'javax.swing.BorderFactory',etchtype.LOWERED);
title = javaMethodEDT('createTitledBorder',...
            'javax.swing.BorderFactory',loweredetched, ...
                xlate('Step 2 of 2: Select Analysis Plots'));
Panel.setBorder(title);
BorderLayout = javaObjectEDT('java.awt.BorderLayout',5,5);
Panel.setLayout(BorderLayout);
this.Panel = Panel;

% Create the table panel
TablePanel = javaObjectEDT('com.mathworks.toolbox.control.sisogui.AnalysisPlotTablePanel');
Panel.add(TablePanel,BorderLayout.CENTER);

% Get the handle to the table
AnalysisPlotTableModel = TablePanel.getPlotContentTableModel;
MATLABAnalysisPlotTableModel = handle(AnalysisPlotTableModel,'callbackproperties');
MATLABAnalysisPlotTableModelListener = handle.listener(MATLABAnalysisPlotTableModel,...
                            'tableChanged',{@LocalAnalysisPlotTableModelCallback,this});

% Store the data
this.Handles.SelectAnalysisPlotsPanel.TablePanel = TablePanel;
this.Handles.SelectAnalysisPlotsPanel.AnalysisPlotTableModel = AnalysisPlotTableModel;
this.Handles.SelectAnalysisPlotsPanel.MATLABAnalysisPlotTableModelListener = MATLABAnalysisPlotTableModelListener;

% Create the callbacks
updatefcn = {@LocalUpdateFcn,this};
AddResponseButton = TablePanel.getAddResponseButton;
h = handle(AddResponseButton,'callbackproperties');
h.ActionPerformedCallback = {@LocalAddResponseFcn,this,updatefcn};                                

% Update the data
LocalUpdateFcn(this);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalAnalysisPlotTableModelCallback(es,ed,this)

row = ed.JavaEvent.getFirstRow;
col = ed.JavaEvent.getColumn;
AnalysisPlotTableModel = this.Handles.SelectAnalysisPlotsPanel.AnalysisPlotTableModel;
MATLABAnalysisPlotTableModelListener = this.Handles.SelectAnalysisPlotsPanel.MATLABAnalysisPlotTableModelListener;

% Disable the table model listener since the table data will be updated
MATLABAnalysisPlotTableModelListener.Enabled = 'off';

% Update the table data
data = cell(AnalysisPlotTableModel.data);

if col ~= -1
    if col == 6
        val = data{row+1,col+1};
        data(row+1,1:6) = repmat({val},1,6);
    else
        data{row+1,7} = false;
    end
end

this.Handles.SelectAnalysisPlotsPanel.TablePanel.UpdatePlotContentTable(data);
drawnow
% Enable the table model listener
MATLABAnalysisPlotTableModelListener.Enabled = 'on';

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalAddResponseFcn(es,ed,this,updatefcn)

WizardFrame = this.wizard.Handles.Frame;
GlassPane = WizardFrame.getGlassPane;
javaMethodEDT('setVisible',GlassPane,true);
% Create the dialog
jDialogs.SelectAnalysisResponseDlg(updatefcn,this.wizard.loopdata,WizardFrame);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdateFcn(this)

% Get the old data
TablePanel = this.Handles.SelectAnalysisPlotsPanel.TablePanel;
olddata = cell(TablePanel.getPlotContentTableModel.data);

% Initialize the checkbox data to logical false
LoopView = this.wizard.loopdata.LoopView;
data(:,1:7) = repmat({false},numel(LoopView),7);
for ct = 1:length(LoopView)
    data{ct,8} = LoopView(ct).Description;
    %% Find the old checkbox state
    if ~isempty(olddata)
        ind = find(strcmp(LoopView(ct).Description,olddata(:,8)));
        if ~isempty(ind)
            data(ct,1:7) = olddata(ind,1:7);
        end
    end
end
    
% Disable the table model listener since the table data will be updated
MATLABAnalysisPlotTableModelListener.Enabled = 'off';
this.Handles.SelectAnalysisPlotsPanel.TablePanel.UpdatePlotContentTable(data);
drawnow
% Enable the table model listener
MATLABAnalysisPlotTableModelListener.Enabled = 'on';