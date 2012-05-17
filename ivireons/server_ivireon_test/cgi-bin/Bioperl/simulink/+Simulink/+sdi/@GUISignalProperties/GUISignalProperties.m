classdef GUISignalProperties< handle
    % Signal properties dialog
    %
    % Copyright 2009-2010 The MathWorks, Inc.

    % Private properties
    properties (Access = 'public')
        % Dialog state
        Data;

        % Handle to dialog
        HDialog = [];

        % OK button
        OKButton;

        % Properties tree table
        TT;
        TTComponent;
        TTContainer;
        TTScrollPane;
        TTCallbacks;
        TTListener;
        TTModel;
        TTSortableModel;
    end % Private properties

    % Public properties
    methods (Access = 'public')

        % Constructor
        function this = GUISignalProperties(data)
            % Cache data object
            this.Data = data;

            % Cache geometric constants class
            GC = Simulink.sdi.GeoConst;

            % Create controls
            this.CreateControls();
            
            % Center dialog on screen
            Simulink.sdi.GUIUtil.CenterDialogOnScreen(this.HDialog,         ...
                                                      GC.SPDefaultDialogHE, ...
                                                      GC.SPDefaultDialogVE);

            % Layout controls
            this.PositionControls();
            
            % Transfer data to controls
            this.TransferDataToScreen();

            % Enable callbacks
            this.SetCallbacks();

            % Display GUI
            this.Show;
        end

        % Show GUI
        function Show(this)
            set(this.HDialog, 'visible', 'on');
            drawnow;
        end

        % Hide GUI without closing
        function Hide(this)
            set(this.HDialog, 'visible', 'off');
            drawnow;
        end

        % Close GUI
        function Close(this)
            close(this.HDialog);
        end

    end % Public properties

    methods (Access = 'private')

        function CreateControls(this)
            % Cache string dictionary class
            SD = Simulink.sdi.StringDict;

            % Cache GUI utilities class
            UG = Simulink.sdi.GUIUtil;

            % Dialog
            DialogTitle  = [SD.ToolName SD.Colon ' ' SD.SPSignalProperties];
            this.HDialog = UG.CreateDialog(DialogTitle);
            
            % set simulink icon instead of MATLAB icon
            warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
            jframe=get(this.HDialog, 'javaframe');
            iconPath = fullfile(matlabroot, ...
                                'toolbox',  ...
                                'matlab',   ...
                                'icons',    ...
                                'simulinkicon.gif');
            jIcon=javax.swing.ImageIcon(iconPath);
            jframe.setFigureIcon(jIcon);

            % OK button
            this.OKButton = UG.CreateHGButton(this.HDialog, SD.OK);

            % Properties table
            [this.TT,              ...
             this.TTComponent,     ...
             this.TTContainer,     ...
             this.TTModel,         ...
             this.TTSortableModel, ...
             this.TTScrollPane,    ...
             ] = UG.CreateTreeTable(this.HDialog, ...
                                    25, ... % Row height
                                    1   ... % Clicks to start
                                    );
             rowList = javaObjectEDT('java.util.ArrayList');
             rowList.add(int32(-1));
             colNames = {SD.SPProperties, SD.SPValues};
             colNameArrayList = javaObjectEDT('java.util.ArrayList');
             this.TT.setShowTreeLines(false);
             
             for i = 1 : length(colNames)
                 strName = java.lang.String(colNames{i});
                 colNameArrayList.add(strName);
             end
             
             this.TTModel = javaObjectEDT('com.mathworks.toolbox.sdi.sdi.CustomTreeTableModel', ...
                                        rowList, 2, colNameArrayList);
             this.TT.setModel(this.TTModel);
        end

        function SetCallbacks(this)
            set(this.HDialog,  'ResizeFcn', @this.DialogResizeCallback);
            set(this.OKButton, 'Callback',  @this.OKButtonCallback);
        end

        % ****************
        % **** Layout ****
        % ****************

        function PositionControls(this)
            % Cache geometric constants class
            GC = Simulink.sdi.GeoConst;

            % Cache GUI utilities class
            UG = Simulink.sdi.GUIUtil;

            % Enforce minimum dialog extents
            [DialogW, DialogH] = UG.LimitDialogExtents(this.HDialog,     ...
                                                       GC.SPMinDialogHE, ...
                                                       GC.SPMinDialogVE);

            % OK button
            OKButtonX   = floor((DialogW - GC.SPOKButtonHE) / 2);
            OKButtonY   = GC.SPWindowMarginVE;
            OKButtonW   = GC.SPOKButtonHE;
            OKButtonH   = GC.SPOKButtonVE;
            OKButtonPos = [OKButtonX, OKButtonY, OKButtonW, OKButtonH];

            % Table Position
            TableX   = GC.SPWindowMarginHE;
            TableY   = GC.SPWindowMarginVE + OKButtonH + GC.SPOKButtonVG;
            TableW   = DialogW - 2 * GC.SPWindowMarginHE;
            TableH   = DialogH - TableY - GC.SPWindowMarginVE;
            TablePos = [TableX, TableY, TableW, TableH];

            % Update positions
            set(this.OKButton,    'Position', OKButtonPos);
            set(this.TTContainer, 'Position', TablePos);
        end

        % *********************************
        % **** Data transfer functions ****
        % *********************************

        function TransferDataToScreen(this)
            % Cache string dictionary class
            SD = Simulink.sdi.StringDict;

            % Construct table data
            TableData = {SD.IGModelSourceColName, this.Data.ModelSource;
                         SD.IGBlockSourceColName, this.Data.BlockSource;  
                         SD.IGPortIndexColName,   num2str(this.Data.PortIndex);
                         SD.mgSigLabel,           this.Data.SignalLabel;                  
                         SD.IGRootSourceColName,  this.Data.RootSource;                           
                         SD.IGTimeSourceColName,  this.Data.TimeSource;  
                         SD.IGDataSourceColName,  this.Data.DataSource;  
                         SD.mgDimension,          num2str(this.Data.SampleDims); 
                         SD.mgChannel,            num2str(this.Data.Channel);   
                         SD.mgSID,                this.Data.SID;
                         SD.mgRunID,              this.Data.RunID;
                         SD.mgDataID,             this.Data.DataID;
                         };
            
            [rows, ~] = size(TableData);
            
            % set values for the table
            for i=1:rows
                newRow = javaObjectEDT                      ...
                      ('com.mathworks.toolbox.sdi.sdi.Row', ...
                       2); 
                newRow.setValueAt(TableData{i, 1}, 0);                    
                newRow.setValueAt(TableData{i, 2}, 1);                    
                this.TTModel.addRow(newRow);
            end
        end

        % *******************
        % **** Callbacks ****
        % *******************

        function OKButtonCallback(this, s, e)%#ok
            this.Close();
        end

        function DialogResizeCallback(this, ~, ~)
            this.PositionControls();
        end

    end % methods - Private

end % classdef