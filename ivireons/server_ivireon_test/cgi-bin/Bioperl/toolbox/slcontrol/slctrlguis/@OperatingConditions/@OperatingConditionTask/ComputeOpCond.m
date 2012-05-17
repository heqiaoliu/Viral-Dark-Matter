function ComputeOpCond(this)
% Method to compute the operating conditions of a Simulink model.

%  Author(s): John Glass
%  Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.18 $ $Date: 2008/10/31 07:36:35 $

% Get the handle to the explorer frame
ExplorerFrame = slctrlexplorer;

% Get the last value for the error
try
    options = evalOptimOptions(this);
catch Ex
    errmsg = ltipack.utStripErrorHeader(Ex.message);
    errordlg(errmsg,'Simulink Control Design')
    return
end

% Trim the model first
ExplorerFrame.postText(ctrlMsgUtils.message('Slcontrol:operpointtask:ComputingOperatingPointMessage',this.Model))

try
    % Update the operating condition object
    opcopy = EvalOperSpecForms(this);
    if strcmp(this.Options.DisplayReport,'iter')
        % Get the handle to the status area
        StatusArea = this.Handles.OpCondSpecPanel.getStatus;
        StatusArea.clearText
        % Select the optimization output panel
        javaMethodEDT('setSelectedIndex',this.Handles.OpCondSpecPanel.OpConstrPanel,3);
        % Run the optimization
        [oppoint,opreport] = findop(opcopy.Model,opcopy,options,...
            {@LocalDisplayIteration,this,StatusArea},...
            {@LocalStopOptimization, this.Handles.ComputeOpCondButton});
    else
        % Get the handle to the status area
        StatusArea = this.Handles.OpCondSpecPanel.getStatus;
        StatusArea.clearText
        % Run the optimization
        [oppoint,opreport] = findop(opcopy.Model,opcopy,options);
    end
                                       
    % Create the operating conditions result node
    Label = this.createDefaultName(ctrlMsgUtils.message('Slcontrol:operpointtask:OperatingPointNodeDefaultLabel'), this);
    node = OperatingConditions.OperConditionResultPanel(Label);
    % Post the summary
    if strcmp(this.Options.DisplayReport,'iter')
        LocalDisplayIteration(this,StatusArea,{''})
        LocalDisplayIteration(this,StatusArea,{opreport.TerminationString})
        LocalDisplayIteration(this,StatusArea,{''})
        % Create the string to display the new node
        str = ctrlMsgUtils.message('Slcontrol:operpointtask:ComputedOperatingPointAdded', Label, Label);
        LocalDisplayIteration(this,StatusArea,{str})
        % Clear the display buffer since the optimization is finished
        this.StatusAreaText = {};    
    end
catch Ex
    if strcmp(Ex.identifier,'SLControllib:opcond:OperatingPointNeedsUpdate')
        str = ctrlMsgUtils.message('Slcontrol:operpointtask:OperSpecOutOfSyncInstruct',this.Model);
    else
        str = ctrlMsgUtils.message('Slcontrol:operpointtask:OperatingPointSearchGenericError',ltipack.utStripErrorHeader(Ex.message));
    end
    errordlg(str, sprintf('Simulink Control Design'))
    return
end

% Store the operating point
node.OpPoint = oppoint;

% Store the operating point report
node.OpReport = opreport;
node.Description = opreport.TerminationString;

% Add it to the node
this.addNode(node);

% Set the dirty flag
this.setDirty

% Expand the analysis nodes so the user sees the new result
ExplorerFrame.expandNode(this.getTreeNodeInterface);

% Send update to tell the user that a node has been added
ExplorerFrame.postText(sprintf(' - An operating point called "%s" has been added to the node Operating Points.', Label))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalDisplayIteration
function LocalDisplayIteration(this,StatusArea,str)

for ct = 1:length(str)
    this.StatusAreaText{end+1} = str{ct};
end
StatusArea.setContent(this.StatusAreaText);
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalStopOptimization
function stop = LocalStopOptimization(button)

if button.isSelected
    stop = false;
else
    stop = true;
end
