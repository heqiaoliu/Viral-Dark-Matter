 function filterFileBrowseCallback(this)

%   Copyright 2009-2010 The MathWorks, Inc.

ext = '*.mat';
text = 'Pick the filter file';

newFile = cv.FilterEditor.browseCallback(this.covFilter, ext, text);
  
if ~isempty(newFile)
    this.covFilter = newFile;
    var =  load(this.covFilter);
    this.filterState = var.slvnvFilterRules;
    this.m_dlg.enableApplyButton(true);
    this.m_dlg.refresh;
end
