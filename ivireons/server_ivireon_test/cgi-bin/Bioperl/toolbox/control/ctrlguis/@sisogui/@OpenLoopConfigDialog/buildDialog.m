function Frame = buildDialog(this)
%buildDialog  Builds the open loop configuration dialog

%   Author(s): C. Buhr
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.8 $  $Date: 2008/12/04 22:22:25 $

import java.awt.*;
import javax.swing.*;
import com.mathworks.toolbox.control.sisogui.*;
import com.mathworks.toolbox.control.tableclasses.*;

% Tuned Loop data
L = this.FeedbackLoops;
Configuration = this.LoopData.getconfig;

% LoopNames
for ct = length(L):-1:1
    LoopNames{ct} = sprintf('%s', L(ct).Description);
end

% Create Frame for dialog
Frame = javaObjectEDT('com.mathworks.mwswing.MJDialog',slctrlexplorer);
Frame.setTitle(sprintf('Open-Loop Configuration Dialog'));
Frame.setName('MainFrame');

%% Main Panel
MainPanel =  javaObjectEDT('com.mathworks.mwswing.MJPanel',BorderLayout(10,10));

%% Loop SelectPanel
LoopSelectPanel =  javaObjectEDT('com.mathworks.mwswing.MJPanel',BorderLayout(10,10));

LoopSelectLabel = javaObjectEDT('com.mathworks.mwswing.MJLabel',sprintf('Open-loop configuration for: '));
LoopSelectComboBox = javaObjectEDT('com.mathworks.mwswing.MJComboBox',LoopNames);
h = handle(LoopSelectComboBox,'callbackproperties' ); 
Listeners =  handle.listener(h,'ActionPerformed',{@LocalUpdateTarget, this}); 

LoopSelectPanel.add(LoopSelectLabel,BorderLayout.WEST);
LoopSelectPanel.add(LoopSelectComboBox,BorderLayout.CENTER);

%% LoopConfigurePanel
LoopConfigurePanel =  javaObjectEDT('com.mathworks.mwswing.MJPanel',BorderLayout(10,10));

% Label
LoopConfigLabel = javaObjectEDT('com.mathworks.mwswing.MJLabel', ...
    sprintf('Pick signal openings for the selected open-loop.'));

% Table
if isequal(this.LoopData.getconfig,0)
    TableModel = BasicTableModel({true,'a','b'},{sprintf('Open'),sprintf('Output of Block'),sprintf('Port')});
    EditableColumns = javaArray('java.lang.Boolean',3);
    EditableColumns(1) = java.lang.Boolean(true);
    EditableColumns(2) = java.lang.Boolean(false);
    EditableColumns(3) = java.lang.Boolean(false);
    TableModel.Editablecolumns=EditableColumns;
    LoopConfigTable = javaObjectEDT('com.mathworks.mwswing.MJTable');
    LoopConfigTable.setModel(TableModel);
    TableModel.clearRows;
    columnModel = LoopConfigTable.getColumnModel;
    column1 = columnModel.getColumn(0);
    column1.setPreferredWidth(10);
    column2 = columnModel.getColumn(1);
    column2.setPreferredWidth(500);
    column3 = columnModel.getColumn(2);
    column3.setPreferredWidth(10);
else
    TableModel = BasicTableModel({true,'a'},{sprintf('Open'),sprintf('Output of Block')});
    EditableColumns = javaArray('java.lang.Boolean',2);
    EditableColumns(1) = java.lang.Boolean(true);
    EditableColumns(2) = java.lang.Boolean(false);
    TableModel.Editablecolumns=EditableColumns;
    LoopConfigTable = javaObjectEDT('com.mathworks.mwswing.MJTable');
    LoopConfigTable.setModel(TableModel);
    TableModel.clearRows;
    columnModel = LoopConfigTable.getColumnModel;
    column1 = columnModel.getColumn(0);
    column1.setPreferredWidth(10);
    column2 = columnModel.getColumn(1);
    column2.setPreferredWidth(500);
end
awtinvoke(LoopConfigTable,'setPreferredScrollableViewportSize',Dimension(350, 150));
ScrollPane = javaObjectEDT('com.mathworks.mwswing.MJScrollPane',LoopConfigTable);

h = handle(TableModel, 'callbackproperties' ); 
hListener = handle.listener(h, 'tableChanged',{@LocalUpdateData this});

% Buttons
LoopConfigBtnPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel',FlowLayout(FlowLayout.RIGHT));

if Configuration == 0
    NewLoopOpeningBtn =  javaObjectEDT('com.mathworks.mwswing.MJButton',sprintf('Select a new loop opening ...'));
    NewLoopOpeningBtn.setName('NewLoopOpeningBtn');
    LoopConfigBtnPanel.add(NewLoopOpeningBtn);
    h = handle(NewLoopOpeningBtn,'callbackproperties');
    h.ActionPerformedCallback = {@LocalNewLoopFcn, this};
end

