function refreshSpecPanel(this,ForceUpdate)
%REFRESHSPECPANEL  Refresh the Specification panel of a tuning method.

%   Author(s): R. Chen
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $  $Date: 2010/05/10 16:59:02 $

if nargin == 1
    ForceUpdate = false;
end

Handles = this.SpecPanelHandles;

% Clear message panel
this.showMessagePanel(false);

%% when no tunable compensator is available, use blank panel
if isempty(this.TunedCompList)
    awtinvoke(this.DesignButton,'setEnabled(Z)',false);                
    awtinvoke(Handles.Panel.getLayout,'show(Ljava.awt.Container;Ljava.lang.String;)',...
        Handles.Panel,java.lang.String('Blank'));
%% when constrains or fixed dynamics exist in the tunable compensator, use
%% textinfo panel, otherwise show nominal panel
else
    compensator = this.TunedCompList(this.IdxC);
    isConstraint = ~isTunable(compensator) || (~isempty(compensator.Constraints) && ...
        (~compensator.Constraints.isStaticGainTunable || ...
        ~isinf(compensator.Constraints.MaxZeros)));
    isFixedDynamics = ~isempty(compensator.FixedDynamics) && ~isstatic(compensator.FixedDynamics);
    % show textinfo panel
    if isConstraint
        awtinvoke(this.DesignButton,'setEnabled(Z)',false);                
        awtinvoke(Handles.Panel.getLayout,'show(Ljava.awt.Container;Ljava.lang.String;)',...
            Handles.Panel,java.lang.String('Constrained'));
    elseif isFixedDynamics
        awtinvoke(this.DesignButton,'setEnabled(Z)',false);                
        awtinvoke(Handles.Panel.getLayout,'show(Ljava.awt.Container;Ljava.lang.String;)',...
            Handles.Panel,java.lang.String('FixedDynamics'));    
    %% show nominal panel
    else
        % when loopdata is changed, refresh open loop plant and fixed dynamics
        PlantChanged = false;
        if this.IsOpenLoopPlantDirty
            % update open loop plant
            PlantChanged = this.utSyncOpenLoopPlant;
            % reset dirty flag
            this.IsOpenLoopPlantDirty = false;
        end
        if isa(this.OpenLoopPlant,'frd')
            awtinvoke(this.SpecPanelHandles.Panel.getLayout,'show(Ljava.awt.Container;Ljava.lang.String;)',...
                this.SpecPanelHandles.Panel,java.lang.String('FRDPlant'));
            awtinvoke(this.DesignButton,'setEnabled(Z)',false);
        elseif isproper(this.OpenLoopPlant) 
            % Show message panel that the delay is being approximated
            if hasdelay(this.OpenLoopPlant) && isequal(getTs(this.OpenLoop),0)
                this.showMessagePanel(true,utCreateApproxMessagePanel(this));
            elseif isUncertain(this.LoopData.Plant)
                this.showMessagePanel(true,utCreateNominalModelMessagePanel(this));
            end
            awtinvoke(this.DesignButton,'setEnabled(Z)',true);
            awtinvoke(Handles.Panel.getLayout,'show(Ljava.awt.Container;Ljava.lang.String;)',...
                Handles.Panel,java.lang.String('Nominal'));
            if PlantChanged || ForceUpdate
                localRefreshSpecPanel(this,Handles);
            end
        else
            % Improper Plant
            awtinvoke(this.DesignButton,'setEnabled(Z)',false);
            awtinvoke(Handles.Panel.getLayout,'show(Ljava.awt.Container;Ljava.lang.String;)',...
                Handles.Panel,java.lang.String('ImproperPlant'));
            
        end

    end
end

function localRefreshSpecPanel(this,Handles)
%% refresh tau
Model = this.utApproxDelay(-this.OpenLoopPlant);
IsStable = isstable(Model);
if IsStable
    s = stepinfo(Model);
    tau = s.SettlingTime/20;
    if isnan(tau) || (tau<=0)
        tau = 1;
    end
else
    % REVISIT: need to initialized to the minimum tau value to make
    % sure that C is stable
    tau = 1;
