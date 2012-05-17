function TransferDataToScreen_ContextMenuCompareSig(this)
    % Convert bools to "on" and "off" strings

%   Copyright 2010 The MathWorks, Inc.

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
    
    % Set menu checkmarks
    set(this.contextMenuRunCompSig,  'Checked', runOnOff);
    set(this.contextMenuColorCompSig, 'Checked', BlockSourceOnOff);
    set(this.contextMenuAbsTolCompSig, 'Checked', absTolOnOff);
    set(this.contextMenuRelTolCompSig, 'Checked', relTolOnOff);
    set(this.contextMenuSyncCompSig, 'Checked', syncOnOff);
    set(this.contextMenuInterpCompSig, 'Checked', interpOnOff);
    set(this.contextMenuChannelCompSig, 'Checked', channelOnOff);
    set(this.contextMenuDataSourceCompSig, 'Checked', SignalLabelOnOff);
    set(this.contextMenuModelSourceCompSig,  'Checked', SignalDimsOnOff);
    set(this.contextMenuSignalLabelCompSig,   'Checked', PortIndexOnOff);
    set(this.contextMenuRootCompSig,  'Checked', rootOnOff);
    set(this.contextMenuTimeSourceCompSig,  'Checked', timeOnOff);
    set(this.contextMenuPortCompSig,  'Checked', portOnOff);
    set(this.contextMenuDimCompSig,  'Checked', dimOnOff);
    this.transferStateToScreen_tableContextMenuCheckMarks();
end

function OnOff = BoolToOnOff(bool)
    if bool, OnOff = 'on';
    else     OnOff = 'off';
    end
end