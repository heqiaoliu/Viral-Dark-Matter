function refreshSpecPanel(this,ForceUpdate)
%REFRESHSPECPANEL  Refresh the Specification panel of the loopsyn tuning method.

%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $  $Date: 2010/05/10 16:59:04 $

if nargin == 1
    ForceUpdate = false;
end

%% Determine which card panel to display
% Clear Message Panel
this.showMessagePanel(false);

if isempty(this.TunedCompList) || isequal(this.idxC,0)
    % No compensators in list show blank card
    awtinvoke(this.DesignButton,'setEnabled(Z)',false);
    awtinvoke(Handles.Panel.getLayout,'show(Ljava.awt.Container;Ljava.lang.String;)',...
        Handles.Panel,java.lang.String('BlankCard'))

elseif isempty(ver('robust')) || (~isempty(ver('robust')) && ~this.TestRobustLicense)
    % Robust toolbox is not licensed
    % Disable design button and display Robust toolbox required panel
    awtinvoke(this.DesignButton,'setEnabled(Z)',false);
    awtinvoke(this.SpecPanelHandles.Panel.getLayout,'show(Ljava.awt.Container;Ljava.lang.String;)',...
        this.SpecPanelHandles.Panel,java.lang.String('RobustRequiredCard'));
    
  
elseif this.utIsTunable
    if this.IsOpenLoopPlantDirty
        % update plant
        this.utSyncOpenLoopPlant;
        % reset dirty flag
        this.IsOpenLoopPlantDirty = false;
    end
    if isa(this.OpenLoopPlant,'frd')
        awtinvoke(this.SpecPanelHandles.Panel.getLayout,'show(Ljava.awt.Container;Ljava.lang.String;)',...
            this.SpecPanelHandles.Panel,java.lang.String('FRDPlantCard'));
        awtinvoke(this.DesignButton,'setEnabled(Z)',false);
    elseif isproper(this.OpenLoopPlant)
        % Show message panel that the delay is being approximated
        if hasdelay(this.OpenLoopPlant) && isequal(getTs(this.OpenLoop),0)
            this.showMessagePanel(true,utCreateApproxMessagePanel(this));
        elseif isUncertain(this.LoopData.Plant)
            this.showMessagePanel(true,utCreateNominalModelMessagePanel(this));
        end
        if length(this.TuningPreference) < length(this.TunedCompList)
            % Update list of default values
            [TargetLoopStruct, TargetBandwidthStruct] = this.utCreateDefaultDataStruct;
            for ct = 1: (length(this.TunedCompList)-length(this.TuningPreference))
                this.TuningPreference{end+1,1} = 'TargetBandwidth';
                this.TargetLoopShapeData(end+1,1) = TargetLoopStruct;
                this.TargetBandwidthData(end+1,1) = TargetBandwidthStruct;
            end
        end

        % Compensator is tunable show specification panel
        awtinvoke(this.SpecPanelHandles.Panel.getLayout,'show(Ljava.awt.Container;Ljava.lang.String;)',...
            this.SpecPanelHandles.Panel,java.lang.String('TuningPanel'));

        awtinvoke(this.SpecPanelHandles.CardPanel.getLayout,'show(Ljava.awt.Container;Ljava.lang.String;)',...
            this.SpecPanelHandles.CardPanel,java.lang.String(this.TuningPreference{this.idxC}));
        if strcmp(this.TuningPreference{this.idxC},'TargetLoopShape')
            LocalRefreshTargetLoopShape(this)
        else
            LocalRefreshTargetBandwidth(this)
        end
        awtinvoke(this.DesignButton,'setEnabled(Z)',true);
    else
        awtinvoke(this.SpecPanelHandles.Panel.getLayout,'show(Ljava.awt.Container;Ljava.lang.String;)',...
            this.SpecPanelHandles.Panel,java.lang.String('ImproperPlantCard'));
        awtinvoke(this.DesignButton,'setEnabled(Z)',false);
    end
    
