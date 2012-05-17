function SetEnable(this)

    % Copyright 2009-2010 The MathWorks, Inc.

    % Cache util class
    UT = Simulink.sdi.Util;

    % Only enable save if there are runs
    isAnyRunsBool = this.SDIEngine.getSignalCount() > 0;
    isDirtyAndAnyRuns = (isAnyRunsBool && this.dirty);
    isSaveAsEnabled = UT.BoolToOnOff(isAnyRunsBool);
    isSaveEnabled = UT.BoolToOnOff(isDirtyAndAnyRuns);

    % Set enable
    set(this.ToolbarButtonSave, 'Enable', isSaveEnabled);
    set(this.MainMenuSave,      'Enable', isSaveEnabled);
    set(this.MainMenuSaveAs,    'Enable', isSaveAsEnabled);
    
    if ~isAnyRunsBool
        set(this.HDialog, 'name', this.sd.MGTitle); 
    end
end