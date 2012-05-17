classdef GUIMain < handle
    
    % Copyright 2009-2010 The MathWorks, Inc.
    
    properties (Access = 'public')
        % Dialog state
        SDIEngine;  % SDI engine instance
        TabType;    % Index of active tab
        CursorType; % Mouse cursor        
        ImportGUI;  % Import GUI
        pathName;   % path of file
        
        % Dialog
        HDialog;
        
        % Main menu
        MainMenuFileGroup;
        MainMenuNew;
        MainMenuOpen;
        MainMenuSave;
        MainMenuSaveAs;
        MainMenuExit;
        MainMenuHelpGroup;
        MainMenuHelpContents;
        MainMenuAbout;
        
        % Plot menu
        plotToolsMenuGroup;
        plotToolsZoomInX;
        plotToolsZoomInY;
        plotToolsZoomInXY;
        plotToolsZoomOut;
        plotToolsPan;
        plotToolsDataCursor;
        
        % Data menu
        dataMenuImport;
        dataMenuRecord;
        
        % Toolbar
        Toolbar;
        ToolbarButtonNew;
        ToolbarButtonLoad;
        ToolbarButtonSave;
        ToolbarButtonImport;
        ToolbarButtonZoomInX;
        ToolbarButtonZoomInY;
        ToolbarButtonZoomInXY;
        ToolbarButtonZoomOut;
        ToolbarButtonPan;
        ToolbarButtonDataCursor;
        ToolbarButtonRecord;
        toolbarButtonHelp;
        
        % Main Tab Group
        TabGroup;
        TabInspectSignals;
        TabCompareSignals;
        TabCompareRuns;
        
        % Table Context Menu
        TableContextMenu;
        TableContextMenuProperties;
        TableContextMenuGoToModel;
        TableContextMenuEditor;
        TableContextMenuDelete;
        tableColumnSelectContextMenu;
        tableColumnSelectContextMenuCompareSig;
        tableColumnSelectContextMenuCompareRuns;
        
        tableContextMenu;
        tableContextMenuColumns;
        tableContextMenuSigSource;
        tableContextMenuViewData;
        tableContextMenuProperties;
        tableContextMenuRun;
        tableContextMenuColor;
        tableContextMenuAbsTol;
        tableContextMenuRelTol;
        tableContextMenuSync;
        tableContextMenuInterp;
        tableContextMenuDataSource;
        tableContextMenuModelSource;
        tableContextMenuSignalLabel;
        tableContextMenuRoot;
        tableContextMenuTimeSource;
        tableContextMenuPort;
        tableContextMenuDim;
        tableContextMenuChannel;
        tableContextMenuDelete;
        tableContextMenuDeleteAll;                                           
        tableContextMenuSortBy;
        tableContextMenuSortByRun;
        tableContextMenuSortByBlock;
        tableContextMenuSortByData;
        tableContextMenuSortByModel;
        tableContextMenuSortBySignalName;
        
        % table context menu compare runs
        tableContextMenuCompRuns;
        tableContextMenuColumnsCompRuns;
        tableContextMenuSigSourceCompRuns;
        tableContextMenuSigSourceCompRuns1;
        tableContextMenuSigSourceCompRuns2;
        tableContextMenuViewDataCompRuns;
        tableContextMenuViewDataCompRuns1;
        tableContextMenuViewDataCompRuns2;
        tableContextMenuPropertiesCompRuns;
        tableContextMenuPropertiesCompRuns1;
        tableContextMenuPropertiesCompRuns2;

        
        % compare runs table context menu columns
        tableContextMenuBlkSrc1;
        tableContextMenuBlkSrc2;
        tableContextMenuDataSrc1;
        tableContextMenuDataSrc2;
        tableContextMenuSID1;
        tableContextMenuSID2;
        tableContextMenuCompRunAbsTol;
        tableContextMenuCompRunRelTol;
        tableContextMenuCompRunSync;
        tableContextMenuCompRunInterp;
        tableContextMenuCompRunChannel
        tableContextMenuBlkSrc;
        tableContextMenuDataSrc;
        tableContextMenuSID;
               
        % context menu items inspect tab
        contextMenuRun;
        contextMenuBlockSource;
        contextMenuPlot;
        contextMenuColor;
        contextMenuAbsTol;
        contextMenuRelTol;
        contextMenuSync;
        contextMenuInterp;
        contextMenuDataSource;
        contextMenuModelSource;
        contextMenuSignalLabel;
        contextMenuRoot;
        contextMenuTimeSource;
        contextMenuPort;
        contextMenuDim;
        contextMenuChannel;
        contextMenuColumns;
        contextMenuSortBy;
        contextMenuSortByRun;
        contextMenuSortByBlock;
        contextMenuSortByData;
        contextMenuSortByModel;
        contextMenuSortBySignalName;
        
        % context menu items compare signals tab
        contextMenuRunCompSig;
        contextMenuBlockSourceCompSig;
        contextMenuColorCompSig;
        contextMenuAbsTolCompSig;
        contextMenuRelTolCompSig;
        contextMenuSyncCompSig;
        contextMenuInterpCompSig;
        contextMenuDataSourceCompSig;
        contextMenuModelSourceCompSig;
        contextMenuSignalLabelCompSig;
        contextMenuRootCompSig;
        contextMenuTimeSourceCompSig;
        contextMenuPortCompSig;
        contextMenuDimCompSig;
        contextMenuChannelCompSig;
        contextMenuColumnsCompSig;
        contextMenuSortByCompSig;
        contextMenuSortByRunCompSig;
        contextMenuSortByBlockCompSig;
        contextMenuSortByDataCompSig;
        contextMenuSortByModelCompSig;
        contextMenuSortBySignalNameCompSig;
        
        % context menu items compare runs tab
        contextMenuBlkSrc_CompRuns;
        contextMenuBlkSrc_CompRuns1;
        contextMenuBlkSrc_CompRuns2;
        contextMenuDataSrc_CompRuns;
        contextMenuDataSrc_CompRuns1;
        contextMenuDataSrc_CompRuns2;
        contextMenuSID_CompRuns;
        contextMenuSID_CompRuns1;
        contextMenuSID_CompRuns2;
        contextMenuAbsTol_CompRuns;
        contextMenuRelTol_CompRuns;
        contextMenuSync_CompRuns;
        contextMenuInterp_CompRuns;
        contextMenuChannel_CompRuns;

        % Options menu
        OptionsMenu;
        OptionsMenuOriginal;
        OptionsMenuNormalize;
        OptionsMenuNewFigure;
        optionsMenuStairPlot;
        optionsMenuLinePlot;
        OptionsMenuButton1;
        OptionsMenuButton2;
		OptionsMenuButton1Container;
        OptionsMenuButton2Container;
        
        % Axes
        AxesInspectSignals;
        AxesCompareSignalsData;
        AxesCompareSignalsDiff;
        AxesCompareRunsData;
        AxesCompareRunsDiff;
        
        % Axes - Types
        AxesInspectSignalsType;
        AxesCompareSignalsDataType;
        AxesCompareSignalsDiffType;
        AxesCompareRunsDataType;
        AxesCompareRunsDiffType;
        
        % Treetables
        InspectTT;
        compareSignalsTT;        
        compareRunsTT;
        compareRunsTTModel;
        inspectTreeTableModel;
        compareSignalsTableModel;
        commonSortableModel;
        commonTableModel;
        
        % Column visibility
        %   Inspect Signals
        runVisibleInsp;
        blockSrcVisibleInsp;
        plotVisibleInsp;
        colorVisibleInsp;
        absTolVisibleInsp;
        relTolVisibleInsp;
        syncVisibleInsp;
        interpVisibleInsp;
        dataSourceVisibleInsp;
        modelSourceVisibleInsp;
        signalLabelVisibleInsp;
        rootVisibleInsp;
        timeVisibleInsp;
        portVisibleInsp;
        dimVisibleInsp;
        channelVisibleInsp;
        
        %   Compare Signals
        runVisibleCompSig;
        blockSrcVisibleCompSig;
        colorVisibleCompSig;
        absTolVisibleCompSig;
        relTolVisibleCompSig;
        syncVisibleCompSig;
        interpVisibleCompSig;
        dataSourceVisibleCompSig;
        modelSourceVisibleCompSig;
        signalLabelVisibleCompSig;
        rootVisibleCompSig;
        timeVisibleCompSig;
        portVisibleCompSig;
        dimVisibleCompSig;
        channelVisibleCompSig;
        
        % compare runs
        blkSrcVis1;
        blkSrcVis2;
        dataSrcVis1;
        dataSrcVis2;
        sidVis1;
        sidVis2;
        absTolVis;
        relTolVis;
        syncVis;
        interpVis;
        channelVis;
        
        % indices
        %  checkboxes
        leftInd;
        rightInd;
        
        
        % Variable dimensions
        MTreeTableHE;
        MAxesVE;
        MAxesHE;
        MTreeTableVE;
        TreeTTopGap;
        AxesTopGap;
        
        % PlotObject
        HInspectPlot;
        HDiffPlot;
        
        % For Tol Column
        TolCellEditor;
        TolCellEditorCBP;
        TolComboBox;
         
        TolCellEditorSCmpL;
        TolCellEditorSCmpLCBP;
        TolComboBoxSCmpL;
        
        TolCellEditorCmpRuns;
        TolCellEditorCmpRunsCBP;
        TolComboBoxCmpRuns;
        
        TolCellEditorSCmpR;
        TolCellEditorSCmpRCBP;
        TolComboBoxSCmpR;
        
        SelectedData; % Data to be updated
        SelectedRow;
        
        LHSSingleCompareRunID;
        RHSSingleCompareRunID;
        LHSSingleCompareSignalID;
        RHSSingleCompareSignalID;
        
        % Run Compare Tab
        lhsRunCombo;
        rhsRunCombo;
        HTableModelCmpRuns;
        lhsRunContainer;
        rhsRunContainer;
        
        Tmp1;
        Tmp2;
        
        Listeners;
        
        % Context Menu Rows clicked
        % DAVID - These should go away
        RowIdxClicked;
        rowObjClicked;        
        rowObjClickedCompRuns;
        
        PlotStyleEditor;
        PlotStyleEditorCBP;
        colorEditorInsp;
        colorEditorCompSig;
        hColorEditorInsp;
        hColorEditorCompSig;
        abstolCellEditorInsp;
        habstolEditorInsp;
        reltolCellEditorInsp;
        hreltolCellEditorInsp;
        syncEditorInsp;
        hsyncEditorInsp;
        interpCellEditorInsp;
        hinterpCellEditorInsp;
        abstolCellEditorCompSig;
        habstolEditorCompSig;
        reltolCellEditorCompSig;
        hreltolCellEditorCompSig;
        syncEditorCompSig;
        hsyncEditorCompSig;
        interpCellEditorCompSig;
        hinterpCellEditorCompSig;
        abstolCellEditorCompRuns;
        habstolEditorCompRuns;
        reltolCellEditorCompRuns;
        hreltolCellEditorCompRuns;
        syncEditorCompRuns;
        hsyncEditorCompRuns;
        interpCellEditorCompRuns;
        hinterpCellEditorCompRuns;
        
        % check box editors
        checkboxCellEditorInsp;
        hCheckBoxEditorInsp;
        checkboxCellEditorLeftCompSig;
        checkboxCellEditorRightCompSig;
        InspPlotStyleEditor;
        InspColorEditor;
        SCmpLPlotStyleEditor;
        SCmpLColorEditor;
        SCmpRPlotStyleEditor;
        SCmpRColorEditor;
        RCmpPlotStyleEditor;
        RCmpColorEditor;
        InspPlotStyleEditorCBP;
        InspColorEditorCBP;
        SCmpLPlotStyleEditorCBP;
        SCmpLColorEditorCBP;
        SCmpRPlotStyleEditorCBP;
        SCmpRColorEditorCBP;
        RCmpPlotStyleEditorCBP;
        RCmpColorEditorCBP;
        
        % search panel
        inspectSearchPanel;
        inspectSearch;
        inspectSearchContainer;
        
        % sort criterion
        inspectSortCriterion;
        compareSignalSortCriterion;
        sortCriterion;
        
        % splitter
        inspectSplitter;
        compareSigVertSplitter;
        compareSigHorSplitter;
        compareRunsVertSplitter;
        compareRunsHorSplitter;
        
        % column names
        colNameInspect;
        colNameCompareSig;
        colNames;
        colNameArrayList;
        colNamesCompRun;
        
        % compare signals tab state variable
        state_SelectedSignalsCompSig;
        
        % compare signals screen variable
        screen_SelectedSignalsCompSig;
        
        % state var compare runs selected signal
        state_SelectedSignalCompRun;
        
        % colum indices of left and right on compare signals
        compareSigLeftIndex;
        compareSigRightIndex;     
        
        % captions
        lhsRunCaption;
        rhsRunCaption;
        advanceOptions;
        alignByCaption;
        firstThenByCaption;
        secondThenByCaption;
        
        % Popup menus
        firstThenByPopUp;
        secondThenByPopUp;
        alignByPopUp;
        alignByContainer;
        firstThenByContainer;
        secondThenByContainer;
        
        % push buttons
        compareRunAdvancePlus;
        compareRuns;
               
        % advanced Options panel - compare runs
        advanceOptionsPanel;  
        
        % string dict
        sd;
        
        % Map for storing run ids corresponding to indices in comboxbox on
        % compare runs tab
        runIDByComboIndexMap;
        comboIndexByRunIDMap;
        
        % cached run IDs on which compare was run
        lhsRunID;
        rhsRunID;
        
        % cached selected row for Compare Runs Tab
        selectedCompRunRow;
        
        % flag to close the GUI without saving anything  
        guiForceClose;
        
        % default name for MAT files
        defaultName;        
    end % properties - public
    
    properties(Access = 'private', SetObservable)                
        % normalized axes
        normInspectAxes;
        normCompSigDataAxes;
        normCompSigDiffAxes;
        normCompRunsDataAxes;
        normCompRunsDiffAxes;        
        stairLineInspectAxes;
        stairLineCompSigDataAxes;
        stairLineCompSigDiffAxes;
        stairLineCompRunsDataAxes;
        stairLineCompRunsDiffAxes;
        
        fileName;   % name of saved MAT-file
        dirty;      % dirty flag if change in the GUI
    end
    
    methods(Static)
        function updateSDIGUI(~,~)
            guiObj = Simulink.sdi.Instance.getMainGUI('isGuiUp');
            
            if isempty(guiObj)
                return;
            end
            
            if ishandle(guiObj.HDialog)
                guiObj.updateGUI('param');
            end
        end
    end
    methods
        
        function this = GUIMain(SDIEngine)
            % Cache engine object
            this.SDIEngine = SDIEngine;
            this.sd = Simulink.sdi.StringDict;            
            this.SDIEngine.registerListener...
                (@Simulink.sdi.GUIMain.updateSDIGUI);
            
            this.normInspectAxes = false;
            this.normCompSigDataAxes = false;
            this.normCompSigDiffAxes = false;
            this.normCompRunsDataAxes = false;
            this.normCompRunsDiffAxes = false;            
            this.stairLineInspectAxes = false;
            this.stairLineCompSigDataAxes = false;
            this.stairLineCompSigDiffAxes = false;
            this.stairLineCompRunsDataAxes = false;
            this.stairLineCompRunsDiffAxes = false;
            this.defaultName = ' ';
            
            addlistener(this, 'normInspectAxes', 'PostSet',...
                        @this.listener_normalized);
            addlistener(this, 'normCompSigDataAxes', 'PostSet',...
                        @this.listener_normalized);
            addlistener(this, 'normCompSigDiffAxes', 'PostSet',...
                        @this.listener_normalized);
            addlistener(this, 'normCompRunsDataAxes', 'PostSet',...
                        @this.listener_normalized);
            addlistener(this, 'normCompRunsDiffAxes', 'PostSet',...
                        @this.listener_normalized);
            addlistener(this, 'stairLineInspectAxes', 'PostSet',...
                        @this.listener_stairLine);
            addlistener(this, 'stairLineCompSigDataAxes', 'PostSet',...
                        @this.listener_stairLine);
            addlistener(this, 'stairLineCompSigDiffAxes', 'PostSet',...
                        @this.listener_stairLine);
            addlistener(this, 'stairLineCompRunsDataAxes', 'PostSet',...
                        @this.listener_stairLine);
            addlistener(this, 'stairLineCompRunsDiffAxes', 'PostSet',...
                        @this.listener_stairLine);
            addlistener(this, 'fileName', 'PostSet', @this.listener_fileName);
            addlistener(this, 'dirty', 'PostSet', @this.listener_fileName);
            
            % DAVID: What are these for?
            this.HInspectPlot = Simulink.sdi.Plot(this.SDIEngine);
            this.HDiffPlot    = Simulink.sdi.Plot(this.SDIEngine);
            
            % Initialize state - Tabs
            this.TabType = Simulink.sdi.GUITabType.InspectSignals;
            
            % Initialize state - Axes
            this.AxesInspectSignalsType     = Simulink.sdi.GUIAxesYType.Original;
            this.AxesCompareSignalsDataType = Simulink.sdi.GUIAxesYType.Original;
            this.AxesCompareSignalsDiffType = Simulink.sdi.GUIAxesYType.Original;
            this.AxesCompareRunsDataType    = Simulink.sdi.GUIAxesYType.Original;
            this.AxesCompareRunsDiffType    = Simulink.sdi.GUIAxesYType.Original;
            
            % Initialize state
            this.CursorType = Simulink.sdi.CursorType.Select;
            this.dirty      = false;
            this.ImportGUI  = [];
            this.screen_SelectedSignalsCompSig(1) = -1;
            this.screen_SelectedSignalsCompSig(2) = -1;  
            this.state_SelectedSignalsCompSig(1) = -1;
            this.state_SelectedSignalsCompSig(2) = -1; 
            this.state_SelectedSignalCompRun = -1;
            
            % Create controls, set callbacks, etc...
            this.Build();
            
            % Display dialog
            this.Show();            
        end
        
        function listener_fileName(this, ~, ~)
            
            if isempty(this.fileName)
                addToTitle = '';
            else
                addToTitle = [' - ' this.fileName];
            end

            if(this.dirty)
                dialogTitle = [this.sd.MGTitle addToTitle '*'];
            else
                dialogTitle = [this.sd.MGTitle addToTitle];                
            end
            % make sure the save and save as are enabled/disabled
            % accordingly
            this.SetEnable();
            set(this.HDialog, 'name', dialogTitle);            
        end
        
        function result = GetCursorType(this)
            result = this.CursorType;
        end
        
        function result = getDirty(this)
            result = this.dirty;
        end
        
        function SetCursorType(this, CursorType)
            % Set internal enum
            this.CursorType = CursorType;
            
            % Update cursor
            this.TransferDataToScreen_Cursor();
            
            % Update toolbar
            this.TransferDataToScreen_Toolbar();
        end
        
        function result = GetTabType(this)
            result = this.TabType;
        end
        
        function SetTabType(this, TabType)
            this.TabType = TabType;
        end
        
        function ToolbarButtonZoomInCallback(this, ~, ~, zoomType)
            switch zoomType
                case 'zoominx'
                    toolbarButton = this.ToolbarButtonZoomInX;
                case 'zoominy'
                    toolbarButton = this.ToolbarButtonZoomInY;
                case 'zoominxy'
                    toolbarButton = this.ToolbarButtonZoomInXY;
            end
            this.clickedCallBackHelper(toolbarButton,...
                                       zoomType)
        end
        
        function ToolbarButtonZoomOutCallback(this, ~, ~)
            this.clickedCallBackHelper(this.ToolbarButtonZoomOut,...
                                        'zoomout')
        end
        
        function ToolbarButtonPanCallback(this, ~, ~)
            this.clickedCallBackHelper(this.ToolbarButtonPan,...
                                        'pan')
        end
        
        function toolbarButtonDataCursorCallback(this, ~, ~)
            this.clickedCallBackHelper(this.ToolbarButtonDataCursor,...
                                        'datacursor')
        end
        
        function ToolbarButtonRecordCallback(this, ~, ~)
            try
                state = get(this.ToolbarButtonRecord, 'State');            
                if(strcmp(state, 'on'))
                    this.SDIEngine.record;
                    set(this.dataMenuRecord,    'Checked','on');
                else
                    this.SDIEngine.stop;
                    set(this.dataMenuRecord,    'Checked','off');
                end
            catch ME %#ok
                disp('Simulation Data Inspector GUI is not up.');
            end
        end
        
        function clickedCallBackHelper(this, button, cursorType)
            state = get(button, 'State');
            this.setCheckMenu(cursorType, state);
            if(strcmp(state, 'on'))
                this.SetCursorType(cursorType);                
            else
                this.CursorType = Simulink.sdi.CursorType.Select;
                % Update cursor
                this.TransferDataToScreen_Cursor();
            end
        end
        
        % *****************************************
        % **** Callbacks - Options menu/button ****
        % *****************************************
        
        function OptionsMenuButton1Callback(this, ~, ~)
            this.ShowOptionsMenu(this.GetTabType, Simulink.sdi.GUIAxesResultType.Signals);
        end
        
        function OptionsMenuButton2Callback(this, ~, ~)
            this.ShowOptionsMenu(this.GetTabType, Simulink.sdi.GUIAxesResultType.Diff);
        end
        
        function OptionsMenuNewFigureCallback(this, s, ~)
            % Get context menu parent
            this.OptionsMenu = get(s, 'parent');
            
            % Get user data from parent menu to determine context
            UserData = get(this.OptionsMenu, 'userdata');
            
            % Show in new figure window
            this.ShowAxesInNewFigure(UserData.AxesID);
        end
        
        % *******************************
        % **** Callbacks - Main menu ****
        % *******************************
        
        function MainMenuHelpContentsCallback(this, ~, ~)
            helpview([docroot '/toolbox/simulink/helptargets.map'],...
                     'simulation_data_inspector');            
        end
        
        function MainMenuAboutCallback(this, ~, ~)
            daabout('simulink');
        end
        
        function TabClickCallback(this, ~, eventdata)
            % Update tab index
            this.setTab(eventdata.NewValue);
            
            % Update control visibility
            this.SetVisible();           
            
        end
        
        %----------------------------------------------------------------------
        % Axes Callback
        function updateInspAxes(this)
            this.HInspectPlot.clearPlot;           
            this.HInspectPlot.plotInspector(this.AxesInspectSignals,...
                                            this.normInspectAxes, ...
                                            this.stairLineInspectAxes);
        end

        %----------------------------------------------------------------------
        % Color Column Callbacks
                
        function updateColorPlotInsp(this)
            this.updateColorPlotHelper(Simulink.sdi.GUITabType.InspectSignals,...
                                       this.hColorEditorInsp);
        end
                
        function updateColorPlotCompareSig(this)
            this.updateColorPlotHelper(Simulink.sdi.GUITabType.CompareSignals,...
                                       this.hColorEditorCompSig);
        end
        
        function DialogResizeCallback(this, ~, ~)
            this.PositionControls();
        end
        
    end % methods
    
    methods(Access = 'private')
        
        function helperUpdateChildren(this, colIndex, funHandle, signalID,...
                                      source, tol, treeTable)
            
            funHandle(signalID, tol);
            [~, ids, ~] = this.SDIEngine.getChildrenAndParent(signalID);
            count = length(ids);
            selectedRow = source.getSelectedRow();
            
            if (count == 0)
                return;
            end
            
            tolStr = source.CellEditorValue;
            
            for i=1:count
                funHandle(ids(i), tol);
                childRow = selectedRow.getChildAt(i - 1);
                childRow.setValueAt(tolStr, colIndex-1);
            end
            
            childRow = selectedRow.getChildAt(i);
            childRow.setValueAt(tolStr, colIndex-1);           
            
            treeTable.repaint();
        end
    
        function helperClearCompareRunsPlot(this)
            % cache string dictionary
            stringDict = this.sd;
            cla(this.AxesCompareRunsData, 'reset');
            title(this.AxesCompareRunsData, stringDict.mgSignals);
            cla(this.AxesCompareRunsDiff, 'reset');
            title(this.AxesCompareRunsDiff, stringDict.mgDifference);
        end
    end
    
end % classdef

