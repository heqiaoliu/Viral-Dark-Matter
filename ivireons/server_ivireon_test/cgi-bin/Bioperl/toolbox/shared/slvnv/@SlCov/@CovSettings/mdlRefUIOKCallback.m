 function mdlRefUIOKCallback(this, mdlRefUI)

%   Copyright 2010 The MathWorks, Inc.
    this.covModelRefEnable = mdlRefUI.m_CovModelRefEnable;
    this.covModelRefExcluded = mdlRefUI.m_CovModelRefExcluded;
    this.recordCoverage = strcmpi(mdlRefUI.m_RecordCoverage,'on');
    
    this.setMdlRefSelStatus