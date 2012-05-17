function this = CovReportSettings(callerSource)

% Copyright 2010 The MathWorks, Inc.

this = SlCov.CovReportSettings;
this.m_callerDlg = callerSource.m_dlg;
this.m_callerSource = callerSource;
