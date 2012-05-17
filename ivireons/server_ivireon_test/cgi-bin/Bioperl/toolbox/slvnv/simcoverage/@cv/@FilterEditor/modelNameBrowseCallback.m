 function modelNameBrowseCallback(this)

%   Copyright 2009-2010 The MathWorks, Inc.

ext = '*.mdl';
text = 'Pick the modelfile';


newModel = cv.FilterEditor.browseCallback(this.modelName, ext, text);
  
if ~isempty(newFile)
    load_system(newModel);
    this.modelName = get_param(newModel, 'name');
    this.m_dlg.enableApplyButton(true);
    this.m_dlg.refresh;
end
