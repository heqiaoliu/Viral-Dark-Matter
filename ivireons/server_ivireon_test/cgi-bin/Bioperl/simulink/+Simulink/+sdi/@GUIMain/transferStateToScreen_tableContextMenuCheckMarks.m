function transferStateToScreen_tableContextMenuCheckMarks(this)
    %   Copyright 2010 The MathWorks, Inc.
    
    tabType = this.GetTabType;
    switch tabType
        case Simulink.sdi.GUITabType.InspectSignals
            runOnOff  = BoolToOnOff(this.runVisibleInsp);
            BlockSourceOnOff = BoolToOnOff(this.colorVisibleInsp);
            absTolOnOff = BoolToOnOff(this.absTolVisibleInsp);
            relTolOnOff = BoolToOnOff(this.relTolVisibleInsp);
            syncOnOff = BoolToOnOff(this.syncVisibleInsp);
            interpOnOff = BoolToOnOff(this.interpVisibleInsp);
            channelOnOff = BoolToOnOff(this.channelVisibleInsp);
            SignalLabelOnOff = BoolToOnOff(this.dataSourceVisibleInsp);
            SignalDimsOnOff  = BoolToOnOff(this.modelSourceVisibleInsp);
            PortIndexOnOff   = BoolToOnOff(this.signalLabelVisibleInsp);
            rootOnOff = BoolToOnOff(this.rootVisibleInsp);
            timeOnOff = BoolToOnOff(this.timeVisibleInsp);
            portOnOff = BoolToOnOff(this.portVisibleInsp);
            dimOnOff  = BoolToOnOff(this.dimVisibleInsp);
            
        case Simulink.sdi.GUITabType.CompareSignals
            runOnOff  = BoolToOnOff(this.runVisibleCompSig);
            BlockSourceOnOff = BoolToOnOff(this.colorVisibleCompSig);
            absTolOnOff = BoolToOnOff(this.absTolVisibleCompSig);
            relTolOnOff = BoolToOnOff(this.relTolVisibleCompSig);
            syncOnOff = BoolToOnOff(this.syncVisibleCompSig);
            interpOnOff = BoolToOnOff(this.interpVisibleCompSig);
            channelOnOff = BoolToOnOff(this.channelVisibleCompSig);
            SignalLabelOnOff = BoolToOnOff(this.dataSourceVisibleCompSig);
            SignalDimsOnOff  = BoolToOnOff(this.modelSourceVisibleCompSig);
            PortIndexOnOff   = BoolToOnOff(this.signalLabelVisibleCompSig);
            rootOnOff = BoolToOnOff(this.rootVisibleCompSig);
            timeOnOff = BoolToOnOff(this.timeVisibleCompSig);
            portOnOff = BoolToOnOff(this.portVisibleCompSig);
            dimOnOff  = BoolToOnOff(this.dimVisibleCompSig);             
    end
     
    if (tabType == Simulink.sdi.GUITabType.InspectSignals || ...
        tabType == Simulink.sdi.GUITabType.CompareSignals)
        % Set menu checkmarks
        set(this.tableContextMenuRun,  'Checked', runOnOff);
        set(this.tableContextMenuColor, 'Checked', BlockSourceOnOff);
        set(this.tableContextMenuDataSource, 'Checked', SignalLabelOnOff);
        set(this.tableContextMenuModelSource,  'Checked', SignalDimsOnOff);
        set(this.tableContextMenuSignalLabel,   'Checked', PortIndexOnOff);
        set(this.tableContextMenuRoot,  'Checked', rootOnOff);
        set(this.tableContextMenuTimeSource,  'Checked', timeOnOff);
        set(this.tableContextMenuPort,  'Checked', portOnOff);
        set(this.tableContextMenuDim,  'Checked', dimOnOff);  
        set(this.tableContextMenuAbsTol, 'Checked', absTolOnOff);
        set(this.tableContextMenuRelTol, 'Checked', relTolOnOff);
        set(this.tableContextMenuSync, 'Checked', syncOnOff);
        set(this.tableContextMenuInterp, 'Checked', interpOnOff);
        set(this.tableContextMenuChannel, 'Checked', channelOnOff);
    end
end

function OnOff = BoolToOnOff(bool)
    if bool, OnOff = 'on';
    else     OnOff = 'off';
    end
end
