function [b, str] = postApply(this)

%   Copyright 2010 The MathWorks, Inc.

b = true;
str = '';

if ishandle(this.m_callerDlg)
    this.m_callerDlg.enableApplyButton(true);
end


