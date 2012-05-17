function transferDataToScreen_ContextMenu(this)

    % Copyright 2010 The MathWorks, Inc.

    % Cache util class
    UT = Simulink.sdi.Util;
    
    % Convert bools to "on" and "off" strings
    RootSourceOnOff  = UT.BoolToOnOff(this.RootSourceVisible);
    TimeSourceOnOff  = UT.BoolToOnOff(this.TimeSourceVisible);
    DataSourceOnOff  = UT.BoolToOnOff(this.DataSourceVisible);
    BlockSourceOnOff = UT.BoolToOnOff(this.BlockSourceVisible);
    ModelSourceOnOff = UT.BoolToOnOff(this.ModelSourceVisible);
    SignalLabelOnOff = UT.BoolToOnOff(this.SignalLabelVisible);
    SignalDimsOnOff  = UT.BoolToOnOff(this.SignalDimsVisible);
    PortIndexOnOff   = UT.BoolToOnOff(this.PortIndexVisible);
    
    % Set menu checkmarks
    set(this.ContextMenuRootSource,  'Checked', RootSourceOnOff);
    set(this.ContextMenuTimeSource,  'Checked', TimeSourceOnOff);
    set(this.ContextMenuDataSource,  'Checked', DataSourceOnOff);
    set(this.ContextMenuBlockSource, 'Checked', BlockSourceOnOff);
    set(this.ContextMenuModelSource, 'Checked', ModelSourceOnOff);
    set(this.ContextMenuSignalLabel, 'Checked', SignalLabelOnOff);
    set(this.ContextMenuSignalDims,  'Checked', SignalDimsOnOff);
    set(this.ContextMenuPortIndex,   'Checked', PortIndexOnOff);
end