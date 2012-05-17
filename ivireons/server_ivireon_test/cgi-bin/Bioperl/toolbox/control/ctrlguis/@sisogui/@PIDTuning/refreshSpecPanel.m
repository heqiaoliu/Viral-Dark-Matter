function refreshSpecPanel(this,ForceUpdate)
%REFRESHSPECPANEL  Refresh the Specification panel of a tuning method.

%   Author(s): R. Chen
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.7 $  $Date: 2010/05/10 16:59:06 $

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
else
    % when the tunable compensator has constraints, use textinfo panel
    compensator = this.TunedCompList(this.IdxC);
    isConstraint = localCheckConstraintsPID(compensator);
    if isConstraint
        awtinvoke(this.DesignButton,'setEnabled(Z)',false);
        awtinvoke(Handles.Panel.getLayout,'show(Ljava.awt.Container;Ljava.lang.String;)',...
            Handles.Panel,java.lang.String('Constrained'));
    else
        PlantChanged = false;
        % when loopdata is changed, refresh open loop plant and fixed dynamics
        if this.IsOpenLoopPlantDirty
            % update open loop plant
            PlantChanged = this.utSyncOpenLoopPlant;
            % reset dirty flag
            this.IsOpenLoopPlantDirty = false;
        end
        
        if isproper(this.OpenLoopPlant)
            % Show message panel that the nominal model is being tuned
            if isUncertain(this.LoopData.Plant)
                this.showMessagePanel(true,utCreateNominalModelMessagePanel(this));
            end
            awtinvoke(this.DesignButton,'setEnabled(Z)',true);
            awtinvoke(Handles.Panel.getLayout,'show(Ljava.awt.Container;Ljava.lang.String;)',...
                Handles.Panel,java.lang.String('Nominal'));
            if PlantChanged || ForceUpdate
                localRefreshSpecPanel(this);
            end
        else
            % Improper Plant
            awtinvoke(this.DesignButton,'setEnabled(Z)',false);
            awtinvoke(Handles.Panel.getLayout,'show(Ljava.awt.Container;Ljava.lang.String;)',...
                Handles.Panel,java.lang.String('ImproperPlant'));
        end
    end
end

function isConstraint = localCheckConstraintsPID(compensator)
if isTunable(compensator)
    if isempty(compensator.Constraints)
        order = inf;
    else
        order = compensator.Constraints.MaxPoles;
    end
    isConstraint = ~isempty(compensator.Constraints) && ...
        (~compensator.Constraints.isStaticGainTunable || ...
        (compensator.Constraints.MaxZeros<order));
else
    isConstraint = true;
end

function localRefreshSpecPanel(this)
%% for fastdesign: reset tuning components
utUpdateFastDesign(this);
