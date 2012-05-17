function build(this)
%BUILD  Builds dialog.

%   Authors: John Glass
%   Copyright 1986-2006 The MathWorks, Inc. 
%   $Revision: 1.1.8.10 $ $Date: 2008/08/01 12:18:59 $

import com.mathworks.mwswing.*;
import java.awt.*;

%% Get useful data
updatefcn = this.updatefcn;

%% Create the dialog
Dialog = awtcreate('com.mathworks.mwswing.MJDialog','Ljava.awt.Frame;Z',this.Handles.ParentFrame,false);
Dialog.setName('SelectNewLoopDialog');
Dialog.setTitle(xlate('Select New Loop to Tune'));
Handles = this.Handles; 
Handles.Dialog = Dialog; 

%% Add listener for the case where the task node is destroyed.
h = handle(getObject(getSelected(slctrlexplorer)));
TaskListener = handle.listener(h,'ObjectBeingDestroyed',{@LocalCancelFcn this});
Handles.TaskListener = TaskListener;
this.Handles = Handles;

cp = Dialog.getContentPane;
cp.setLayout(java.awt.BorderLayout(5,5));

%% Create the closed loop panel
CLPanel = this.buildClosedLoopPanel;
cp.add(CLPanel,java.awt.BorderLayout.CENTER);

%% Create the bottom button panel
OKButton = MJButton(xlate('OK'));
h = handle(OKButton,'callbackproperties');
h.ActionPerformedCallback = {@LocalOKFcn this updatefcn};

CancelButton = MJButton(xlate('Cancel'));
h = handle(CancelButton,'callbackproperties');
h.ActionPerformedCallback = {@LocalCancelFcn this};

HelpButton = MJButton(xlate('Help'));
h = handle(HelpButton,'callbackproperties');
h.ActionPerformedCallback = {@LocalHelpFcn};

ButtonPanel = com.mathworks.mwswing.MJPanel;
ButtonPanel.setLayout(FlowLayout(FlowLayout.RIGHT))
ButtonPanel.add(OKButton);
ButtonPanel.add(CancelButton);
ButtonPanel.add(HelpButton);
cp.add(ButtonPanel,BorderLayout.SOUTH);

%% Set the frame to a good size
Dialog.setSize(650,450);

%% Add closing callback for the dialog
h = handle(Dialog,'callbackproperties');
h.WindowClosingCallback = {@LocalWindowClose};

%% Show the dialog
javaMethodEDT('setLocationRelativeTo',Dialog,slctrlexplorer);
javaMethodEDT('show', Dialog);
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Local Functions
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalWindowClose(es, ed)

%% Set the CETM to be blocked with a GlassPane
CETMFrame = slctrlexplorer;
CETMFrame.setBlocked(false,[])
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalCancelFcn(es, ed, this)

LocalWindowClose([], []);
%% Close the frame
awtinvoke(this.Handles.Dialog,'dispose');
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalOKFcn(es, ed, this, updatefcn)

loopdata = this.loopdata;
Handles = this.Handles;

%% Determine the number of existing closed loop responses
FeedbackFlag = get(loopdata.L,{'Feedback'});
nCL = sum(~[FeedbackFlag{:}]);

%% Get the selected response
inioind = Handles.ClosedLoopInputSelect.getSelectedIndex+1;
inio = Handles.ClosedLoopInputSelect.getSelectedItem;
outioind = Handles.ClosedLoopOutputSelect.getSelectedIndex+1;
outio = Handles.ClosedLoopOutputSelect.getSelectedItem;
blocktotuneind = Handles.BlockToTuneSelect.getSelectedIndex+1;

%% Create a unique name and the description
% Create a Unique name
k = nCL+1;
Name = sprintf('Closed Loop %d',k);
while any(strcmp(Name,get(loopdata.L,{'Name'})))
    k = k +1;
    Name = sprintf('Closed Loop %d',k);
end
    
Description = sprintf('Closed Loop - From %s to %s',inio,outio);

%% Check for a duplicate loop
if ~any(strcmp(Description,get(loopdata.L,{'Description'})))

    %% Update the Tuned Closed Loops
    tunedcl = sisodata.TunedLoop;
    tunedcl.Name = Name;
    tunedcl.Description = Description;
    tunedcl.Identifier = sprintf('FF%d',nCL+1);
    tunedcl.setTunedLFT(ltipack.ssdata([],zeros(0,1),zeros(1,0),1,[],0),[]);
    tunedcl.TunedFactors = loopdata.C(blocktotuneind);
    tunedcl.ClosedLoopIO = [outioind,inioind];
    loopdata.addLoop(tunedcl);

    %% Create a new loop view and be sure that the loop view has not
    %% been created.
    if ~any(strcmp(Description,get(loopdata.LoopView,{'Description'})))
        LoopTF = sisodata.looptransfer;
        LoopTF.Type = 'T';
        LoopTF.Index = {outioind inioind};
        LoopTF.Description = tunedcl.Description;
        LoopTF.ExportAs = sprintf('T_%s',tunedcl.Description);
        addLoopView(this,loopdata,LoopTF);
    end

    %% Update the loop table
    feval(updatefcn{:})

    %% Dispose of the dialog
    LocalCancelFcn([],[],this);
else
    warndlg(sprintf(['The closed-loop %s has already been selected.  ',...
        'Please select another loop.'],Description),'SISOTool')
end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalHelpFcn(es, ed)
mapfile = ctrlguihelp;
helpview(mapfile,'sisoselectnewloop','CSHelpWindow');
end