function setEnable(this)

    % Manage enable for all controls on dialog
    %
    % Copyright 2009-2010 The MathWorks, Inc.

    % Cache util class
    UT = Simulink.sdi.Util;
    
    % "Import from" section
    IsBaseWSBool   = strcmp(this.BaseWSOrMAT, 'basews');
    IsMATBool      = strcmp(this.BaseWSOrMAT, 'mat');
    IsBaseWSEnable = UT.BoolToOnOff(IsBaseWSBool);%#ok
    IsMATEnable    = UT.BoolToOnOff(IsMATBool);
    
    % "Import to" section
    IsNewRunBool       = strcmp(this.NewOrExistRun, 'new');%#ok
    IsExistRunBool     = strcmp(this.NewOrExistRun, 'exist');
    IsAnyRunsBool      = this.SDIEngine.getRunCount() > 0;
    IsAnyRunsEnable    = UT.BoolToOnOff(IsAnyRunsBool);
    IsExistComboEnable = UT.BoolToOnOff(IsAnyRunsBool && IsExistRunBool);
    
    % Set enable
    set(this.ImportFromMATLabel, 'Enable', IsMATEnable);
    set(this.ImportFromMATEdit,  'Enable', IsMATEnable);
    set(this.ImportToExistRadio, 'Enable', IsAnyRunsEnable)
    set(this.ImportToExistLabel, 'Enable', IsExistComboEnable);
    set(this.ImportToExistCombo, 'Enable', IsExistComboEnable);
    this.ImportFromMATButton.setEnabled(IsMATBool);
end