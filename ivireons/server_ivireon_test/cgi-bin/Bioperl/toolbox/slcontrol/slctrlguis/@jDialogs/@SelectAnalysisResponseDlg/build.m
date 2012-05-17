function build(this)
%BUILD  Builds dialog.

%   Authors: John Glass
%   Copyright 1986-2006 The MathWorks, Inc. 
%   $Revision: 1.1.8.10 $ $Date: 2009/03/23 16:44:28 $

import java.awt.*;

% Get useful data
updatefcn = this.updatefcn;

% Create the dialog
Dialog = javaObjectEDT('com.mathworks.mwswing.MJDialog',this.Handles.ParentFrame,false);
Dialog.setName('SelectAnalysisResponseDialog');
Dialog.setTitle(ctrlMsgUtils.message('Slcontrol:controldesign:SelectNewResponseAnalyzeLabel'));
cp = Dialog.getContentPane;
javaObjectEDT(cp);
cp.setLayout(java.awt.BorderLayout(5,5));

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create the top selector panel
TypeLabel = javaObjectEDT('com.mathworks.mwswing.MJLabel',ctrlMsgUtils.message('Slcontrol:controldesign:SelectResponseTypeLabel'));
TypeLabel.setName('TypeLabel');
TypeCombo = javaObjectEDT('com.mathworks.mwswing.MJComboBox',...
    {ctrlMsgUtils.message('Slcontrol:controldesign:ClosedLoopResponseLabel'),...
     ctrlMsgUtils.message('Slcontrol:controldesign:TunedBlockResponseLabel'),...
     ctrlMsgUtils.message('Slcontrol:controldesign:OpenLoopResponseLabel')});
TypeCombo.setName('TypeCombo');
h = handle(TypeCombo,'callbackproperties');
h.ActionPerformedCallback = {@LocalLoopTypeCombo, this};
TypePanel = javaObjectEDT('com.mathworks.mwswing.MJPanel');
TypePanel.setLayout(java.awt.FlowLayout(java.awt.FlowLayout.LEFT))
TypePanel.add(TypeLabel);
TypePanel.add(TypeCombo);
cp.add(TypePanel,java.awt.BorderLayout.NORTH);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create the center panels

% Create the panels
ClosedLoopResponsePanel = this.buildClosedLoopPanel;
IndividualElementResponsePanel = buildSelectCompensatorPanel(this);
OpenLoopResponsePanel = this.buildOpenLoopPanel;

% Create the card panel
CardPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel');
CardPanel.setLayout(java.awt.CardLayout());
CardPanel.add(ClosedLoopResponsePanel,'ClosedLoopResponsePanel')
CardPanel.add(IndividualElementResponsePanel,'IndividualElementResponsePanel')
CardPanel.add(OpenLoopResponsePanel,'OpenLoopResponsePanel')

% Create the help panel
HelpPanel = javaObjectEDT('com.mathworks.mlwidgets.help.HelpPanel');

% Create the splitpane
SplitPane = javaObjectEDT('com.mathworks.mwswing.MJSplitPane',1,CardPanel,HelpPanel);
SplitPane.setDividerLocation(0.65)
cp.add(SplitPane,BorderLayout.CENTER);

% Store the handles that are needed
Handles = this.Handles;
Handles.Dialog = Dialog;
Handles.CardPanel = CardPanel;
Handles.TypeCombo = TypeCombo;
Handles.HelpPanel = HelpPanel;

% Add listener for the case where the task node is destroyed.
TaskListener = handle.listener(handle(getObject(getSelected(slctrlexplorer))), 'ObjectBeingDestroyed', ...
                              {@LocalCancelFcn, this});
Handles.TaskListener = TaskListener;
this.Handles = Handles;

% Create the buttons below
OKButton = javaObjectEDT('com.mathworks.mwswing.MJButton',xlate('OK'));
h = handle(OKButton,'callbackproperties');
h.ActionPerformedCallback = {@LocalOKFcn,this, updatefcn};

CancelButton = javaObjectEDT('com.mathworks.mwswing.MJButton',xlate('Cancel'));
h = handle(CancelButton,'callbackproperties');
h.ActionPerformedCallback = {@LocalCancelFcn, this};

ButtonPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel');
ButtonPanel.setLayout(java.awt.FlowLayout(java.awt.FlowLayout.RIGHT))
ButtonPanel.add(OKButton);
ButtonPanel.add(CancelButton);
cp.add(ButtonPanel,java.awt.BorderLayout.SOUTH);

% Add closing callback for the dialog
h = handle(Dialog,'callbackproperties');
h.WindowClosingCallback = {@LocalCancelFcn, this};

% Set the initial help
LocalLoopTypeCombo([],[],this)

% Set the frame to a good size
Dialog.setSize(650,450);

% Show the dialog
Dialog.setLocationRelativeTo(this.Handles.ParentFrame);
javaMethodEDT('show',Dialog);
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalWindowClose(es,ed,this)

