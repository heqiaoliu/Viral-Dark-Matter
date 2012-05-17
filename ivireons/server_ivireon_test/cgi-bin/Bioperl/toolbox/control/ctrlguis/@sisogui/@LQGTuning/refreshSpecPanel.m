function refreshSpecPanel(this,ForceUpdate)
%REFRESHSPECPANEL  Refresh the Specification panel of a tuning method.

%   Author(s): R. Chen
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $  $Date: 2010/05/10 16:59:03 $

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
        PlantChanged = false;
        % when loopdata is changed, refresh open loop plant and
        % fixed dynamics
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
            awtinvoke(this.DesignButton,'setEnabled(Z)',false);
            awtinvoke(Handles.Panel.getLayout,'show(Ljava.awt.Container;Ljava.lang.String;)',...
                Handles.Panel,java.lang.String('ImproperPlant'));
        end
    end
end

function localRefreshSpecPanel(this,Handles)
%% refresh order
Model = this.utApproxDelay(this.OpenLoopPlant);
compensator = this.TunedCompList(this.IdxC);
if isTunable(compensator) && ~isempty(compensator.Constraints) && ~isinf(compensator.Constraints.MaxPoles)
    localResetCompensatorOrder(Handles,compensator.Constraints.MaxPoles);
else
    localResetCompensatorOrder(Handles,order(Model)+1);
end

%% initialize order slider and edit box
function localResetCompensatorOrder(Handles,Order)

Handles.Slider_CompensatorOrder.setMinimum(1);
Handles.Slider_CompensatorOrder.setMaximum(Order);
Handles.Slider_CompensatorOrder.setValue(Order);
labelTable = javaObjectEDT(Handles.Slider_CompensatorOrder.getLabelTable());
labelTable.clear;
labelTable.put(java.lang.Integer(1),javaObjectEDT('javax.swing.JLabel','       1       '));
labelTable.put(java.lang.Integer(Order),javaObjectEDT('javax.swing.JLabel',['       ' num2str(Order) '       ']));
Handles.Slider_CompensatorOrder.setLabelTable(labelTable);
Handles.Slider_CompensatorOrder.setMajorTickSpacing(Order-1);
Handles.Slider_CompensatorOrder.setMinorTickSpacing((Order-1)/4);    
Handles.Slider_CompensatorOrder.setPaintTicks(true);
Handles.Slider_CompensatorOrder.setPaintLabels(true);
Handles.Slider_CompensatorOrder.setPaintTrack(true);
Handles.Edit_CompensatorOrder.setValue(java.lang.Integer(Order));

