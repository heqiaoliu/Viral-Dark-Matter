function h = linkplotmanager

% Linkplotmanager is a singleton
mlock
persistent linkManager;

if isempty(linkManager)
    linkManager = datamanager.linkplotmanager;
    try 
        linkManager.LinkListener = com.mathworks.page.datamgr.linkedplots.LinkedVariableObserver;
        linkManager.LinkListener.activate;
    catch %#ok<CTCH>
        error('MATLAB:graphics:linkplotdata','This feature is not supported');
    end
end
h = linkManager;
