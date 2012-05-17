 function mdlRefBrowseCallback(this)

%   Copyright 2009-2010 The MathWorks, Inc.
covMdlRefSelUIH = handle(this.getCovMdlRefSelUIH);
%if it's invoked twice, e.g click twice on the browse button

if ~isempty(covMdlRefSelUIH) && ishandle(covMdlRefSelUIH) && ishandle(covMdlRefSelUIH.m_editor.getDialog)
    covMdlRefSelUIH.m_editor.show;
else
    if this.getCovEnabled
        RecordCoverage = 'on';
    else
        RecordCoverage = 'off';
    end

    this.m_covMdlRefSelUIH = cv.ModelRefSelectorUI(this.modelH, RecordCoverage, this.CovModelRefEnable, this.CovModelRefExcluded);
    this.m_covMdlRefSelUIH.m_panelH = []; 
    this.m_covMdlRefSelUIH.m_dlg = this;
end
