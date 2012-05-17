classdef GUIImport < handle

    % Data import GUI
    %
    % Copyright 2009-2010 The MathWorks, Inc.

    properties (Access = 'public')
        % Dialog state
        BaseWSOrMAT;   % One of "basews" or "mat"
        MATFileName;   % Name of mat file
        NewOrExistRun; % One of "new" or "exist"
        ExistRunID;    % ID of existing run
        
        % Column visibility
        RootSourceVisible;
        TimeSourceVisible;
        DataSourceVisible;
        BlockSourceVisible;
        ModelSourceVisible;
        SignalLabelVisible;
        SignalDimsVisible;
        PortIndexVisible;
        
        % Simulation output explorer
        SimOutExplorer;
        
        % SDI engine instance
        SDIEngine;
        
        % Handle to dialog
        HDialog;
        
        % ********************************
        % **** Common Dialog Controls ****
        % ********************************

        % OK, Cancel, and Help Buttons
        OKButton;
        CancelButton;
        HelpButton;
        
        % ***************************
        % **** Import Wizard Tab ****
        % ***************************
        
        % "Import From" section
        ImportFromLabel;
        ImportFromBaseRadio;
        ImportFromMATRadio;
        ImportFromMATLabel;
        ImportFromMATEdit;
        ImportFromMATButton;
        ImportFromMATButtonContainer;
        
        % "Import To" section
        ImportToLabel;
        ImportToNewRadio;
        ImportToExistRadio;
        ImportToExistLabel;
        ImportToExistCombo;
        
        % "Import Variables" section - Table
        ImportVarsTT;
        ImportVarsTTComponent;
        ImportVarsTTContainer;
        ImportVarsTTScrollPane;
        ImportVarsTTCallbacks;
        ImportVarsTTListener;
        ImportVarsTTModel;
        ImportVarsSTTModel;
        ImportVarsCheckboxCellRenderer;
        ImportVarsCheckboxCellEditor;
        
        % "Import Variables" section - Buttons
        RefreshButton;
        RefreshButtonContainer;
        SelectAllButton;
        SelectAllButtonContainer;
        ClearAllButton;
        ClearAllButtonContainer;

        % "Import Variables" section - Context menu
        ContextMenu;
        ContextMenuRootSource;
        ContextMenuTimeSource;
        ContextMenuDataSource;
        ContextMenuBlockSource;
        ContextMenuModelSource;
        ContextMenuSignalLabel;
        ContextMenuSignalDims;
        ContextMenuPortIndex;

        % Dialog state
        Dirty;
        
        % run id by drop down index map
        runIDByIndexMap;
        
        % column Names
        colNames;
        colNameArrayList;
        numCol;
        
    end % Properties

    methods (Access = 'public')
        
        % Constructor
        function this = GUIImport(SDIEngine)
            % Cache engine object
            this.SDIEngine = SDIEngine;
                     
            % Cache string dictionary class
            SD = Simulink.sdi.StringDict;
            
            % Construct column headings
            this.colNames =                      ... 
                       {SD.IGRootSourceColName,  ...
                        SD.IGTimeSourceColName,  ...
                        SD.IGDataSourceColName,  ...
                        SD.IGBlockSourceColName, ...
                        SD.IGModelSourceColName, ...
                        SD.mgSigLabel,           ...
                        SD.IGSignalDimsColName,  ...
                        SD.IGPortIndexColName,   ...
                        SD.IGImportColName};
            this.colNameArrayList = javaObjectEDT('java.util.ArrayList');
            this.numCol = length(this.colNames);
            
            for i = 1 : this.numCol
                strName = java.lang.String(this.colNames{i});
                this.colNameArrayList.add(strName);
            end

            % Initialize dialog state
            this.BaseWSOrMAT   = 'basews';
            this.MATFileName   = '';
            this.NewOrExistRun = 'new';
            this.ExistRunID    = [];

            % Initialize column visibility
            this.RootSourceVisible  = true;
            this.TimeSourceVisible  = false;
            this.DataSourceVisible  = false;
            this.BlockSourceVisible = true;
            this.ModelSourceVisible = true;
            this.SignalLabelVisible = false;
            this.SignalDimsVisible  = false;
            this.PortIndexVisible   = false;

            % Create an output explorer and initialize results
            this.SimOutExplorer = Simulink.sdi.SimOutputExplorer;

            % Create controls, do layout, set callbacks, etc.
            this.build();

            % Initialize dirty flag
            this.Dirty = false;


        end             
    end % Methods

end % classdef