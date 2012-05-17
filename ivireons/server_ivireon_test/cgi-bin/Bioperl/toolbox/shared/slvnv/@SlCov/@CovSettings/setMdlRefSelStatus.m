 function setMdlRefSelStatus(this)

%   Copyright 2010 The MathWorks, Inc.


    if strcmpi(this.covModelRefEnable,'filtered') &&  ~isempty(this.covModelRefExcluded)
        commas = length(strfind(this.covModelRefExcluded,','));
        this.mdlRefSelStatus = DAStudio.message('Slvnv:simcoverage:numOfExcludedModels', commas+1);
    else
        this.mdlRefSelStatus = DAStudio.message('Slvnv:simcoverage:allReferencedMdlsIncluded');
    end
    
    if ishandle(this.m_dlg)
         this.m_dlg.setWidgetValue('SlCov_CovSettings_mdlRefSelStatus', this.mdlRefSelStatus);
         this.m_dlg.enableApplyButton(true);
    end