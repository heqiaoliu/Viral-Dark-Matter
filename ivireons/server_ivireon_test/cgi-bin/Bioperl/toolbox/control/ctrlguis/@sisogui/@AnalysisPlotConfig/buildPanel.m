function buildPanel(this)
% BUILDPANEL - Build the analysis plot configuration panel

%   Author(s): C. Buhr
%   Copyright 1986-2008 The MathWorks, Inc. 
%   $Revision: 1.1.8.5 $  $Date: 2008/12/04 22:21:54 $

import javax.swing.border.*;
import java.awt.*;

% Panels
MainPanel= javaObjectEDT('com.mathworks.mwswing.MJPanel',BorderLayout(10, 10)); % MainPanel

%% Create the panel
Panel = javaObjectEDT('com.mathworks.mwswing.MJPanel',false);
Panel.setLayout(BorderLayout(5,5));

%% Create the table panel
TablePanel = javaObjectEDT('com.mathworks.toolbox.control.sisogui.AnalysisPlotTablePanel');
Panel.add(TablePanel,BorderLayout.CENTER);

% Create the DesignPlotButton
TablePanel.addAnalysisPlotButton;
AnalysisPlotButton = javaObjectEDT(TablePanel.getAnalysisPlotButton);
h = handle(AnalysisPlotButton, 'callbackproperties' );
h.ActionPerformedCallback  = {@LocalAnalysisPlotButtonClicked this};

% Create the AddResponseButton
AddResponseButton = javaObjectEDT(TablePanel.getAddResponseButton);
h = handle(AddResponseButton, 'callbackproperties' );
h.ActionPerformedCallback  = {@LocalAddResponseButtonClicked this};

%% Add it to the frame
MainPanel.add(Panel,BorderLayout.CENTER);

%% Add a listener to the table model
h = handle(TablePanel.getPlotContentTableModel, 'callbackproperties' ); 
TableListener = handle.listener(h, 'tableChanged',{@LocalTableChanged this});

%% Add listeners to the comboboxes
ComboBoxes = javaObjectEDT(TablePanel.getPlotCombos);
for ct = length(ComboBoxes):-1:1
    h1(ct) = handle(ComboBoxes(ct), 'callbackproperties' ); 
    hListener(ct) = handle.listener(h1(ct), 'ActionPerformed', {@LocalUpdateViewer this}); 
end

this.Handles = struct('Panel', MainPanel, ...
                      'TablePanel', TablePanel, ...
                      'Listeners',hListener, ...
                      'TableListener',TableListener);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdateTable(this,loopdata)

%% Set the CETM to be blocked with a GlassPane
CETMFrame = slctrlexplorer;
javaMethodEDT('setBlocked', CETMFrame, false,[]);


%% Update the table with the new data
RespData = cell(this.Handles.TablePanel.getPlotContentTableModel.data);
RespData = [RespData;repmat({false},1,7),{loopdata.LoopView(end).Description}];
this.RespData = RespData;

%% Disable the table listener
listener = this.Handles.TableListener;
listener.Enabled = 'off';

%% Update the table.  Call drawnow since this is asynchronous.
this.Handles.TablePanel.UpdatePlotContentTable(RespData);
drawnow

%% Re-Enable the table listener
listener.Enabled = 'on';

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalAddResponseButtonClicked(es,ed,this)

%% Set the CETM to be blocked with a GlassPane
CETMFrame = slctrlexplorer;
javaMethodEDT('setBlocked', CETMFrame, true,[]);


%% Get the loopdata
loopdata = this.SISODB.LoopData;

%% Set the updatefcn
updatefcn = {@LocalUpdateTable,this,loopdata};

%% Determine if the sisotool is being used for Simulink or MATLAB control
%% design.
if (loopdata.getconfig == 0);
    %% Create the dialog
    jDialogs.SelectAnalysisResponseDlg(updatefcn,loopdata,CETMFrame);
else
    %% Create the dialog
    sisogui.SelectAnalysisResponseDlg(updatefcn,loopdata,CETMFrame);
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalAnalysisPlotButtonClicked(es,ed,this)
this.showViewer;
% if isa(this.SISODB.AnalysisView.Figure,'figure')
%     figure(double(this.SISODB.AnalysisView.Figure));
% end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdateViewer(es,ed,this)
this.updateViewer;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalTableChanged(es,ed,this)

% Block explorer to prevent multiple tablechanged events when a user
% clicks faster than ltiviewer can update
F=slctrlexplorer;
javaMethodEDT('setBlocked', F, true,[]);

row = ed.JavaEvent.getFirstRow;
col = ed.JavaEvent.getColumn;
AnalysisPlotTableModel = this.Handles.TablePanel.getPlotContentTableModel;

%% Disable the table model listener since the table data will be updated
this.Handles.TableListener.Enabled = 'off';

%% Update the table data
data = cell(AnalysisPlotTableModel.data);

if col ~= -1
    if col == 6
        val = data{row+1,col+1};
        data(row+1,1:6) = repmat({val},1,6);
    else
        data{row+1,7} = false;
    end
end

this.Handles.TablePanel.UpdatePlotContentTable(data);
this.RespData = data;
drawnow
%% Enable the table model listener
this.Handles.TableListener.Enabled = 'on';

this.updateViewer;

javaMethodEDT('setBlocked', F, false,[]);


