function this = vdataPanel(hdftree, hImportPanel)
%VDATAPANEL Construct a vdataPanel.
%   The vdataPanel is responsible for displaying the information of an
%   HDF vdata node.
%
%   Function arguments
%   ------------------
%   HDFTREE: the hdfTree which contains us.
%   HIMPORTPANEL: the panel which will be our HG parent.

%   Copyright 2004-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2009/02/06 14:22:57 $

    this = hdftool.vdatapanel;
    this.hdfPanelConstruct(hdftree, hImportPanel, 'Vdata');

    hParent = uiflowcontainer('v0', 'Parent', this.subsetPanel,...
            'BackgroundColor', get(0,'defaultUiControlBackgroundColor'), ...
            'FlowDirection', 'TopDown');

    prefs  = hdftree.fileFrame.prefs;

    % Create the top uipanel
    [fieldsPanel, this.datafieldApi] = this.createMultilineSelectGroup(...
        hParent, 'Data fields:', {''}, prefs);

    % Create the middle uipanel
    [firstRecPanel, this.firstRecordApi] = this.createSingleEntryGroup(...
        hParent, 'First record:', '1', prefs);

    % Create the bottom uipanel
    [numRecPanel, this.numRecordsApi] = this.createSingleEntryGroup(...
        hParent, 'Number of records:', '', prefs);

end



