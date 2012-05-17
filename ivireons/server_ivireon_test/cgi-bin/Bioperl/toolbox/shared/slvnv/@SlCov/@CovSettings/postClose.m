function postClose(this)

%   Copyright 2010 The MathWorks, Inc.
if ishandle(this.covSubSysTree)
    delete(this.covSubSysTree);
end
if ishandle(this.reportSettingsDlg)
    delete(this.reportSettingsDlg);
end
SlCov.CovSettings.mdlRefClose(this);
