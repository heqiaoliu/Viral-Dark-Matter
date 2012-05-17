 function mdlRefRecordCoverageUpdate(this)

%   Copyright 2010 The MathWorks, Inc.

covMdlRefSelUIH = handle(this.getCovMdlRefSelUIH);
if  ~isempty(covMdlRefSelUIH)  && ishandle(covMdlRefSelUIH) && ...
    ishandle(covMdlRefSelUIH.m_editor) && ~isempty(covMdlRefSelUIH.m_editor.getDialog)
    covMdlRefSelUIH.set_root_enabled_status;
end
