function transferDataToScreen_ImportFromImportTo(this)

    % Copyright 2010 The MathWorks, Inc.

    IsBaseWS   = strcmp(this.BaseWSOrMAT,   'basews');
    IsMAT      = strcmp(this.BaseWSOrMAT,   'mat');
    IsNewRun   = strcmp(this.NewOrExistRun, 'new');
    IsExistRun = strcmp(this.NewOrExistRun, 'exist');
    
    % Set values
    set(this.ImportFromBaseRadio, 'Value',  IsBaseWS);
    set(this.ImportFromMATRadio,  'Value',  IsMAT);
    set(this.ImportFromMATEdit,   'String', this.MATFileName);
    set(this.ImportToNewRadio,    'Value',  IsNewRun);
    set(this.ImportToExistRadio,  'Value',  IsExistRun);
end