HighlightBtn =  javaObjectEDT('com.mathworks.mwswing.MJButton',sprintf('Highlight feedback loop'));
HighlightBtn.setName('HighlightBtn');
LoopConfigBtnPanel.add(HighlightBtn);
h = handle(HighlightBtn,'callbackproperties');
h.ActionPerformedCallback = {@LocalHighlightFcn this};

% Populate LoopConfigurePanel
LoopConfigurePanel.add(LoopConfigLabel,BorderLayout.NORTH);
LoopConfigurePanel.add(ScrollPane,BorderLayout.CENTER);
LoopConfigurePanel.add(LoopConfigBtnPanel,BorderLayout.SOUTH);

%% Button Panel
% Create buttons panel
BtnPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel',FlowLayout(FlowLayout.RIGHT));

% Make buttons and add to panel
Btn1 = javaObjectEDT('com.mathworks.mwswing.MJButton',sprintf('OK'));
Btn1.setName('OK')
h = handle(Btn1,'callbackproperties');
h.ActionPerformedCallback = {@LocalOK, this};

Btn2 = javaObjectEDT('com.mathworks.mwswing.MJButton',sprintf('Cancel'));
Btn2.setName('Cancel')
h = handle(Btn2,'callbackproperties');
h.ActionPerformedCallback = {@LocalCancel, this};

Btn3 = javaObjectEDT('com.mathworks.mwswing.MJButton',sprintf('Help'));
Btn3.setName('Help')
h = handle(Btn3,'callbackproperties');
h.ActionPerformedCallback = @LocalHelp;

Buttons = struct('Btn1', Btn1, 'Btn2', Btn2, 'Btn3', Btn3);

% Populate Button Panel
BtnPanel.add(Btn1);
BtnPanel.add(Btn2);
BtnPanel.add(Btn3);

% Main panel for Frame
ContentPanel=javaObjectEDT(Frame.getContentPane);
ContentPanel.setLayout(BorderLayout(0,0));
ContentPanel.add(MainPanel,BorderLayout.CENTER);
ContentPanel.add(javaObjectEDT('com.mathworks.mwswing.MJPanel'),BorderLayout.WEST);
ContentPanel.add(javaObjectEDT('com.mathworks.mwswing.MJPanel'),BorderLayout.EAST);
ContentPanel.add(javaObjectEDT('com.mathworks.mwswing.MJPanel'),BorderLayout.NORTH);
MainPanel.add(LoopSelectPanel,BorderLayout.NORTH);
MainPanel.add(LoopConfigurePanel,BorderLayout.CENTER);
MainPanel.add(BtnPanel,BorderLayout.SOUTH);

%% Add listener for the case where the task node is destroyed.
TaskListener = handle.listener(handle(getObject(getSelected(slctrlexplorer))), 'ObjectBeingDestroyed', ...
                              {@LocalWindowClose, this});

this.Handles = struct(...
    'Frame', Frame, ...
    'Buttons', Buttons, ...
    'TableModel', TableModel,...
    'ComboBox', LoopSelectComboBox,...
    'Listeners', Listeners, ...
    'TableListener', hListener,...
    'TaskListener', TaskListener,...
    'HighlightBtn', HighlightBtn);

if Configuration == 0
    this.Handles.NewLoopOpeningBtn = NewLoopOpeningBtn;
end

%% Set the frame to a good size
Frame.setSize(650,450);

%% Add closing callback for the frame
h = handle(Frame,'callbackproperties');
h.WindowClosingCallback = {@LocalCancel this};


%------------------------Callback Functions--------------------------------

% ------------------------------------------------------------------------%
% Function: LocalWindowClose
% Purpose:  Hide dialog Frame
% ------------------------------------------------------------------------%
function LocalWindowClose(es,ed,this)
CETMFrame = slctrlexplorer;
CETMFrame.setBlocked(false,[]);
Frame = this.Handles.Frame;
delete(this);
awtinvoke(Frame,'dispose');

% ------------------------------------------------------------------------%
% Function: LocalOK
% Purpose:  Export data and hide
% ------------------------------------------------------------------------%
function LocalOK(es,ed,this)
this.export;

%% Call the cancel function to dispose of the dialog
LocalCancel([],[],this)

% ------------------------------------------------------------------------%
% Function: LocalCancel
% Purpose:  Hide dialog Frame
% ------------------------------------------------------------------------%
function LocalCancel(es,ed,this)

% Turn off highlighting of the Simulink model
if this.LoopData.getconfig == 0
    %% Get the TaskNode
    TaskNode = handle(getObject(getSelected(slctrlexplorer)));
    
    %% Get the open block diagrams
    open_bd = find_system('type','block_diagram');
    mdl = getModel(TaskNode);
    if ~isempty(find(strcmp(mdl,open_bd),1))
        set_param(mdl,'HiliteAncestors','none');
    end
