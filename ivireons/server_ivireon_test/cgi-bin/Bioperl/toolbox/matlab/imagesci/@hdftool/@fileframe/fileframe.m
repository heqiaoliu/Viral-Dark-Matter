function this = fileframe()
%FILEFRAME Create the frame for the user interface.
%   This method creates a fileframe, which provides the UI
%   components necessary to view a file.
%

%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.11 $  $Date: 2010/04/15 15:25:53 $
    
    this = hdftool.fileframe;
    
    % create the FRAME for the HDFTOOL
    set(this.figureHandle, 'Pointer', 'watch');
    try
        [this, handles] = createToolFrame(this);
        this.lowerRightPanel = handles.lowerRightPanel;
        
        % Create the UITree
        this.treeHandle = createUITree(this, handles.leftPanel);

        % Construct the splitpanes.
        % The splitpanes are dividers which may be laid out horizontally or
        % vertically, and which have a 'Dominant' half (this is the half
        % that maintains it's size as the figure size is altered).
        
        % Layout the figure.
        this.figSplitPane = hdftool.splitpane(this.figureHandle);
        this.figSplitPane.LayoutDirection = 'Horizontal';
        this.figSplitPane.Dominant = 'NorthWest';
        this.figSplitPane.DominantExtent = this.prefs.figurePosition(3) - ...
            this.prefs.panelWidth;
        this.figSplitPane.MinDominantExtent = this.prefs.minTreeWidth;
        this.figSplitPane.MinNonDominantExtent = this.prefs.minPanelWidth;
        this.figSplitPane.NorthWest = handles.leftPanel;
        this.figSplitPane.SouthEast = handles.rightPanel;
        this.figSplitPane.DividerWidth = this.prefs.dividerWidth(1);
        this.figSplitPane.AutoUpdate = false;

        % layout the right panel
        this.rightSplitPane = hdftool.splitpane(handles.rightPanel);
        this.rightSplitPane.LayoutDirection = 'Vertical';
        this.rightSplitPane.Dominant  = 'NorthWest';
        this.rightSplitPane.DominantExtent = this.prefs.figurePosition(4) - ...
            this.prefs.panelHeight;
        this.rightSplitPane.MinDominantExtent = this.prefs.minMetadataHeight;
        this.rightSplitPane.MinNonDominantExtent = this.prefs.minPanelHeight;
        this.rightSplitPane.NorthWest = handles.upperRightPanel;
        this.rightSplitPane.SouthEast = handles.lowerRightPanel;
        this.rightSplitPane.DividerWidth = this.prefs.dividerWidth(2);
        this.rightSplitPane.AutoUpdate = false;
        
        % Create the menus
        createMenus(this);
        this.setMetadataText('default');
        this.setDatapanel('default');
        
        % Show everything
        set([this.figSplitPane this.rightSplitPane], 'Active', [true true]);
        
        % Set a resize function in order to set a lower bound on the size of the
        % figure.
        oldPos = get(this.figureHandle, 'position');
        oldResize = get(this.figureHandle, 'ResizeFcn');
        overSeparator = false;
        
        set(this.figureHandle, 'ResizeFcn', {@ResizeFcn this.prefs.minFigureSize});
        set(this.figureHandle, 'WindowButtonMotionFcn', {@WindowButtonMotionFcn ...
                            [this.rightSplitPane.DividerHandle this.figSplitPane.DividerHandle]...
                             this.prefs.minFigureSize});
        set(this.figureHandle, 'CloseRequestFcn', @(varargin)(this.close()) );
    catch myException
        set(this.figureHandle, 'Pointer', 'arrow');
        rethrow(myException);
    end
    set(this.figureHandle, 'Pointer', 'arrow');
    
    function ResizeFcn( hFig, event, minFigureSize)
    % Ensure a minimum figure size.
        pos = get(hFig, 'position');
        minSize = max(pos(3:4),minFigureSize);
        if any(pos(3:4) < minSize)
            oldPos(3:4) = max(pos(3:4),minSize);
            % Temporarily unset ourselves: see geck 222664
            set(this.figureHandle, 'ResizeFcn', '' )
            set(hFig, 'position', oldPos);
            set(this.figureHandle, 'ResizeFcn', {@ResizeFcn this.prefs.minFigureSize} )
        else
            oldPos = pos;
        end
        % Call the resize function set by the splitPanel.
        feval(oldResize{1}, hFig, event, oldResize{2});
    end

    function WindowButtonMotionFcn(hFig, event, divider, minFigureSize)
        % The cursor should change when it is over a divider.
        obj = hittest(hFig);
        pos = get(hFig, 'position');
        if any(obj == divider)
            if obj == divider(1) && pos(4) > minFigureSize(2)
                set(this.figureHandle, 'Pointer', 'top');
            elseif obj == divider(2) && pos(3) > minFigureSize(1)
                set(this.figureHandle, 'Pointer', 'right');
            end
            overSeparator = true;
        else
            if overSeparator == true
                set(this.figureHandle, 'Pointer', 'arrow');
                overSeparator = false;
            end
        end
    end

end

%===================================================================
function [this handles] = createToolFrame(this)
    % Construct the frame and other elements of the HDFTOOL UI.

    % Create the figure
    this.figureHandle = figure('Toolbar','none',...
        'Menubar','none',...
        'DockControls', 'off',...
        'HandleVisibility','callback',...
        'IntegerHandle','off',...
        'NumberTitle','off',...
        'Tag','filetoolFigure',...
        'Units','character',...
        'Visible','on' );

    % Initialize all layout preference (defaults)
    initializePreferences(this, this.figureHandle);

    set(this.figureHandle,...
        'Position',this.prefs.figurePosition,...
        'Name',this.prefs.toolTitle);

    % Create the right panel
    handles.rightPanel = uipanel('Parent',this.figureHandle,...
        'Visible','on');
    % Create the left panel
    handles.leftPanel = uipanel('Parent',this.figureHandle,...
        'Visible','on');
    % Create the metadata panel
    [this, handles.upperRightPanel] = createMetaDataPanel(this, this.figureHandle, handles.rightPanel);

    % Create the no-data panel
    handles.lowerRightPanel = uipanel('Parent',handles.rightPanel,...
        'Bordertype','none');
    this.noDataPanel = hdftool.filepanel(handles.lowerRightPanel);
    this.currentPanel = this.noDataPanel;
end

%===================================================================
function [this, hContainer] = createMetaDataPanel(this, fig, panel)

    colorPrefs = this.prefs.colorPrefs;

    % Create the panel in which we display metadata for a particular node.
    display = com.mathworks.mwswing.MJEditorPane;
    display.setContentType('text/html');
    display.setOpaque(true);
    border = javax.swing.border.EmptyBorder(2,8,2,8);
    display.setBorder(border);
    display.setText('');

    display.setBackground(colorPrefs.backgroundColorObj);
    display.setEditable(0);

	hdisplay = handle(display,'callbackProperties');
	set(hdisplay,'MouseEnteredCallback',@(varargin)(set(fig, 'pointer', 'arrow')));

    mjscroll = com.mathworks.mwswing.MJScrollPane(display);
    mjscroll.getVerticalScrollBar.setMaximum(1);
    mjscroll.getVerticalScrollBar.setValue(0);
    [jComp, hContainer] = javacomponent(mjscroll,[10,10,10,10],fig);

    set(hContainer,'Parent',panel);
    this.metadataDisplay = display;
    this.metadataScroll = mjscroll.getVerticalScrollBar();
end

%===================================================================
function createMenus(this)
    % Create the menus for the figure.

    % File Menu
    fileMenu = uimenu('Parent',this.figureHandle,...
        'Label','&File',...
        'Callback',{@fileMenuCallback this},...
        'ForegroundColor', this.prefs.colorPrefs.menuTextColor,...
        'Tag','fileMenu');
    uimenu('Parent',fileMenu,...
        'Label','Open File',...
        'Callback', @(varargin)(this.openFile()),...
        'ForegroundColor', this.prefs.colorPrefs.menuTextColor,...
        'Accelerator','O',...
        'Tag','openMenu');
    this.importMenu = uimenu('Parent',fileMenu,...
        'Label','Import Dataset to workspace',...
        'Separator', 'on',...
        'Callback',{@importDatasetToWorkspaceCallback this},...
        'ForegroundColor', this.prefs.colorPrefs.menuTextColor,...
        'Accelerator','I',...
        'Tag','importMenu');
    closeMenu = uimenu('Parent',fileMenu,...
        'Label','Close File',...
        'Callback', @(varargin)(this.closeFile()),...
        'ForegroundColor', this.prefs.colorPrefs.menuTextColor,...
        'Separator', 'on',...
        'Accelerator','W',...
        'Tag','closeFileMenu');
    closeAllMenu = uimenu('Parent',fileMenu,...
        'Label','Close All Files',...
        'Callback', @(varargin)(this.closeAllFiles()),...
        'ForegroundColor', this.prefs.colorPrefs.menuTextColor,...
        'Tag','closeAllFilesMenu');
    uimenu('Parent',fileMenu,'Label','Close HDFTool',...
        'Callback', @(varargin)(this.close()),...
        'ForegroundColor', this.prefs.colorPrefs.menuTextColor,...
        'Tag','closeToolMenu');

    % Help Menu
    helpMenu = uimenu('Parent',this.figureHandle,...
        'Label','&Help',...
        'ForegroundColor', this.prefs.colorPrefs.menuTextColor,...
        'Tag','helpMenu');
    uimenu('Parent',helpMenu,...
           'Label','HDFTool Help',...
           'callback',@(varargin)(showHelp(this, 'hdftool_help')),...
           'ForegroundColor', this.prefs.colorPrefs.menuTextColor,...
           'Accelerator','H',...
           'Tag','helpOverviewMenu');
    uimenu('Parent',helpMenu,...
           'Label','Subsetting options',...
           'callback',@(varargin)(showHelp(this, 'subsetting_options')),...
           'ForegroundColor', this.prefs.colorPrefs.menuTextColor,...
           'Accelerator','S',...
           'Tag','helpImportMenu');

    function fileMenuCallback(hObj, event, this)
        % The user has selected the file menu.
        
        % Disable the "close" options if there are no open files.
        rootNode = get(this.treeHandle,'Root');
        if ~get(rootNode, 'ChildCount')
            set([closeMenu closeAllMenu], 'enable', 'off');
        else
            set(closeAllMenu, 'enable', 'on');
            selectedNode = get(this.treeHandle,'SelectedNodes');
            if ~isempty(selectedNode);
                set(closeMenu, 'enable', 'on');
            else
                set(closeMenu, 'enable', 'off');
            end
        end
            
        % Disable the importDatasetToWorkspace item
        panelMethods = methods(this.currentPanel);
        match = strcmp(panelMethods, 'importDatasetToWorkspace');
        if any(match)
            set(this.importMenu, 'Enable', 'on');
        else
            set(this.importMenu, 'Enable', 'off');
        end
            
    end
end

function importDatasetToWorkspaceCallback(hObj, event, this)
    % Call the importDatasetToWorkspace method for the current panel.
    this.currentPanel.importDatasetToWorkspace;
end

function treeHandle = createUITree(this, parentPanel)
    % A method to construct (initialize) a UITREE object.
    % This method creates the singleton UITREE.

    colorPrefs = this.prefs.colorPrefs;

    fig = this.figurehandle;
    prefs = this.prefs;
    title = 'File Tree';

    % Create a node which will serve as the parent to all opened files
    node = hdftool.createTreeNode(title, struct, ...
        @this.displayNodeInfo,...
        title,[],false);

    % Create the UITREE
    [treeHandle, treeContainer] = uitree('v0', fig);
    set(treeHandle, 'NodeSelectedCallback', @(varargin)(this.nodeCallback()) );
    set(treeContainer, 'Opaque', 'on');

    
    hTree = getTree(treeHandle);
    awtinvoke(hTree, 'setRowHeight', prefs.treeNodeIconHeight);

    awtinvoke(hTree, 'setBackground', colorPrefs.backgroundColorObj );

    % Get the cell renderer so we can control the nonselection colors.
    % If something is NOT selected, then the background and text of that
    % node element should be the stame as the htree background.
    cellRenderer = get(hTree,'CellRenderer');
    awtinvoke(cellRenderer,'setTextNonSelectionColor', colorPrefs.textColorObj);
    awtinvoke(cellRenderer,'setBackgroundNonSelectionColor', colorPrefs.backgroundColorObj);

    awtinvoke(hTree, 'setShowsRootHandles', true);
    awtinvoke(hTree, 'setRootVisible(Z)', false);

	hhtree = handle(hTree,'callbackProperties');
	set(hhtree,'MouseEnteredCallback',@(varargin)(set(fig, 'pointer', 'arrow')));

    treeHandle.setRoot(node);

    % Set the UITREE's HG parent
    treeContainerParent = uipanel('Parent',fig,...
        'Visible','on',...
        'BorderType','none',...
        'Units','normalized',...
        'Position', [0 0 1 1]);
    set(treeContainer, ...
        'Parent', treeContainerParent,...
        'Units','normalized',...
        'Position', [0 0 1 1]);
    treeContainer = treeContainerParent;
    set(treeContainer, 'parent', parentPanel);

end

function showHelp(this, location)
    % Display help for HDFTOOL
    switch location
        case 'hdftool_help'
            helpview([docroot '/techdoc/import_export/import_export.map'],'hdfviewer_help');
        case 'subsetting_options'
            helpview([docroot '/techdoc/import_export/import_export.map'],'hdfviewer_ov');
    end
end
