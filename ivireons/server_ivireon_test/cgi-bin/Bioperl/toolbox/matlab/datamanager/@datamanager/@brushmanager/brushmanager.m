function h = brushmanager

% Brushmanager is a singleton
mlock
persistent bManager;
if isempty(bManager)
    bManager = datamanager.brushmanager;    
    com.mathworks.page.datamgr.brushing.ArrayEditorManager.addArrayEditorListener;
end
bManager.UseMCOS = feature('HGUsingMATLABClasses');
h = bManager;