else
    TaskNode = handle(getObject(getSelected(slctrlexplorer)));
    DesignTask = TaskNode.sisodb.DesignTask;
    if ~isempty(DesignTask.Diagram) && strcmp(DesignTask.Diagram.Figure.Visible,'on');
        DesignTask.showDiagram;
    end
end

% Close the window
LocalWindowClose([],[],this)

% ------------------------------------------------------------------------%
% Function: LocalHelp
% Purpose:  Help link
% ------------------------------------------------------------------------%
function LocalHelp(es,ed)
mapfile = ctrlguihelp;
helpview(mapfile,'sisoconfigureopenloop','CSHelpWindow');

%-------------------------------------------------------------------------%
% Function: LocalUpDateTarget
% Abstract: Update target for selected compensator
%-------------------------------------------------------------------------%
function LocalUpdateTarget(es,ed,this)

this.Target = this.Handles.ComboBox.getSelectedIndex+1;
this.refreshTable;

%-------------------------------------------------------------------------%
% Function: LocalUpdateData
% Abstract: Update loopopenings data for selected Loop
%-------------------------------------------------------------------------%
function LocalUpdateData(es,ed,this)

Data = cell(this.Handles.TableModel.data);
for ct = 1:size(Data,1);
    this.LoopConfig(this.Target).LoopOpenings(ct).Status = Data{ct,1};
end

%-------------------------------------------------------------------------%
% Function: LocalNewLoopFcn
% Abstract: Create dialog to allow for a user to add a new loop opening.
%-------------------------------------------------------------------------%
function LocalNewLoopFcn(es,ed,this)

% Create the new open loop dialog
createNewOpenLoopDlg(this);

%-------------------------------------------------------------------------%
% Function: LocalHighlightFcn
% Abstract: Highlight the loop in the model or in the SISOTOOL figure
%-------------------------------------------------------------------------%
function LocalHighlightFcn(es, ed, this)

LoopData = this.LoopData;
if LoopData.getconfig == 0
    %% Get the TaskNode
    TaskNode = handle(getObject(getSelected(slctrlexplorer)));
    
    %% Get the open block diagrams
    open_bd = find_system('type','block_diagram');
    mdl = getModel(TaskNode);
    if isempty(find(strcmp(mdl,open_bd),1))
        try
            open_system(mdl);
        catch ME
            str = ltipack.utStripErrorHeader(ME.message);
            errordlg(str, xlate('Simulink Control Design'));
        end
    end

    %% Get the data
    GUILoopConfig = this.LoopConfig(this.Target);
    ComputedLoopConfig = this.FeedbackLoops(this.Target).LoopConfig;
    
    if ~isequal(GUILoopConfig,ComputedLoopConfig)
        wtbr = waitbar(0,'Computing feedback loop');
        %% Create the loop opening IOs
        LoopOpenings = GUILoopConfig.LoopOpenings;
        for ct = numel(LoopOpenings):-1:1
            if LoopOpenings(ct).Status
                Active = 'on';
            else
                Active = 'off';
            end
            loopopeningio(ct) = linio(LoopOpenings(ct).BlockName,...
                                      LoopOpenings(ct).PortNumber,...
                                      'none','on'); %#ok<AGROW>
            loopopeningio(ct).Active = Active; %#ok<AGROW>
        end

        %% Create the FeedbackLoop IO
        OpenLoop = GUILoopConfig.OpenLoop;
        FeedbackLoop = linio(OpenLoop.BlockName,OpenLoop.PortNumber,'outin','on');

        loopio = struct('FeedbackLoop',FeedbackLoop,...
            'LoopOpenings',loopopeningio,...
            'Name',this.FeedbackLoops(this.Target).Name,...
            'Description',this.FeedbackLoops(this.Target).Description);

        % Recompute loop for SCD
        try
            waitbar(1/10);
            tunedloop = computeSingleTunedLoop(TaskNode,loopio,LoopData);
        catch ME
            if strcmp(ME.identifier,'slcontrol:BlockNotInFeedbackLoop')
                str = sprintf(['The signal at the outport of the block %s, port %d is ',...
                    'not in a feedback loop when using the selected Open-Loop configuration.  ',...
                    'Please select another configuration.'],GUILoopConfig.OpenLoop.BlockName,...
                    GUILoopConfig.OpenLoop.PortNumber);
            else
                str = sprintf(['The open-loop %s could not be analyzed due ',...
                    'to the following error: \n\n %s'],LoopData.Name,ME.message);
                close(wtbr)
                errordlg(str, xlate('Simulink Control Design'))
                return
            end
            close(wtbr)
            errordlg(str, xlate('Simulink Control Design'));
            return
        end
        waitbar(1)
        close(wtbr);
    else
        tunedloop = this.FeedbackLoops(this.Target);
    end    
    hiliteloop(linutil,getModel(TaskNode),tunedloop,'on')
else
    if any(LoopData.getconfig == [4,6])
       TaskNode = handle(getObject(getSelected(slctrlexplorer)));
       TaskNode.sisodb.DesignTask.showDiagram(this.LoopConfig(this.Target));
    end
end

