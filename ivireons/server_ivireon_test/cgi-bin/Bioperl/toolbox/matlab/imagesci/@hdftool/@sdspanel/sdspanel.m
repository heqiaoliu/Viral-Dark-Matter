function this = sdsPanel(hdftree, hImportPanel)
%SDSPANEL Construct a sdsPanel.
%   The sdsPanel is responsible for displaying the information of an
%   HDF Scientific Data Set.
%
%   Function arguments
%   ------------------
%   HDFTREE: the hdfTree which contains us.
%   HIMPORTPANEL: the panel which will be our HG parent.

%   Copyright 2004-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2009/01/16 11:06:58 $

    this = hdftool.sdspanel;
    this.hdfPanelConstruct(hdftree, hImportPanel, 'Scientific Data Set');

    colNames = {xlate('Start'), xlate('Increment'), xlate('Length')};
    fig = hdftree.fileFrame.figureHandle;

    [this.table, this.tableApi] = this.createDirectIndexGroup( fig, colNames);

    set(this.table,...
        'Parent', this.subsetPanel,...
        'Visible', get(this.mainpanel,'Visible'),...
        'Units', 'Normalized',...
        'Position', [0 .2 .9 .7]);

    listener = addlistener(this.subsetPanel, 'Visible', ...
	                           'PostSet', @settablevisibility);


    %----------------------------------------------------------------------
    function settablevisibility(src, event)
        if ~ishghandle(this.tableContainer)
            delete(listener);
            return
        end
        vis = get(this.subsetPanel,'Visible');
        set(this.tableContainer,'Visible',vis);
        set(this.table,'Visible',vis);
        % FIXME: the following should not be necessary
        if strcmpi('off',vis)
            set(this.tableContainer, 'Position', [0 0 .001 .001]);
        else
            set(this.tableContainer, 'Position', [0 .2 .9 .7]);
        end
    end
end
