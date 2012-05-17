 function setCovPathStatus(this, covPath)

%   Copyright 2009-2010 The MathWorks, Inc.
this.covPath = covPath;
if strcmpi(covPath,'/')
    status = DAStudio.message('Slvnv:simcoverage:allSubsystemsIncluded');
elseif isempty(covPath)
    status = '';
else
    status = DAStudio.message('Slvnv:simcoverage:oneSubsystemSelected', covPath);
end
if ishandle(this.m_dlg) 
    this.m_dlg.setWidgetValue('SlCov_CovSettings_covPath',status);
    this.m_dlg.enableApplyButton(true);
end
this.covPathStatus = status; 

