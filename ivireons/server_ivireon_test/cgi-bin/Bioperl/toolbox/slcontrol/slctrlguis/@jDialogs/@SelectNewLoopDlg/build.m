function build(this)
%BUILD  Builds dialog.

%   Authors: John Glass
%   Copyright 1986-2006 The MathWorks, Inc. 
%   $Revision: 1.1.8.12 $ $Date: 2009/03/23 16:44:30 $

% Get useful data
updatefcn = this.updatefcn;

% Create the dialog
Dialog = javaObjectEDT('com.mathworks.mwswing.MJDialog',this.Handles.ParentFrame,false);
Dialog.setName('SelectNewLoopDialog');
Dialog.setTitle(ctrlMsgUtils.message('Slcontrol:controldesign:SelectNewLoopTuneLabel'));
cp = javaObjectEDT(Dialog.getContentPane);
BorderLayout = javaObjectEDT('java.awt.BorderLayout');
cp.setLayout(BorderLayout);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create the top selector panel
TypeLabel = javaObjectEDT('com.mathworks.mwswing.MJLabel',...
                    ctrlMsgUtils.message('Slcontrol:controldesign:SelectLoopTypeLabel'));
TypeLabel.setName('TypeLabel');
Labels = {ctrlMsgUtils.message('Slcontrol:controldesign:ClosedLoopLabel'),...
            ctrlMsgUtils.message('Slcontrol:controldesign:OpenLoopLabel')};
TypeCombo = javaObjectEDT('com.mathworks.mwswing.MJComboBox',Labels);
TypeCombo.setName('TypeCombo');
h = handle(TypeCombo,'callbackproperties');
h.ActionPerformedCallback = {@LocalLoopTypeCombo, this};
TypePanel = javaObjectEDT('com.mathworks.mwswing.MJPanel');
FlowLayout = javaObjectEDT('java.awt.FlowLayout');
FlowLayout.setAlignment(FlowLayout.LEFT);
TypePanel.setLayout(FlowLayout)
TypePanel.add(TypeLabel);
TypePanel.add(TypeCombo);
cp.add(TypePanel,BorderLayout.NORTH);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create the center panels

% Create the closed loop panel
ClosedLoopResponsePanel = this.buildClosedLoopPanel;

% Create the open loop panel
OpenLoopResponsePanel = this.buildOpenLoopPanel;

% Create the card panel
CardPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel');
CardLayout = javaObjectEDT('java.awt.CardLayout');
CardPanel.setLayout(CardLayout);
CardPanel.add(ClosedLoopResponsePanel,'ClosedLoopResponsePanel')
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
                              {@LocalCancelFcn,this});
Handles.TaskListener = TaskListener;
this.Handles = Handles;

% Create the buttons below
OKButton = javaObjectEDT('com.mathworks.mwswing.MJButton',xlate('OK'));
OKButton.setName('OKButton');
h = handle(OKButton,'callbackproperties');
h.ActionPerformedCallback = {@LocalOKFcn,this, updatefcn};

CancelButton = javaObjectEDT('com.mathworks.mwswing.MJButton',xlate('Cancel'));
CancelButton.setName('CancelButton');
h = handle(CancelButton,'callbackproperties');
h.ActionPerformedCallback = {@LocalWindowClose, this};

ButtonPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel');
FlowLayout = javaObjectEDT('java.awt.FlowLayout');
FlowLayout.setAlignment(FlowLayout.RIGHT);
ButtonPanel.setLayout(FlowLayout)
ButtonPanel.add(OKButton);
ButtonPanel.add(CancelButton);
cp.add(ButtonPanel,BorderLayout.SOUTH);

% Set the frame to a good size
Dialog.setSize(650,450);

% Add closing callback for the frame
h = handle(Dialog,'callbackproperties');
h.WindowClosingCallback = {@LocalWindowClose, this};

% Set the initial help
LocalLoopTypeCombo([],[],this)

% Show the dialog
Dialog.setLocationRelativeTo(slctrlexplorer);
javaMethodEDT('show',Dialog);
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Local Functions
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalWindowClose(es,ed,this)

Handles = this.Handles;
if isa(Handles.ParentFrame,'com.mathworks.toolbox.control.explorer.Explorer')
    Handles.ParentFrame.setBlocked(false,[]);
else
    % Turn off the glass pane
    GlassPane = Handles.ParentFrame.getGlassPane;
    javaMethodEDT('setVisible',GlassPane,false);
end

% Clean up the Open Loop Panel
SignalInspectPanel = this.Handles.SignalInspectPanel;
TreeManager = this.Handles.TreeManager;
SignalInspectPanel.setSelected(TreeManager.Root.getTreeNodeInterface);
drawnow
ModelNode = TreeManager.Root.getChildren;
LocalRemoveListeners(ModelNode)
disconnect(ModelNode);
drawnow
delete(TreeManager);

% Take apart the Java dialog
Handles.OpenLoopSplitPane.remove(Handles.OpenLoopInstruct);
Handles.OpenLoopSplitPane.remove(Handles.SignalInspectPanel);

javaMethodEDT('cleanup',SignalInspectPanel)
cp = this.Handles.Dialog.getContentPane;
javaMethodEDT('removeAll',cp);
javaMethodEDT('dispose',this.Handles.Dialog);

% Delete handles
delete(Handles.TaskListener)
delete(this)
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalRemoveListeners(Node)

removeListeners(Node);

Children = Node.getChildren;

for ct = numel(Children):-1:1;
    LocalRemoveListeners(Children(ct))
end
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalOKFcn(es,ed,this,updatefcn)