Handles = this.Handles;
if isa(Handles.ParentFrame,'com.mathworks.toolbox.control.explorer.Explorer')
    Handles.ParentFrame.setBlocked(false,[]);
else
    % Turn off the glass pane
    GlassPane = Handles.ParentFrame.getGlassPane;
    javaMethodEDT('setVisible',GlassPane,false);
end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalOKFcn(es,ed,this,updatefcn)

Handles = this.Handles;

% Get the handle to the loopdata 
loopdata = this.loopdata;

% Create the IO for the open loop then the closed loop
if this.Handles.TypeCombo.getSelectedIndex == 1
    % Get the selected response
    ctrlind = Handles.IndividualElementSelect.getSelectedIndex+1;

    Description = sprintf('Tuned Block - %s',loopdata.C(ctrlind).Name);
    if ~any(strcmp(Description,get(loopdata.LoopView,{'Description'})))
        % Create a new loop view
        LoopTF = sisodata.looptransfer;
        LoopTF.Type = 'C';
        LoopTF.Index = ctrlind;
        LoopTF.Description = Description;
        Cind = numel(strcmp(get(loopdata.LoopView,'Type'),'C'))+1;
        LoopTF.ExportAs = sprintf('C_%d',Cind);
        addLoopView(this,loopdata,LoopTF);

        % Update the loop table
        feval(updatefcn{:})
        % Close the frame
        LocalCancelFcn([],[],this)
    else
        slctrlguis.warndlg('controldesign','TuneBlockAlreadySelected',loopdata.C(ctrlind).Name);
    end
elseif this.Handles.TypeCombo.getSelectedIndex == 2
    % Get the selected response
    ctrlind = Handles.OpenLoopSelect.getSelectedIndex+1;

    if ctrlind > 0
        Description = Handles.OpenLoopSelect.getSelectedItem;
        if ~any(strcmp(Description,get(loopdata.LoopView,{'Description'})))
            % Create a new loop view
            LoopTF = sisodata.looptransfer;
            LoopTF.Type = 'L';
            LoopTF.Index = find(strcmp(Description,get(loopdata.L,{'Description'})));
            LoopTF.Description = Description;
            Lind = numel(strcmp(get(loopdata.LoopView,'Type'),'L'))+1;
            LoopTF.ExportAs = sprintf('L_%d',Lind);
            addLoopView(this,loopdata,LoopTF);

            % Update the loop table
            feval(updatefcn{:})
            % Close the frame
            LocalCancelFcn([],[],this)
        else
            slctrlguis.warndlg('controldesign','OpenLoopAlreadySelected',Description);
        end
    else
        slctrlguis.warndlg('controldesign','NoOpenLoopResponsesAvailable');
    end
else        
    % Get the selected response
    inioind = Handles.ClosedLoopInputSelect.getSelectedIndex+1;
    inio = Handles.ClosedLoopInputSelect.getSelectedItem;
    outioind = Handles.ClosedLoopOutputSelect.getSelectedIndex+1;
    outio = Handles.ClosedLoopOutputSelect.getSelectedItem;
    
    Description = ctrlMsgUtils.message('Slcontrol:controldesign:ClosedLoopFromTo',inio,outio);
        
    if ~any(strcmp(Description,get(loopdata.LoopView,{'Description'})))
        % Create a new loop view
        LoopTF = sisodata.looptransfer;
        LoopTF.Type = 'T';
        LoopTF.Index = {outioind inioind};
        LoopTF.Description = Description;
        Tind = numel(strcmp(get(loopdata.LoopView,'Type'),'T'))+1;
        LoopTF.ExportAs = sprintf('T_%d',Tind);
        addLoopView(this,loopdata,LoopTF);

        % Update the loop table
        feval(updatefcn{:})
        % Close the frame
        LocalCancelFcn([],[],this)
    else
        slctrlguis.warndlg('controldesign','ClosedLoopResponseAlreadySelected',Description);
    end
end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalCancelFcn(es,ed,this)

Handles = this.Handles;
LocalWindowClose([],[],this)

% Close the frame
javaMethodEDT('dispose',Handles.Dialog);
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalLoopTypeCombo(es,ed,this)

c = this.Handles.CardPanel.getLayout;

if this.Handles.TypeCombo.getSelectedIndex == 0
    javaMethodEDT('show',c,this.Handles.CardPanel,'ClosedLoopResponsePanel');
    % Set the help topic
    scdguihelp('select_closed_loop_response_analysis',this.Handles.HelpPanel)
elseif this.Handles.TypeCombo.getSelectedIndex == 1
    javaMethodEDT('show',c,this.Handles.CardPanel,'IndividualElementResponsePanel');
    % Set the help topic
    scdguihelp('tuned_block_response_embedded_help',this.Handles.HelpPanel)
else
    javaMethodEDT('show',c,this.Handles.CardPanel,'OpenLoopResponsePanel');
    % Set the help topic
    scdguihelp('select_open_loop_response_analysis',this.Handles.HelpPanel)
end
end