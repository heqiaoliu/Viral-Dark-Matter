%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $ $Date: 2009/08/08 01:19:13 $
classdef (Hidden = true) LinearizationOperatingPointSearchDialog < slctrlguis.util.AbstractJavaGUI
properties(SetAccess='private',GetAccess = 'private', SetObservable = true)
        OperatingPointTaskNodeListener;
    end
    properties(SetAccess='private',GetAccess = 'public', SetObservable = true)
        OperatingPointSearchOptionsPanel;
        LinearizationOptionsPanel;
        StateOrderPanel; 
        OperatingPointTaskNode;
        SelectedTab = 'Linearization';
        linopts;
    end
    methods
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function createPeer(obj)
            if isempty(obj.getPeer)
                % Create the linearization options panel manager
                obj.LinearizationOptionsPanel = slctrlguis.optionspanels.LinearizationOptionsPanel;
                obj.LinearizationOptionsPanel.createPeer;
                
                % Create the operating point search options panel manager
                obj.OperatingPointSearchOptionsPanel = slctrlguis.optionspanels.OperatingPointSearchOptionsPanel;
                obj.OperatingPointSearchOptionsPanel.createPeer;

                % Create the state order panel
                obj.StateOrderPanel = slctrlguis.optionspanels.StateOrderPanel;
                obj.StateOrderPanel.createPeer;
                
                % Create the Java peer
                inputargs = {slctrlexplorer,...
                    obj.LinearizationOptionsPanel.getPeer,...    
                    obj.OperatingPointSearchOptionsPanel.getPeer,...
                    obj.StateOrderPanel.getPeer};
                obj.setPeer(com.mathworks.toolbox.slcontrol.OptionsDialogs.LinearizationOperatingPointSearchPeer(inputargs{:}));
                installDefaultListeners(obj);
            end
        end
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = init(obj,OperatingPointTaskNode)
            obj.OperatingPointTaskNode = OperatingPointTaskNode;
            obj.linopts = copy(OperatingPointTaskNode.Options);
            if isempty(obj.getPeer)
                createPeer(obj)
            end
            % Initialize the linearization options panel manager
            obj.LinearizationOptionsPanel.init(obj.linopts,obj.OperatingPointTaskNode.StoreDiagnosticsInspectorInfo);

            % Initialize the operating point search options panel manager
            obj.OperatingPointSearchOptionsPanel.init(obj.linopts);

            % Initialize the state order panel
            obj.StateOrderPanel.init(OperatingPointTaskNode.Model,OperatingPointTaskNode.StateOrderList,OperatingPointTaskNode.EnableStateOrdering);
            
            % Add listener for the case where the operating point task node is destroyed.
            obj.OperatingPointTaskNodeListener = handle.listener(OperatingPointTaskNode, 'ObjectBeingDestroyed',...
                                                        {@LocalCancelButtonCallback,obj});
        end
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function show(obj)
            obj.getPeer.show(slctrlexplorer);
        end
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function dispose(obj)
            obj.getPeer.dispose;
            delete(obj.OperatingPointTaskNodeListener);
            obj.OperatingPointTaskNode = [];
            obj.linopts = [];
            delete(obj);
        end
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function setSelectedTab(obj,Tab)
            obj.SelectedTab = Tab;
            obj.getPeer.setSelectedTab(Tab);
        end
    end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function installDefaultListeners(obj)
Peer = obj.getPeer;
addCallbackListener(obj,Peer.getHelpButtonCallback,{@LocalHelpButtonCallback,obj})
addCallbackListener(obj,Peer.getOKButtonCallback,{@LocalOKButtonCallback,obj})
addCallbackListener(obj,Peer.getCancelButtonCallback,{@LocalCancelButtonCallback,obj})
addCallbackListener(obj,Peer.getApplyButtonCallback,{@LocalApplyButtonCallback,obj})
addCallbackListener(obj,Peer.getTabSelectionCallback,{@LocalTabSelectionCallback,obj})
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalHelpButtonCallback(es,ed,obj)
% Launch the help browser
switch obj.SelectedTab
    case 'Linearization'
        scdguihelp('linearization_panel',obj.getPeer.getDialog)
    case 'OperatingPoint'
        scdguihelp('op_point_panel',obj.getPeer.getDialog)
    case 'StateOrder'
        scdguihelp('state_ordering_panel',obj.getPeer.getDialog)
end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalOKButtonCallback(es,ed,obj)
LocalApplyButtonCallback(es,ed,obj)
obj.dispose;
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalCancelButtonCallback(es,ed,obj)
obj.dispose;
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalApplyButtonCallback(es,ed,obj)

% Store the state string
obj.OperatingPointTaskNode.StateOrderList = obj.StateOrderPanel.StateOrderList;
obj.OperatingPointTaskNode.EnableStateOrdering = obj.StateOrderPanel.EnableStateOrdering;

% Store the linearization diagnostics/inspector enable flag
obj.OperatingPointTaskNode.StoreDiagnosticsInspectorInfo = obj.LinearizationOptionsPanel.StoreDiagnostics;

% Get the optimization settings structure
fn = fieldnames(obj.linopts);
for ct = 1:numel(fn)
    obj.OperatingPointTaskNode.Options.(fn{ct}) = obj.linopts.(fn{ct});
end
obj.OperatingPointTaskNode.setDirty;

end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalTabSelectionCallback(es,ed,obj)
obj.SelectedTab = char(ed);
end
