function this = pointPanel(hdftree, hImportPanel)
%POINTPANEL construct a pointPanel.
%   The pointPanel is responsible for displaying the information of an
%   HDF-EOS POINT.
%
%   Function arguments
%   ------------------
%   HDFTREE: the hdfTree which contains us.
%   HIMPORTPANEL: the panel which will be our HG parent.

%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/02/06 14:22:53 $

    this = hdftool.pointpanel;
    this.hdfPanelConstruct(hdftree, hImportPanel,'HDF-EOS Point');

    topPanel = uiflowcontainer('v0', 'Parent', this.subsetPanel,...
	        'BackgroundColor', get(0,'defaultUiControlBackgroundColor'), ...
            'FlowDirection','LeftToRight');

    prefs  = hdftree.fileFrame.prefs;
    
    topLeftPanel = uiflowcontainer('v0', 'Parent',topPanel,...
	        'BackgroundColor', get(0,'defaultUiControlBackgroundColor'), ...
            'FlowDirection','TopDown');
    topRightPanel = uiflowcontainer('v0', 'Parent',topPanel,...
	        'BackgroundColor', get(0,'defaultUiControlBackgroundColor'), ...
            'FlowDirection','TopDown');

    
    % Create the 'datafields' uipanel
    [fieldsPanel, this.datafieldApi] = this.createMultilineSelectGroup(...
        topLeftPanel, 'Data fields:', {''}, prefs);
    
    % Create the 'Level' uipanel
    [levelPanel, this.levelApi] = this.createSingleEntryGroup(...
        topLeftPanel, 'Level:', '1', prefs);
    
    % RecordNumbers panel
    [recordPanel, this.recordApi, minSize] = this.createSingleEntryGroup(...
        topLeftPanel, 'Record (optional):', '', prefs);
    
    set(topLeftPanel,...
        'WidthLimits', [minSize(1) minSize(1)]*prefs.charExtent(1));

    % Box panel
    [boxPanel, this.boxApi] = this.createBoxCornerGroup(topRightPanel, '', prefs);

    % Time panel
    [timePanel, this.timeApi] = this.createEntryFieldGroup(...
        topRightPanel, [1 2], '', {'Start:','Stop:'}, 'Time (optional)', prefs );
    
end
