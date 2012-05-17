
%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $ $Date: 2008/10/31 07:35:38 $
classdef (Hidden = true) LinearizationOptionsPanel < slctrlguis.util.AbstractPanel
properties(SetAccess='private',GetAccess = 'public', SetObservable = true)
        linopts;
        StoreDiagnostics;
    end
    methods
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function createPeer(obj)
            if isempty(obj.getPeer)
                obj.setPeer(com.mathworks.toolbox.slcontrol.OptionsPanels.LinearizationOptionsPanelPeer);
                installDefaultListeners(obj);
            end
        end
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = init(obj,linopts,storediag)
            obj.linopts = linopts;
            obj.StoreDiagnostics = storediag;
            if isempty(obj.getPeer)
                createPeer(obj)
            end
            setData(obj);
        end
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function setData(obj)
            %LinearizationAlgorithm
            algorithm = obj.linopts.LinearizationAlgorithm;
            obj.getPeer.setAlgorithm(algorithm);
            %SampleTime
            sampletime = obj.linopts.SampleTime;
            if ~ischar(sampletime)
                sampletime = num2str(sampletime);
            end
            obj.getPeer.setSampleTime(sampletime);
            %UseFullBlockNameLabels
            usefullname = obj.linopts.UseFullBlockNameLabels;
            obj.getPeer.setUseFullName(usefullname);
            %UseBusSignalNameLabels
            usebusname = obj.linopts.UseBusSignalLabels;
            obj.getPeer.setUseBusSignalName(usebusname);
            %BlockReduction
            blockreduction = obj.linopts.BlockReduction;
            obj.getPeer.setEnableBlockReduction(blockreduction);
            %IgnoreDiscreteStates
            ignorediscrete = obj.linopts.IgnoreDiscreteStates;
            obj.getPeer.setIgnoreDiscrete(ignorediscrete);
            %UseExactDelayModel
            exactdelay = obj.linopts.UseExactDelayModel;
            obj.getPeer.setReturnExactDelay(exactdelay);
            %PreWarpFreq
            prewarpfreq = obj.linopts.PreWarpFreq;
            if ~ischar(prewarpfreq);
                prewarpfreq = num2str(prewarpfreq);
            end
            obj.getPeer.setPreWarpFreq(prewarpfreq);
            %NumericalPertRel
            relpertlevel = obj.linopts.NumericalPertRel;
            if ~ischar(relpertlevel)
                relpertlevel = num2str(relpertlevel);
            end
            obj.getPeer.setRelPertLevel(relpertlevel);
            %NumericalXPert
            xpertlevel = obj.linopts.NumericalXPert;
            if ~ischar(xpertlevel)
                xpertlevel = num2str(xpertlevel);
            end
            obj.getPeer.setXPertLevel(xpertlevel);
            %NumericalUPert
            upertlevel = obj.linopts.NumericalUPert;
            if ~ischar(upertlevel)
                upertlevel = num2str(upertlevel);
            end
            obj.getPeer.setUPertLevel(upertlevel);
            %RateConversionMethod
            convmethod = obj.linopts.RateConversionMethod;
            obj.getPeer.setConvMethod(convmethod);
            %StoreDiagnostics
            obj.getPeer.setStoreDiag(obj.StoreDiagnostics);            
        end
    end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function installDefaultListeners(obj)
% Call the getPanel method to ensure that the panel has been
% created.
obj.getPanel;
Peer = obj.getPeer;
addCallbackListener(obj,Peer.getComboBoxCallback,{@LocalComboBoxCallback,obj})
addCallbackListener(obj,Peer.getEditFieldCallback,{@LocalEditFieldCallback,obj})
addCallbackListener(obj,Peer.getCheckBoxCallback,{@LocalCheckBoxCallback,obj})
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalComboBoxCallback(es,ed,obj)
property = char(ed.property);
data = char(ed.data);
obj.linopts.(property) = data;
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalEditFieldCallback(es,ed,obj)
property = char(ed.property);
obj.linopts.(property) = char(ed.data);
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalCheckBoxCallback(es,ed,obj)
property = char(ed.property);
data = char(ed.data);
if strcmp(property,'StoreDiagnostics')
    obj.StoreDiagnostics = data;
else
    obj.linopts.(property) = data;
end
end