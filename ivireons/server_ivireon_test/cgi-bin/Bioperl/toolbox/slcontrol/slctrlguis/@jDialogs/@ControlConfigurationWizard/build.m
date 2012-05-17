function Frame = build(this) 
% BUILD  Build the configuration wizard
%
 
% Author(s): John W. Glass 10-Aug-2005
% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.11 $ $Date: 2008/12/04 23:27:43 $

% Initialize the panel counter
this.ind_current = 1;

% Get the panels that will be used in the wizard;
this.createPanels;

% Now add the panels to the card panel
for ct = numel(this.WizardPanels):-1:1
    Panels(ct,1) = this.WizardPanels(ct).Panel;
end

% Get the strings
GUIStrings = {xlate('Design Configuration Wizard');...
              xlate('< Back');...
              xlate('Next >');...
              xlate('Cancel');...
              xlate('Finish')};

% Build the frame.  Parent it to the Control and Estimation Tools Manager
Frame = javaObjectEDT('com.mathworks.toolbox.slcontrol.Dialogs.ControlConfigurationWizardDialog',...
                    slctrlexplorer,Panels,GUIStrings,scdmapfile);         
          
% Get the help panel
HelpPanel = Frame.getEmbeddedHelpPanel; 

% Create the main panel
LeftPanel = Frame.getLeftPanel;

% Create the buttons below
BackButton = Frame.getBackButton;
h = handle(BackButton,'callbackproperties');
h.ActionPerformedCallback = {@LocalBackFcn, this};

NextButton = Frame.getNextButton;
h = handle(NextButton,'callbackproperties');
h.ActionPerformedCallback = {@LocalNextFcn, this};

CancelButton = Frame.getCancelButton;
h = handle(CancelButton,'callbackproperties');
h.ActionPerformedCallback = {@LocalCancelFcn, this};

FinishButton = Frame.getFinishButton;
h = handle(FinishButton,'callbackproperties');
h.ActionPerformedCallback = {@LocalFinishFcn, this};

% Update the contents for the first frame
[mapfile, HelpTopic] = this.WizardPanels(1).getHelpTopic;
Frame.updateContents(0, HelpTopic, -1);

% Build and pack the frame
Frame.setSize(1000,450);
Frame.setLocationRelativeTo(slctrlexplorer);
Frame.show;

% Add closing callback for the frame
h = handle(Frame,'callbackproperties');
h.WindowClosingCallback = {@LocalWindowClose, this};

% Add listener for the case where the design task node is destroyed.
SISOTaskNodeListener = handle.listener(handle(getObject(getSelected(slctrlexplorer))), 'ObjectBeingDestroyed',...
                                    {@LocalCancelFcn, this});

% Store the useful handles
Handles = this.Handles;
Handles.SISOTaskNodeListener = SISOTaskNodeListener;
Handles.Frame = Frame;
Handles.HelpPanel = HelpPanel;
Handles.LeftPanel = LeftPanel;
Handles.BackButton = BackButton;
Handles.NextButton = NextButton;
Handles.FinishButton = FinishButton;
Handles.SplitPanel = Frame.getSplitPanel;
this.Handles = Handles;

end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Local Functions
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalWindowClose(es,ed,this)

% Turn off the explorer glass pane
Explorer = slctrlexplorer;
Explorer.setBlocked(false, []);
LocalCleanUpListeners(this)
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalCleanUpListeners(this)

delete(this.WizardPanels);
this.Handles.Frame.cleanup;
delete(this)
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalBackFcn(es,ed,this)

if this.Handles.Frame.isUpdated
    %% Set the updating flag
    this.Handles.Frame.setUpdated(false);
  
    %% Decrement the counter
    this.ind_current = this.ind_current-1;
    [mapfile,HelpTopic] = this.WizardPanels(this.ind_current).getHelpTopic;
    this.Handles.Frame.updateContents(this.ind_current-1, HelpTopic, -1);
end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalNextFcn(es,ed,this)

if this.Handles.Frame.isUpdated
    %% Set the updating flag
    this.Handles.Frame.setUpdated(false);
    
    %% Increment the counter
    this.ind_current = this.ind_current+1;
    [mapfile,HelpTopic] = this.WizardPanels(this.ind_current).getHelpTopic;
    this.Handles.Frame.updateContents(this.ind_current-1, HelpTopic, 1);
end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalCancelFcn(es,ed,this)
this.Handles.Frame.dispose;
% Turn off the explorer glass pane
LocalWindowClose(es,ed,this)
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalFinishFcn(es,ed,this)

% Get the SISOTOOL Design View table data
DesignViews = getSelectedDesignViews(this.WizardPanels(2));

% Close the wizard
this.Handles.Frame.dispose;

% Turn off the explorer glass pane
Explorer = slctrlexplorer;
Explorer.setBlocked(false, []);

% Create the design node
explorer = slctrlexplorer;
SISOTaskNode = this.SISOTaskNode;
SCDTasknode = SISOTaskNode.SimulinkControlDesignTask;

% Launch the SISOTOOL
sisodb = createSISOTool(linutil,this.loopdata,DesignViews);
SISOTaskNode.sisodb = sisodb;
sisodb.setNode(SISOTaskNode);

% Get the Analysis view table data 
AnalysisPlotData = getAnalysisPlotData(this.WizardPanels(3));

if ~isempty(AnalysisPlotData)
    wb = waitbar(0,'Creating Analysis Views');
    sisodb.setViewerContents(AnalysisPlotData)
    waitbar(1);
    close(wb);
end

% Create a node storing the original design
originalnode = ControlDesignNodes.DesignSnapshot(sprintf('Initial Design'));
originalnode.Description = xlate('Initial values from the Simulink model.');
sisodb.LoopData.History = sisodb.LoopData.exportdesign;
sisodb.LoopData.History.Name = xlate('Initial Design');

% Get a default name
SISOTaskNode.Label = SISOTaskNode.createDefaultName(sprintf('SISO Design Task'), SCDTasknode);
SCDTasknode.addNode(SISOTaskNode)

% Set the loopdata name to be the name of the task node.
sisodb.LoopData.Name = SISOTaskNode.Label;

% Add the node to the tree
explorer.setSelected(SISOTaskNode.getTreeNodeInterface);
children = SISOTaskNode.getChildren;
children(1).addNode(originalnode);
Frame = slctrlexplorer;
Frame.expandNode(children(1).getTreeNodeInterface)

% Set dirty listeners for the project
SISOTaskNode.setDirtyListener

% Clean up listeners
LocalCleanUpListeners(this)

% Set the project dirty flag
SCDTasknode.setDirty;

end
