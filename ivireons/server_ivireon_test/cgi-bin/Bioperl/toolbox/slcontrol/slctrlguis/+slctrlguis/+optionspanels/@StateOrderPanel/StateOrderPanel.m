
%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $ $Date: 2008/06/13 15:30:59 $
classdef (Hidden = true) StateOrderPanel < slctrlguis.util.AbstractPanel
properties(SetAccess='private',GetAccess = 'public', SetObservable = true)
        EnableStateOrdering;
        StateOrderList;
        Model;
    end
    methods
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function createPeer(obj)
            if isempty(obj.getPeer)
                obj.setPeer(com.mathworks.toolbox.slcontrol.OptionsPanels.StateOrderPanelPeer);
                installDefaultListeners(obj);
            end
        end
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = init(obj,Model,StateOrderList,EnableStateOrdering)
            obj.StateOrderList = StateOrderList;
            obj.EnableStateOrdering = EnableStateOrdering;
            obj.Model = Model;
            if isempty(obj.getPeer)
                createPeer(obj)
            end
            setData(obj);
        end
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function setData(obj)
            % Set the new data on the panel using javaMethodEDT to dispatch
            % on the MATLAB thread.
            if isempty(obj.StateOrderList)
                obj.getPeer.clearStateOrderList;
            else
                obj.getPeer.setStateOrderList(obj.StateOrderList);
            end
            obj.getPeer.setStateOrderingEnabled(obj.EnableStateOrdering);           
        end
    end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalStateOrderChangedCallback(es,ed,obj)
obj.StateOrderList = cell(ed);
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalStateOrderingEnableCallback(es,ed,obj)
obj.EnableStateOrdering = ed;
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalSyncWithModelCallback(es,ed,obj)

% Create a copy of the operating point object to sync with  
try
    op = operpoint(obj.Model);
catch Ex
    lastmsg = ltipack.utStripErrorHeader(Ex.message);
    str = ctrlMsgUtils.message('Slcontrol:linearizationtask:ModelCouldNotBeSynchronized',obj.Model,lastmsg);
    title = ctrlMsgUtils.message('Slcontrol:linearizationtask:ModelCouldNotBeSynchronizedTitle');
    errordlg(str,title)
    return
end

% Update the list box
obj.StateOrderList = OperatingConditions.updateStateOrder(op,obj.StateOrderList);
setData(obj);
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function installDefaultListeners(obj)
% Call the getPanel method to ensure that the panel has been
% created.
obj.getPanel;
Peer = obj.getPeer;
addCallbackListener(obj,Peer.getStateOrderCallback,{@LocalStateOrderChangedCallback,obj})
addCallbackListener(obj,Peer.getStateOrderingEnableCallback,{@LocalStateOrderingEnableCallback,obj})
addCallbackListener(obj,Peer.getSyncWithModelCallback,{@LocalSyncWithModelCallback,obj})
end