end
awtinvoke(Handles.Edit_DominantTimeConstant,'setText(Ljava/lang/String;)',java.lang.String(num2str(tau)));
%% refresh order
compensator = this.TunedCompList(this.IdxC);
if isTunable(compensator) && ~isempty(compensator.Constraints) && ~isinf(compensator.Constraints.MaxPoles)
    localResetCompensatorOrder(Handles,compensator.Constraints.MaxPoles);
else
    localResetCompensatorOrder(Handles,localCalcOrder(Model));
end

%% initialize order slider and edit box
function localResetCompensatorOrder(Handles,Order)
awtinvoke(Handles.Slider_CompensatorOrder,'setMinimum(I)',1);
awtinvoke(Handles.Slider_CompensatorOrder,'setMaximum(I)',Order);
awtinvoke(Handles.Slider_CompensatorOrder,'setValue(I)',Order);
labelTable = awtinvoke(Handles.Slider_CompensatorOrder,'getLabelTable()');
awtinvoke(labelTable,'clear');
awtinvoke(labelTable,'put(Ljava.lang.Object;Ljava.lang.Object;)',java.lang.Integer(1),javaObjectEDT('javax.swing.JLabel','1'));
awtinvoke(labelTable,'put(Ljava.lang.Object;Ljava.lang.Object;)',java.lang.Integer(Order),javaObjectEDT('javax.swing.JLabel',num2str(Order)));
awtinvoke(Handles.Slider_CompensatorOrder,'setLabelTable(Ljava.util.Dictionary;)',labelTable);
awtinvoke(Handles.Slider_CompensatorOrder,'setMajorTickSpacing(I)',Order-1);
awtinvoke(Handles.Slider_CompensatorOrder,'setMinorTickSpacing(I)',(Order-1)/4);    
awtinvoke(Handles.Slider_CompensatorOrder,'setPaintTicks(Z)',true);
awtinvoke(Handles.Slider_CompensatorOrder,'setPaintLabels(Z)',true);
awtinvoke(Handles.Slider_CompensatorOrder,'setPaintTrack(Z)',true);
awtinvoke(Handles.Edit_CompensatorOrder,'setValue',java.lang.Integer(Order));

function Order = localCalcOrder(Model)
[Zero,Pole,Gain,Ts] = zpkdata(Model,'v');
Ts = abs(Ts);
if Ts==0
    indRHPzero = (real(Zero)>0);                        % indices of open RHP zeros
    indRHPpole = (real(Pole)>0);                        % indices of open RHP poles
    indIntegrator = (real(Pole)==0)&(imag(Pole)==0);    % indices of integrators
    NumRHPzeros = sum(indRHPzero);                      % number of open RHP zeros 
    NumRHPpoles = sum(indRHPpole);                      % number of open RHP poles 
    NumIntegrator = sum(indIntegrator);                 % number of integrators
    IsPlantStable = (NumRHPpoles+NumIntegrator==0);
    IsPlantMP = (NumRHPzeros==0);
    if IsPlantStable
        Order = order(Model)+1;
    elseif IsPlantMP
        Order = order(Model)+NumRHPpoles+NumIntegrator+1;
    else
        Order = order(Model)+NumRHPpoles+NumIntegrator+NumRHPzeros+1;
    end
else
    indRHPzero = (abs(Zero)>1);                         % indices of open RHP zeros
    indRHPpole = (abs(Pole)>1);                         % indices of open RHP poles
    indIntegrator = (real(Pole)==1)&(imag(Pole)==0);    % indices of integrators
    NumRHPzeros = sum(indRHPzero);                      % number of open RHP zeros 
    NumRHPpoles = sum(indRHPpole);                      % number of open RHP poles 
    NumIntegrator = sum(indIntegrator);                 % number of integrators
    IsPlantStable = (NumRHPpoles+NumIntegrator==0);
    IsPlantMP = (NumRHPzeros==0);
    if IsPlantStable
        Order = order(Model)+length(Zero)+1;
    elseif IsPlantMP
        Order = order(Model)+1;
    else
        Order = order(Model)+length(Zero)+sum(real(Zero)<0)*2+(NumRHPpoles+NumIntegrator)*2+NumRHPzeros+1;
    end
end