else
    % Compensator is constrained and/or has fixed dynamics
    % Disable design button and display not tunable panel
    awtinvoke(this.DesignButton,'setEnabled(Z)',false);
    awtinvoke(this.SpecPanelHandles.Panel.getLayout,'show(Ljava.awt.Container;Ljava.lang.String;)',...
        this.SpecPanelHandles.Panel,java.lang.String('NotTunableCard'));
end

 

%% initialize order slider and edit box
function LocalResetCompensatorOrder(Handles,Order,MaxOrder)
awtinvoke(Handles.Edit_CompensatorOrder,'setMinimum(I)',0);
awtinvoke(Handles.Edit_CompensatorOrder,'setMaximum(I)',MaxOrder);
awtinvoke(Handles.Edit_CompensatorOrder,'setValue(I)',Order);
labelTable = awtinvoke(Handles.Edit_CompensatorOrder,'getLabelTable()');
awtinvoke(labelTable,'clear');
awtinvoke(labelTable,'put(Ljava.lang.Object;Ljava.lang.Object;)',java.lang.Integer(0),javaObjectEDT('javax.swing.JLabel','0'));
awtinvoke(labelTable,'put(Ljava.lang.Object;Ljava.lang.Object;)',java.lang.Integer(MaxOrder),javaObjectEDT('javax.swing.JLabel',num2str(MaxOrder)));
awtinvoke(Handles.Edit_CompensatorOrder,'setLabelTable(Ljava.util.Dictionary;)',labelTable);
awtinvoke(Handles.Edit_CompensatorOrder,'setMajorTickSpacing(I)',max(MaxOrder,1));
awtinvoke(Handles.Edit_CompensatorOrder,'setMinorTickSpacing(I)',max(MaxOrder/4,1));    
awtinvoke(Handles.Edit_CompensatorOrder,'setPaintTicks(Z)',true);
awtinvoke(Handles.Edit_CompensatorOrder,'setPaintLabels(Z)',true);
awtinvoke(Handles.Edit_CompensatorOrder,'setPaintTrack(Z)',true);
awtinvoke(Handles.Edit_OrderField,'setValue',java.lang.Integer(Order));



%% Refresh TargetLoopShapePanel
function LocalRefreshTargetLoopShape(this)

TargetLoopShapeData = this.TargetLoopShapeData(this.idxC);
Handles = this.SpecPanelHandles.LoopShapeCardHandles;

awtinvoke(this.SpecPanelHandles.LoopShapeRadioBtn,'setSelected(Z)',true);

awtinvoke(Handles.Edit_TargetShape,'setText(Ljava.lang.String;)',TargetLoopShapeData.TargetLoopShape);
awtinvoke(Handles.Edit_FreqRange,'setText(Ljava.lang.String;)',TargetLoopShapeData.SpecifiedFreqRange);

MaxOrder = utComputeCompensatorOrder(this);
this.TargetLoopShapeData(this.idxC).TargetOrder = min(TargetLoopShapeData.TargetOrder,MaxOrder);
LocalResetCompensatorOrder(Handles,this.TargetLoopShapeData(this.idxC).TargetOrder,MaxOrder)



%% Refresh TargetBandwidthPanel
function LocalRefreshTargetBandwidth(this)

TargetBandwidthData = this.TargetBandwidthData(this.idxC);
Handles = this.SpecPanelHandles.BandwidthCardHandles;

awtinvoke(this.SpecPanelHandles.BandwidthRadioBtn,'setSelected(Z)',true);

awtinvoke(Handles.Edit_TargetBandwidth,'setText(Ljava.lang.String;)',TargetBandwidthData.TargetBandwidth);

MaxOrder = utComputeCompensatorOrder(this);
this.TargetBandwidthData(this.idxC).TargetOrder = min(TargetBandwidthData.TargetOrder,MaxOrder);
LocalResetCompensatorOrder(Handles,this.TargetBandwidthData(this.idxC).TargetOrder,MaxOrder)