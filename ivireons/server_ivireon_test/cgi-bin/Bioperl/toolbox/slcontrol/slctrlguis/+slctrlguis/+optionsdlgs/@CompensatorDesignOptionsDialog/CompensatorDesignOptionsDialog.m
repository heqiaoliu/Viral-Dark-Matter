%  Author(s): Erman Korkut 08-May-2009
%  Revised:
%  Copyright 2003-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/08/08 01:19:12 $
classdef (Hidden = true) CompensatorDesignOptionsDialog < slctrlguis.util.AbstractJavaGUI 
    properties(SetAccess='private',GetAccess = 'private', SetObservable = true)
        ControlDesignTaskNodeListener;
    end
    properties(SetAccess='private',GetAccess = 'public', SetObservable = true)
        ControlDesignTaskNode;
        OptionsStruct;
    end
    methods
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function createPeer(obj)
            if isempty(obj.getPeer)                
                % Create the Java peer
                inputargs = {slctrlexplorer};
                obj.setPeer(com.mathworks.toolbox.slcontrol.OptionsDialogs.CompensatorDesignOptionsPeer(inputargs{:}));
                installDefaultListeners(obj);
            end
        end
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = init(obj,ControlDesignTaskNode)
            obj.ControlDesignTaskNode = ControlDesignTaskNode;
            obj.OptionsStruct = ControlDesignTaskNode.OptionsStruct;
            if isempty(obj.getPeer)
                createPeer(obj)
            end
            % Initialize the linearization options panel manager
            setData(obj);
            % Add listener for the case where the operating point task node is destroyed.
            obj.ControlDesignTaskNodeListener = handle.listener(ControlDesignTaskNode, 'ObjectBeingDestroyed',...
                {@LocalCancelButtonCallback,obj});
        end
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function setData(obj)
            optsstruct = obj.OptionsStruct;
            %SampleTime
            sampletime = optsstruct.SampleTime;
            if ~ischar(sampletime)
                sampletime = num2str(sampletime);
            end
            obj.getPeer.setSampleTime(sampletime);
            %RateConversionMethod
            convmethod = optsstruct.RateConversionMethod;
            obj.getPeer.setConvMethod(convmethod);
            %PreWarpFreq
            prewarpfreq = optsstruct.PreWarpFreq;
            if ~ischar(prewarpfreq);
                prewarpfreq = num2str(prewarpfreq);
            end
            obj.getPeer.setPreWarpFreq(prewarpfreq);            
            %UseExactDelayModel
            exactdelay = optsstruct.UseExactDelayModel;
            obj.getPeer.setReturnExactDelay(exactdelay);
            %UseBusSignalNameLabels
            usebusname = optsstruct.UseBusSignalLabels;
            obj.getPeer.setUseBusSignalName(usebusname);
        end
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function show(obj)
            obj.getPeer.show(slctrlexplorer);
        end
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function dispose(obj)
            obj.getPeer.dispose;
            delete(obj.ControlDesignTaskNodeListener);
            obj.ControlDesignTaskNode = [];
            obj.OptionsStruct = [];
            delete(obj);
        end
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function setDirty(obj)
            obj.ControlDesignTaskNode.up.Dirty = 1;
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
addCallbackListener(obj,Peer.getComboBoxCallback,{@LocalComboBoxCallback,obj})
addCallbackListener(obj,Peer.getEditFieldCallback,{@LocalEditFieldCallback,obj})
addCallbackListener(obj,Peer.getCheckBoxCallback,{@LocalCheckBoxCallback,obj})
end

function LocalComboBoxCallback(es,ed,obj)
property = char(ed.property);
data = char(ed.data);
obj.OptionsStruct.(property) = data;
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalEditFieldCallback(es,ed,obj)
property = char(ed.property);
obj.OptionsStruct.(property) = char(ed.data);
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalCheckBoxCallback(es,ed,obj)
property = char(ed.property);
data = char(ed.data);
obj.OptionsStruct.(property) = data;
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalHelpButtonCallback(es,ed,obj)
% Launch the help browser
scdguihelp('control_linearization_options',obj.getPeer.getDialog)
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
obj.setDirty;
% Write the current structure to the control design node
obj.ControlDesignTaskNode.OptionsStruct = obj.OptionsStruct;
end

