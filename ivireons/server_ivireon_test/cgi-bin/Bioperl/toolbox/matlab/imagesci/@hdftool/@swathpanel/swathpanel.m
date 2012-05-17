function this = swathPanel(hdftree, hImportPanel)
%SWATHPANEL construct a swathPanel.
%   The swathPanel is responsible for displaying the information of an
%   HDF-EOS SWATH.
%
%   Function arguments
%   ------------------
%   HDFTREE: the hdfTree which contains us.
%   HIMPORTPANEL: the panel which will be our HG parent.

%   Copyright 2004-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2009/02/06 14:22:56 $

    this = hdftool.swathpanel;
    this.hdfPanelConstruct(hdftree, hImportPanel,'HDF-EOS Swath');
    hPanel = this.subsetPanel;

    topPanel = uipanel('Parent',hPanel);
    topPanel = uiflowcontainer('v0', 'Parent',topPanel,...
            'BackgroundColor', get(0,'defaultUiControlBackgroundColor'), ...
            'FlowDirection','TopDown');

    buttonNames = {xlate('No Subsetting'),...
        xlate('Direct Index'),...
        xlate('Geographic Box'),...
        xlate('Time'),...
        xlate('User-defined')};

    [radioBtns api ctrl] = makePopupMenu(this, topPanel, @createFrame, ...
        buttonNames, this.fileTree.fileFrame.prefs);
    this.subsetSelectionApi = api;
    this.subsetApi{5} = [];
    this.subsetFrameContainer = topPanel;
    [this.subsetFrame(1) this.subsetApi{1}] = createEmptyFrame(this, this.subsetFrameContainer);

end


function createFrame(this, index)
    % If we have already created the panel, return.
    if ~isempty(this.subsetApi{index})
        return
    end

    % Since we have no parameters, disable the reset button.
    resetButton = findobj(this.mainPanel, 'tag', 'resetSelectionParameters');
    if index == 1
        set(resetButton, 'enable', 'off');
    else
        set(resetButton, 'enable', 'on');
    end
    
    % Create the appropriate panel.
    switch index
        case 1
            [this.subsetFrame(1) this.subsetApi{1}] = createEmptyFrame(this, this.subsetFrameContainer);
        case 2
            [this.subsetFrame(2) this.subsetApi{2}] = createModeAugmentedFrame(this, this.subsetFrameContainer, 'DirectIndex');
        case 3
            [this.subsetFrame(3) this.subsetApi{3}] = createModeAugmentedFrame(this, this.subsetFrameContainer, 'GeographicBox');
        case 4
            [this.subsetFrame(4) this.subsetApi{4}] = createModeAugmentedFrame(this, this.subsetFrameContainer, 'Time');
        case 5
            [this.subsetFrame(5) this.subsetApi{5}] = createModeAugmentedFrame(this, this.subsetFrameContainer, 'UserDefined');
    end
end

