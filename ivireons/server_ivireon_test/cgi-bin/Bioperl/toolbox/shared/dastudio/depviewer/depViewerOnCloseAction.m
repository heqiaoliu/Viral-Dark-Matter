% Copyright 2009 The MathWorks, Inc.

function depViewerOnCloseAction(depviewID)
    manager    = DepViewer.DepViewerUIManager;
    ui         = manager.getUI(depviewID);
    uiactions  = DepViewerUIActions;
    uiactions.close(ui);
end
