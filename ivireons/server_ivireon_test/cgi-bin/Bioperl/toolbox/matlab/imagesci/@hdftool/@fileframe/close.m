function close(this)
%CLOSE Destroy the fileframe.
%   This method is called when the fileframe class is being closed.
%   It will close all files and close the tool itself.
%
%   Function arguments
%   ------------------
%   THIS: the fileframe object

%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2010/04/15 15:25:52 $

    if this.prefs.confirmClose
        reply = questdlg('Are you sure you want to close the HDF tool?','Really quit?','Yes','No','Yes');
        if strcmp(reply, 'No')
            return
        end
    end

    fileToolSize = get(this.figureHandle,'Position');

    fileToolConfigSize = [fileToolSize(3)-this.figSplitPane.DominantExtent,...
        fileToolSize(4)-this.rightSplitPane.DominantExtent];

    % Save the size preferences of the tool.
    setpref('MATLAB_IMAGESCI', 'FILETOOL_SIZE', fileToolSize);
    setpref('MATLAB_IMAGESCI', 'FILETOOL_CONFIG_SIZE', fileToolConfigSize);
    
    this.closeAllFiles();
    drawnow;
    
    set(this.metadataDisplay, 'MouseEnteredCallback','');

    hTree = getTree(this.treeHandle);
	hhTree = handle(hTree,'callbackProperties');
    set(hhTree, 'MouseEnteredCallback', '');
    
    delete(this.treeHandle);
    delete(this.figureHandle);
    delete(this.noDataPanel);
    delete(this);
end
