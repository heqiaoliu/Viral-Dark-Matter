 function reportSettingsCallback(this)

%   Copyright 2009-2010 The MathWorks, Inc.

if  ~isempty(this.reportSettingsDlg) && ishandle(this.reportSettingsDlg)
    this.reportSettingsDlg.show; 
else
    this.reportSettingsDlg = DAStudio.Dialog(SlCov.CovReportSettings(this));
end