loopdata = this.loopdata;
Handles = this.Handles;

% Turn off the glass pane
GlassPane = Handles.ParentFrame.getGlassPane;
javaMethodEDT('setVisible',GlassPane,false);

% Determine the number of existing closed loop responses
FeedbackFlag = get(loopdata.L,{'Feedback'});
nCL = sum(~[FeedbackFlag{:}]);
nOL = sum([FeedbackFlag{:}]);

% Create the IO for the open loop then the closed loop
if this.Handles.TypeCombo.getSelectedIndex == 1

    % Get the selected signal from the explorer dialog
    SignalInspectPanel = Handles.SignalInspectPanel;
    selectednode = handle(getObject(SignalInspectPanel.getSelected));
    dlg = selectednode.getDialogInterface;
    row = dlg.getTable.getSelectedRow+1;

    if ~isempty(row) && row > 0
        % Create the Description and Name Labels
        % Create Unique Name
        k = nOL+1;
        Name = ctrlMsgUtils.message('Slcontrol:controldesign:OpenLoopNumberLabel',k);
        while any(strcmp(Name,get(loopdata.L,{'Name'})))
            k = k +1;
            Name = ctrlMsgUtils.message('Slcontrol:controldesign:OpenLoopNumberLabel',k);
        end
        
        SelectedSignal = selectednode.Signals{row};
        portdel = strfind(SelectedSignal,':');
        Block = SelectedSignal(1:portdel-1);
        Port = str2double(SelectedSignal(portdel+1:end));
        
        % Create the description string
        ph = get_param(Block,'PortHandles');
        name = getUniqueSignalName(slcontrol.Utilities,ph.Outport(Port));
        if ~isempty(get_param(ph.Outport(Port),'Name'))
            Description = ctrlMsgUtils.message('Slcontrol:controldesign:OpenLoopAtSignal',name);
        else
            Description = ctrlMsgUtils.message('Slcontrol:controldesign:OpenLoopAtOutport',Port,name);
        end

        % Check for a duplicate loop
        if ~any(strcmp(Description,get(loopdata.L,{'Description'})))
            wtbr = waitbar(0,ctrlMsgUtils.message('Slcontrol:controldesign:ComputingOpenLoopTitle'));
        
            loopio = struct('FeedbackLoop',linio(Block,Port,'outin','on'),...
                'LoopOpenings',[],....
                'Name',Name,...
                'Description',Description);

            try
                waitbar(1/10);
                % Compute the feedback loop
                tunedloop = computeSingleTunedLoop(this.SISOTaskNode,loopio,this.loopdata);
            catch Ex
                close(wtbr)
                msg = ltipack.utStripErrorHeader(Ex.message);
                errordlg(msg,'Simulink Control Design')
                return
            end

            waitbar(1);
            close(wtbr)
            loopdata.addLoop(tunedloop);

            % Update the loop table
            feval(updatefcn{:})
            % Dispose of the dialog
            LocalWindowClose(es,ed,this);
        else
            slctrlguis.warndlg('controldesign','OpenLoopAlreadySelected',Description);
        end
    end
else
    % Get the selected response
    inioind = Handles.ClosedLoopInputSelect.getSelectedIndex+1;
    inio = Handles.ClosedLoopInputSelect.getSelectedItem;
    outioind = Handles.ClosedLoopOutputSelect.getSelectedIndex+1;
    outio = Handles.ClosedLoopOutputSelect.getSelectedItem;
    blocktotuneind = Handles.BlockToTuneSelect.getSelectedIndex+1;

    % Create the name and description
    % Create a unique name
    k = nCL+1;
    Name = ctrlMsgUtils.message('Slcontrol:controldesign:ClosedLoopNumberLabel',k);
    while any(strcmp(Name,get(loopdata.L,{'Name'})))
        k = k +1;
        Name = ctrlMsgUtils.message('Slcontrol:controldesign:ClosedLoopNumberLabel',k);
    end
    Description = ctrlMsgUtils.message('Slcontrol:controldesign:ClosedLoopFromTo',inio,outio);

    % Check for a duplicate loop
    if ~any(strcmp(Description,get(loopdata.L,{'Description'})))
        % Update the Tuned Closed Loops
        tunedcl = sisodata.TunedLoop;
        tunedcl.Name = Name;
        tunedcl.Description = Description;
        tunedcl.Identifier = sprintf('FF%d',nCL+1);
        tunedcl.setTunedLFT(ltipack.ssdata([],zeros(0,1),zeros(1,0),1,[],0),[]);
        tunedcl.TunedFactors = loopdata.C(blocktotuneind);
        tunedcl.ClosedLoopIO = [outioind,inioind];
        loopdata.addLoop(tunedcl);

        % Update the loop table
        feval(updatefcn{:})
        % Dispose of the dialog
        LocalWindowClose(es,ed,this);
    else
        slctrlguis.warndlg('controldesign','ClosedLoopResponseAlreadySelected',Description);
    end
end

end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalLoopTypeCombo(es,ed,this)

c=this.Handles.CardPanel.getLayout;

if this.Handles.TypeCombo.getSelectedIndex == 0
    javaMethodEDT('show',c,this.Handles.CardPanel,'ClosedLoopResponsePanel');
    % Set the help topic
    scdguihelp('select_closed_loop_response_design',this.Handles.HelpPanel)
else
    javaMethodEDT('show',c,this.Handles.CardPanel,'OpenLoopResponsePanel');
    % Set the help topic
    scdguihelp('select_open_loop_response_dialog',this.Handles.HelpPanel)
end

end
