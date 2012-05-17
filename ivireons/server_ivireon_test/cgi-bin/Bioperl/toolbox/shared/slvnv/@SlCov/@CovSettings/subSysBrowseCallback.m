 function subSysBrowseCallback(this)

%   Copyright 2009-2010 The MathWorks, Inc.

if ~isempty(this.covSubSysTree) && ishandle(this.covSubSysTreeDlg)
    this.covSubSysTreeDlg.show; 
else
    this.covSubSysTreeDlg = DAStudio.Dialog(SlCov.CovSubSysTree(this));
end




