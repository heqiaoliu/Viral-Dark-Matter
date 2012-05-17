
%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $ $Date: 2008/12/04 23:26:40 $
classdef (Hidden = true) OperatingPointSearchOptionsPanel < slctrlguis.util.AbstractPanel
properties(SetAccess='private',GetAccess = 'public', SetObservable = true)
        linopts;
        linoptlistener;
    end
    methods
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function createPeer(obj)
            if isempty(obj.getPeer)
                obj.setPeer(com.mathworks.toolbox.slcontrol.OptionsPanels.OperatingPointSearchOptionsPanelPeer);
                installDefaultListeners(obj);
            end
        end
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = init(obj,linopts)
            obj.linopts = linopts;
            if isempty(obj.getPeer)
                createPeer(obj)
            end
            % Listener for the optimizer type change
            obj.linoptlistener = handle.listener(obj.linopts,'OptimizerTypeChanged',@(es,ed)LocalOptimizerTypeChanged(obj,ed));
            setData(obj);
        end
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function setData(obj)
            Data = com.mathworks.toolbox.slcontrol.OptionsPanels.OperatingPointSearchOptionsData;
            Data.Method = obj.linopts.OptimizerType;
            LocalGetOptimizerOptions(obj,Data)
            obj.getPeer.setData(Data);
        end
    end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function installDefaultListeners(obj)
% Call the getPanel method to ensure that the panel has been
% created.
obj.getPanel;
Peer = obj.getPeer;
addCallbackListener(obj,Peer.getDataCallback,{@LocalDataCallback,obj})
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalDataCallback(es,ed,obj)
OptimizerType = char(ed.Method);
OldOptimizerType = obj.linopts.OptimizerType;
if ~strcmp(OptimizerType,OldOptimizerType)
    % If the optimizer has changed the defaults may have
    % changed.
    try
        obj.linopts.OptimizerType = OptimizerType;
    catch Ex
        if ~license('test','Optimization_Toolbox')
            errordlg(ctrlMsgUtils.message('Slcontrol:operpointtask:LSQNonlinRequiresOptim'),...
                'Simulink Control Design')
            return
        end
    end        
    eventData = ctrluis.dataevent(obj.linopts,'OptimizerTypeChanged',OptimizerType);
    send(obj.linopts,'OptimizerTypeChanged',eventData)
    obj.getPeer.enableMethodSpecificFields(OptimizerType);
    return
end
obj.linopts.DisplayReport = char(ed.DisplayReport);
optimoptions = obj.linopts.OptimizationOptions;
optimoptions.DiffMaxChange = char(ed.DiffMaxChange);
optimoptions.DiffMinChange = char(ed.DiffMinChange);
optimoptions.MaxFunEvals = char(ed.MaxFunEvals);
optimoptions.MaxIter = char(ed.MaxIter);
optimoptions.TolFun = char(ed.TolFun);
optimoptions.TolX = char(ed.TolX);
optimoptions.TolCon = char(ed.TolCon);
if strcmp(char(ed.LargeScale),'on')
    if ~license('test','Optimization_Toolbox')
        errordlg(ctrlMsgUtils.message('Slcontrol:operpointtask:LargeScaleRequiresOptim'),...
            'Simulink Control Design')
        return
    end
end
if strcmp(OptimizerType,'lsqnonlin')
    if strcmp(char(ed.LargeScale),'on')
        optimoptions.Algorithm = 'trust-region-reflective';
    else
        optimoptions.Algorithm = 'levenberg-marquardt';
    end
else    
    optimoptions.LargeScale = char(ed.LargeScale);
end

if ed.Jacobian
    optimoptions.Jacobian = 'on';
else
    optimoptions.Jacobian = 'off';
end
obj.linopts.OptimizationOptions = optimoptions;
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalGetOptimizerOptions(obj,Data)
optimoptions = obj.linopts.OptimizationOptions;
Data.DiffMaxChange = LocalConvertChar(optimoptions.DiffMaxChange);
Data.DiffMinChange = LocalConvertChar(optimoptions.DiffMinChange);
Data.MaxFunEvals = LocalConvertChar(optimoptions.MaxFunEvals);
Data.MaxIter = LocalConvertChar(optimoptions.MaxIter);
Data.TolFun = LocalConvertChar(optimoptions.TolFun);
Data.TolX = LocalConvertChar(optimoptions.TolX);
Data.TolCon = LocalConvertChar(optimoptions.TolCon);
if strcmp(optimoptions.Jacobian,'on')
    Data.Jacobian = true;
else
    Data.Jacobian = false;
end

if strcmp(obj.linopts.OptimizerType,'lsqnonlin')
    if strcmp(obj.linopts.OptimizationOptions,'trust-region-reflective')
        Data.LargeScale = 'on';
    else
        Data.LargeScale = 'off';
    end
else
    if isempty(optimoptions.LargeScale)
        Data.LargeScale = '';
    else
        Data.LargeScale = char(optimoptions.LargeScale);
    end
end

Data.DisplayReport = obj.linopts.DisplayReport;
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalOptimizerTypeChanged(obj,ed)
    Data = com.mathworks.toolbox.slcontrol.OptionsPanels.OperatingPointSearchOptionsData;
    Data.Method = ed.Data;
    LocalGetOptimizerOptions(obj,Data)
    obj.getPeer.setData(Data);
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = LocalConvertChar(val)
    if ischar(val)
        str = val;
    else
        str = num2str(val);
    end        
end
