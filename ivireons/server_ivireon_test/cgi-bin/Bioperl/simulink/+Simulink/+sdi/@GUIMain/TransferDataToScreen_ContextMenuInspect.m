function TransferDataToScreen_ContextMenuInspect(this)
    % Convert bools to "on" and "off" strings

%   Copyright 2010 The MathWorks, Inc.

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
   
    % Set menu checkmarks
    set(this.contextMenuRun,  'Checked', runOnOff);
    set(this.contextMenuColor, 'Checked', BlockSourceOnOff);
    set(this.contextMenuAbsTol, 'Checked', absTolOnOff);
    set(this.contextMenuRelTol, 'Checked', relTolOnOff);
    set(this.contextMenuSync, 'Checked', syncOnOff);
    set(this.contextMenuInterp, 'Checked', interpOnOff);
    set(this.contextMenuChannel, 'Checked', channelOnOff);
    set(this.contextMenuDataSource, 'Checked', SignalLabelOnOff);
    set(this.contextMenuModelSource,  'Checked', SignalDimsOnOff);
    set(this.contextMenuSignalLabel,   'Checked', PortIndexOnOff);
    set(this.contextMenuRoot,  'Checked', rootOnOff);
    set(this.contextMenuTimeSource,  'Checked', timeOnOff);
    set(this.contextMenuPort,  'Checked', portOnOff);
    set(this.contextMenuDim,  'Checked', dimOnOff);
    this.transferStateToScreen_tableContextMenuCheckMarks();
end

function OnOff = BoolToOnOff(bool)
    if bool, OnOff = 'on';
    else     OnOff = 'off';
    end
end