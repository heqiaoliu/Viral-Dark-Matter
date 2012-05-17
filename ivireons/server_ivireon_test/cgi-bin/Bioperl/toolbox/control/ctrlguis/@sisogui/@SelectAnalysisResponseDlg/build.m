function build(this)
%BUILD  Builds dialog.

%   Authors: John Glass
%   Copyright 1986-2006 The MathWorks, Inc. 
%   $Revision: 1.1.8.8 $ $Date: 2007/02/06 19:50:47 $

import com.mathworks.mwswing.*;
import java.awt.*;

%% Get useful data
updatefcn = this.updatefcn;

%% Create the dialog
Dialog = awtcreate('com.mathworks.mwswing.MJDialog','Ljava.awt.Frame;Z',this.Handles.ParentFrame,false);
Dialog.setName('SelectAnalysisResponseDialog');
Dialog.setTitle(xlate('Select New Response to View'));
cp = Dialog.getContentPane;
cp.setLayout(java.awt.BorderLayout(5,5));

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Create the top selector panel
TypeLabel = MJLabel(xlate('Select the Response Type:'));
TypeLabel.setName('TypeLabel');
TypeCombo = MJComboBox({'Closed-Loop Response','Tuned Block Response'});
TypeCombo.setName('TypeCombo');
h = handle(TypeCombo,'callbackproperties');
h.ActionPerformedCallback = {@LocalLoopTypeCombo this};
TypePanel = MJPanel;
TypePanel.add(TypeLabel);
TypePanel.add(TypeCombo);
cp.add(TypePanel,java.awt.BorderLayout.NORTH);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Create the center panels

%% Create the closed and open loop panels
ClosedLoopResponsePanel = this.buildClosedLoopPanel;
OpenLoopResponsePanel = this.buildOpenLoopPanel;

%% Create the card panel
CardPanel = MJPanel;
CardPanel.setLayout(java.awt.CardLayout());
CardPanel.add(ClosedLoopResponsePanel,'ClosedLoopResponsePanel')
CardPanel.add(OpenLoopResponsePanel,'OpenLoopResponsePanel')
cp.add(CardPanel,java.awt.BorderLayout.CENTER);

%% Store the handles that are needed
Handles = this.Handles;
Handles.Dialog = Dialog;
Handles.CardPanel = CardPanel;
Handles.TypeCombo = TypeCombo;

%% Add listener for the case where the task node is destroyed.
h = handle(getObject(getSelected(slctrlexplorer)));
TaskListener = handle.listener(h, 'ObjectBeingDestroyed', {@LocalCancelFcn this});
Handles.TaskListener = TaskListener;

this.Handles = Handles;

%% Create the buttons below
OKButton = com.mathworks.mwswing.MJButton(xlate('OK'));
h = handle(OKButton,'callbackproperties');
h.ActionPerformedCallback = {@LocalOKFcn this updatefcn};

CancelButton = com.mathworks.mwswing.MJButton(xlate('Cancel'));
h = handle(CancelButton,'callbackproperties');
h.ActionPerformedCallback = {@LocalCancelFcn this};

HelpButton = com.mathworks.mwswing.MJButton(xlate('Help'));
h = handle(HelpButton,'callbackproperties');
h.ActionPerformedCallback = {@LocalHelpFcn};

ButtonPanel = com.mathworks.mwswing.MJPanel;
ButtonPanel.setLayout(java.awt.FlowLayout(java.awt.FlowLayout.RIGHT))
ButtonPanel.add(OKButton);
ButtonPanel.add(CancelButton);
ButtonPanel.add(HelpButton);
cp.add(ButtonPanel,java.awt.BorderLayout.SOUTH);

%% Set the frame to a good size
Dialog.setSize(650,450);

%% Add closing callback for the frame
h = handle(Dialog,'callbackproperties');
h.WindowClosingCallback = {@LocalWindowClose this};

%% Show the dialog
Dialog.setLocationRelativeTo(this.Handles.ParentFrame);
Dialog.show;
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Local Functions
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalWindowClose(es, ed, this)

if isa(this.Handles.ParentFrame,'com.mathworks.toolbox.control.explorer.Explorer')
    this.Handles.ParentFrame.setBlocked(false,[]);
else
    %% Turn off the glass pane
    GlassPane = this.Handles.ParentFrame.getGlassPane;
    awtinvoke(GlassPane,'setVisible',false);
end
Frame = this.Handles.Dialog;
delete(this);
%% Close the frame
awtinvoke(Frame,'dispose');
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalCancelFcn(es, ed, this)

LocalWindowClose([],[],this)
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalOKFcn(es, ed, this, updatefcn)

%% Get the handle to the loopdata 
loopdata = this.loopdata;

%% Create the IO for the open loop then the closed loop
if this.Handles.TypeCombo.getSelectedIndex == 1
    %% Get the selected response
    ctrlind = this.Handles.IndividualElementSelect.getSelectedIndex+1;

    Description = sprintf('Tuned Block - %s',loopdata.C(ctrlind).Name);
    if ~any(strcmp(Description,get(loopdata.LoopView,{'Description'})))
        %% Create a new loop view
        LoopTF = sisodata.looptransfer;
        LoopTF.Type = 'C';
        LoopTF.Index = ctrlind;
        LoopTF.Description = Description;
        LoopTF.ExportAs = loopdata.C(ctrlind).ID;
        addLoopView(this,loopdata,LoopTF);

        %% Update the loop table
        feval(updatefcn{:})
        %% Close the frame
        LocalCancelFcn([],[],this)
    else
        warndlg(sprintf(['The tuned block %s has already been selected.  ',...
            'Please select another tuned block.'],loopdata.C(ctrlind).Name),'Simulink Control Design')
    end
else        
    %% Get the selected response
    inioind = this.Handles.ClosedLoopInputSelect.getSelectedIndex+1;
    inio = this.Handles.ClosedLoopInputSelect.getSelectedItem;
    outioind = this.Handles.ClosedLoopOutputSelect.getSelectedIndex+1;
    outio = this.Handles.ClosedLoopOutputSelect.getSelectedItem;
    
    Description = sprintf('Closed Loop - From %s to %s',inio,outio);
        
    if ~any(strcmp(Description,get(loopdata.LoopView,{'Description'})))
        %% Create a new loop view
        LoopTF = sisodata.looptransfer;
        LoopTF.Type = 'T';
        LoopTF.Index = {outioind inioind};
        LoopTF.Description = Description;
        LoopTF.ExportAs = sprintf('T_%s2%s',inio,outio);
        addLoopView(this,loopdata,LoopTF);

        %% Update the loop table
        feval(updatefcn{:})
        %% Close the frame
        LocalCancelFcn([],[],this);
    else
        warndlg(sprintf(['The closed-loop %s has already been selected.  ',...
            'Please select another loop.'],Description),'Simulink Control Design')
    end
end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalLoopTypeCombo(es, ed, this)

c = this.Handles.CardPanel.getLayout;
if this.Handles.TypeCombo.getSelectedIndex == 0
    awtinvoke(c,'show',this.Handles.CardPanel,'ClosedLoopResponsePanel');
else
    awtinvoke(c,'show',this.Handles.CardPanel,'OpenLoopResponsePanel');
end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalHelpFcn(es, ed)
mapfile = ctrlguihelp;
helpview(mapfile,'sisoselectnewresponse','CSHelpWindow');
end
