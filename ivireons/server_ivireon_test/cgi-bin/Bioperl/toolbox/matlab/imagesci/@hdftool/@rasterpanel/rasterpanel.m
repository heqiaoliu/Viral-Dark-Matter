function this = rasterPanel(hdftree, hImportPanel)
%RASTERPANEL Construct a rasterPanel.
%   The rasterPanel is responsible for displaying the information of an
%   HDF raster node.
%
%   Function arguments
%   ------------------
%   HDFTREE: the hdfTree which contains us.
%   HIMPORTPANEL: the panel which will be our HG parent.

%   Copyright 2004-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/02/06 14:22:54 $

    this = hdftool.rasterpanel;
    this.hdfPanelConstruct(hdftree, hImportPanel,'Raster Image');
    prefs = this.fileTree.fileFrame.prefs;
    
    hParent = uiflowcontainer('v0', 'Parent', this.subsetPanel, ...
	        'BackgroundColor', get(0,'defaultUiControlBackgroundColor'), ...
            'FlowDirection','LeftToRight');

    % Create the middle uipanel
    [firstRecPanel, cmapApi] = this.createSingleEntryGroup(...
        hParent, 'Colormap Variable:', 'cmap', prefs);
    
    this.editHandle = findobj(hParent, 'Style', 'Edit');
    this.textHandle = findobj(hParent, 'Style', 'Text');
end
