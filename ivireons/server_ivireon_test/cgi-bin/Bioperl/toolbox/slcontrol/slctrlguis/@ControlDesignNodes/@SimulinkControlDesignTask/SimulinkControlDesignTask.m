function this = SimulinkControlDesignTask(model)
%  SIMULINKCONTROLDESIGNTASK Constructor for @SimulinkControlDesignTask class

%  Author(s): John Glass
%  Revised:
%   Copyright 2004-2010 The MathWorks, Inc.
%  $Revision: 1.1.8.7.2.1 $  $Date: 2010/06/07 13:34:40 $

% Create class instance
this = ControlDesignNodes.SimulinkControlDesignTask;

if nargin == 0
  % Call when reloading object
  return
end

% Create the model parameter manager
ModelParameterMgr = linearize.ModelLinearizationParamMgr.getInstance(model);
ModelParameterMgr.loadModels;
ModelParameterMgr.prepareModels;

% Get the initial closed loop io settings.  There cannot be any loop
% openings for the closed loop signals.
newios = linearize.getModelIOPoints(ModelParameterMgr.getUniqueNormalModeModels);

% Compile the model
try
    ModelParameterMgr.compile('compile');
catch Ex
    % Restore the old configuration set
    ModelParameterMgr.restoreModels;
    ModelParameterMgr.closeModels;
    throwAsCaller(Ex);
end

% Get the tunable blocks
[ValidBlockStruct,BlockTree] = utFindTunableBlocks(linutil,ModelParameterMgr);
this.ValidBlockStruct = ValidBlockStruct;
this.BlockTree = BlockTree;

% Get the selectable scalar signals
this.SignalTree = utFindSISOSignals(linutil,ModelParameterMgr);

ModelParameterMgr.term;
% Restore the old configuration set
ModelParameterMgr.restoreModels;
ModelParameterMgr.closeModels;

% Create the node label
this.Label = xlate('Simulink Compensator Design Task');
% Store the model name
this.Model = model;

% Determine if there are any loop openings in the IOs
indopenloop = find(strcmp(get(newios,{'OpenLoop'}),'on'));
if any(indopenloop)
    set(newios(indopenloop),'OpenLoop','off');
    str = ['In a Simulink Compensator Design Task only the input ',...
           'and output linearization points will be used as ',...
           'closed-loop signals.  Any open-loop points that are specified ',...
           'in the model will be ignored.'];
    warndlg(xlate(str),...
              xlate('Simulink Control Design'),'modal');
    setlinio(this.Model,newios);
end

this.IOData = newios;

% Node name is editable
this.Editable = 1;
this.AllowsChildren = 1;
% Set the resources
this.Resources = 'com.mathworks.toolbox.slcontrol.resources.SimulinkCompensatorDesignTask';
% Set the icon
this.Icon = fullfile('toolbox', 'shared', ...
                            'slcontrollib','resources', 'simulink_doc.gif');
                        
this.Handles = struct('Panels', [], 'Buttons', [], 'PopupMenuItems', []);

% Add required components
nodes = this.getDefaultNodes;
for i = 1:size(nodes,1)
  this.addNode(nodes(i));
end
