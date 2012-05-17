classdef ResponsePlotPanel < handle
    % @ResponsePlotPanelBlk subclass

    %   Author(s): R. Chen
    %   Copyright 2009-2010 The MathWorks, Inc.
    %	 $Revision: 1.1.8.5.2.1 $  $Date: 2010/07/07 13:42:31 $
    
    properties

        Handles
        Listeners
        
        Platform
        DOF
        
        ParentFigure
        BackgroundColor
        PlotTypeContents
        PlotSystemContents
        StabilityContents
        
        TunedController        
        BaseController
        
        TunedAxesColor
        TunedAxesIndex
        TunedTableIndex
        BaseAxesColor
        BaseAxesIndex
        BaseTableIndex
        
        ShownTable
        ShownLegend
        RemovedParameterTableColumn
        RemovedMetricTableColumn

    end
    
    methods

        %% ----------
        % Constructor
        %% ----------
        function this = ResponsePlotPanel(s,Data)
            this.Platform = s.Platform;
            this.DOF = s.DOF;
            this.ParentFigure = s.ParentFigure;
            this.BackgroundColor = s.BackgroundColor;
            this.TunedAxesIndex = s.TunedAxesIndex;
            this.TunedTableIndex = s.TunedTableIndex;
            this.TunedAxesColor = s.TunedAxesColor;
            this.BaseAxesIndex = s.BaseAxesIndex;
            this.BaseTableIndex = s.BaseTableIndex;
            this.BaseAxesColor = s.BaseAxesColor;
            this.ShownLegend = s.ShownLegend;
            this.ShownTable = s.ShownTable;
            this.setConstants;            
            this.build(Data);
            this.setDisplayLegend;
            this.toggletable;
        end
                
        %% ----------
        % GUI
        %% ----------
        % re-position
        function setPosition(this, Position)
            set(this.Handles.Panel,'Position',Position);
        end

        % resize
        function layout(this)
            p = get(this.Handles.Panel,'Position');
            fw = p(3);  
            fh = p(4);
            hTopStrip = 4;
            
            if this.ShownTable
                tmp = hgconvertunits(this.ParentFigure, [10 4 max(0.01,fw-90) max(0.01,fh-hTopStrip-4.2)], 'character', 'normalized', this.Handles.Panel);
            else
                tmp = hgconvertunits(this.ParentFigure, [10 4 max(0.01,fw-20) max(0.01,fh-hTopStrip-4.2)], 'character', 'normalized', this.Handles.Panel);
            end
            set(this.Handles.hResponsePlot.AxesGrid,'Position',tmp);
            
            % set table panel
            x0 = max(0.01,fw-74);
            y0 = 1.5;
            width = min(71,fw);
            height = max(0.01, fh-hTopStrip-2.5);
            set(this.Handles.TablePanelCONTAINER,'Position',[x0 y0 width height]);

            set(this.Handles.PlotTypeTextCONTAINER,'Position',[4 fh-hTopStrip 8 2]);
            set(this.Handles.PlotTypeComboBoxCONTAINER,'Position',[13 fh-hTopStrip 14 2]);
            set(this.Handles.PlotSystemTextCONTAINER,'Position',[30 fh-hTopStrip 12 2]);
            set(this.Handles.PlotSystemComboBoxCONTAINER,'Position',[43 fh-hTopStrip 36 2]);
            set(this.Handles.ShowBaseCheckBoxCONTAINER,'Position',[84 fh-hTopStrip 42 2]);
            set(this.Handles.MoreTextCONTAINER,'Position',[fw-30 fh-hTopStrip 22 2]);
            set(this.Handles.MoreButtonCONTAINER,'Position',[fw-8 fh-hTopStrip 5 2]);
        end
        
        % set legend status
        function setLegendVisible(this, val)
            this.ShownLegend = val;
            this.setDisplayLegend;
        end
        
        %% ----------
        % Controller update
        %% ----------
        % update tuned controller meta information
        function setTunedController(this, s)
            this.updateAxes(this.TunedAxesIndex, s.OLsys, s.r2y, s.r2u, s.id2y, s.od2y, s.Plant);
            this.updateParameters(this.TunedTableIndex, s.Type, s.P, s.I, s.D, s.N, s.b, s.c);
            if this.ShownTable
                this.updateMetrics(this.TunedTableIndex, s.OLsys, s.r2y, s.IsStable);
            end
            this.TunedController = s;            
        end
        
        % update base controller meta information
        function setBaseController(this, s)
            this.updateAxes(this.BaseAxesIndex, s.OLsys, s.r2y, s.r2u, s.id2y, s.od2y, s.Plant);
            this.updateParameters(this.BaseTableIndex, s.Type, s.P, s.I, s.D, s.N, s.b, s.c);
            this.updateMetrics(this.BaseTableIndex, s.OLsys, s.r2y, s.IsStable);
            this.BaseController = s;
        end
        
        %% ----------
        % GUI update
        %% ----------
        % update axes
        function updateAxes(this, Index, OLsys, r2y, r2u, id2y, od2y, Plant)
            % update plot
            hw = ctrlMsgUtils.SuspendWarnings; %#ok<*NASGU>
            hResponses = get(this.Handles.hResponsePlot,'Responses');
            hDataSrc = get(hResponses(Index),'DataSrc');
            PlotSystem = this.PlotSystemContents{this.Handles.PlotSystemComboBoxCOMPONENT.getSelectedIndex+1};
            switch PlotSystem
                case 'r2y'
                    hDataSrc.Model = r2y;
                case 'r2u'
                    hDataSrc.Model = r2u;
                case 'id2y'
                    hDataSrc.Model = id2y;
                case 'od2y'
                    hDataSrc.Model = od2y;
                case 'open'
                    hDataSrc.Model = OLsys;
                case 'plant'
                    hDataSrc.Model = Plant;
            end
        end
        
        % update metric table
        function updateMetrics(this, Index, OLsys, r2y, IsStable)
            % update performance table
            col = Index+1;
            s = pidtool.utPIDgetmetrics(OLsys,r2y);
            Data = cell(this.Handles.MetricTableModel.data);
            Data{1,col} = sprintf('%0.3g',s.RiseTime);
            Data{2,col} = sprintf('%0.3g',s.SettlingTime);
            Data{3,col} = sprintf('%0.3g',s.Overshoot);
            Data{4,col} = sprintf('%0.3g',s.Peak);
            Data{5,col} = sprintf('%0.3g @ %0.3g',20*log10(s.GainMargin),s.GainMarginAt);
            Data{6,col} = sprintf('%0.3g @ %0.3g',s.PhaseMargin,s.PhaseMarginAt);
            Data{7,col} = this.StabilityContents{IsStable+1};
            this.Handles.MetricTableModel.setData(Data);
        end
        
        % update parameter table
        function updateParameters(this, Index, Type, P, I, D, N, b, c)
            % update parameter table
            col = Index+1;
            Data = cell(this.Handles.ParameterTableModel.data);
            if this.DOF == 1
                switch Type
                    case 'p'
                        Data{1,col} = num2str(P);
                        Data{2,col} = ' ';
                        Data{3,col} = ' ';
                        Data{4,col} = ' ';
                    case 'i'
                        Data{1,col} = ' ';
                        Data{2,col} = num2str(I);
                        Data{3,col} = ' ';
                        Data{4,col} = ' ';
                    case 'pi'
                        Data{1,col} = num2str(P);
                        Data{2,col} = num2str(I);
                        Data{3,col} = ' ';
                        Data{4,col} = ' ';
                    case 'pd'
                        Data{1,col} = num2str(P);
                        Data{2,col} = ' ';
                        Data{3,col} = num2str(D);
                        Data{4,col} = ' ';
                    case 'pdf'
                        Data{1,col} = num2str(P);
                        Data{2,col} = ' ';
                        Data{3,col} = num2str(D);
                        Data{4,col} = num2str(N);
                    case 'pid'
                        Data{1,col} = num2str(P);
                        Data{2,col} = num2str(I);
                        Data{3,col} = num2str(D);
                        Data{4,col} = ' ';
                    case 'pidf'
                        Data{1,col} = num2str(P);
                        Data{2,col} = num2str(I);
                        Data{3,col} = num2str(D);
                        Data{4,col} = num2str(N);
                end
            else
                switch Type
                    case 'pi'
                        Data{1,col} = num2str(P);
                        Data{2,col} = num2str(I);
                        Data{3,col} = ' ';
                        Data{4,col} = ' ';
                        Data{5,col} = num2str(b);
                        Data{6,col} = ' ';
                    case 'pdf'
                        Data{1,col} = num2str(P);
                        Data{2,col} = ' ';
                        Data{3,col} = num2str(D);
                        Data{4,col} = num2str(N);
                        Data{5,col} = num2str(b);
                        Data{6,col} = num2str(c);
                    case 'pidf'
                        Data{1,col} = num2str(P);
                        Data{2,col} = num2str(I);
                        Data{3,col} = num2str(D);
                        Data{4,col} = num2str(N);
                        Data{5,col} = num2str(b);
                        Data{6,col} = num2str(c);
                end
            end            
            this.Handles.ParameterTableModel.setData(Data);
        end
        
        % update parameter table
        function updateGainNames(this, Form)
            % update parameter table
            Data = cell(this.Handles.ParameterTableModel.data);
            if this.DOF == 1
                if strcmp(Form,'parallel');
                    Data(1,1) = {'Kp'};
                    Data(2,1) = {'Ki'};
                    Data(3,1) = {'Kd'};
                    Data(4,1) = {'Tf'};
                else
                    Data(1,1) = {'Kp'};
                    Data(2,1) = {'Ti'};
                    Data(3,1) = {'Td'};
                    Data(4,1) = {'N'};
                end
            else
                if strcmp(this.Form,'parallel');
                    Data(1,1) = {'Kp'};
                    Data(2,1) = {'Ki'};
                    Data(3,1) = {'Kd'};
                    Data(4,1) = {'Tf'};
                    Data(5,1) = {'b'};
                    Data(6,1) = {'c'};
                else
                    Data(1,1) = {'Kp'};
                    Data(2,1) = {'Ti'};
                    Data(3,1) = {'Td'};
                    Data(4,1) = {'N'};
                    Data(5,1) = {'b'};                    
                    Data(5,1) = {'c'};                    
                end
            end            
            this.Handles.ParameterTableModel.setData(Data);
        end
        
        % set visibility of baseline response
        function showBaseResponse(this)
            hw = ctrlMsgUtils.SuspendWarnings; %#ok<*NASGU>
            hgroup = handle(this.Handles.hResponsePlot.Responses(this.BaseAxesIndex).Group);
            if this.Handles.ShowBaseCheckBoxCOMPONENT.isSelected
                % display baseline in legend
                for ct = 1:length(hgroup)
                    hgroup(ct).Annotation.LegendInformation.IconDisplayStyle = 'on';
                end
                % display baseline curve
                set(this.Handles.hResponsePlot.Responses(this.BaseAxesIndex),'visible','on');
                % display column in parameter table if necessary
                if this.Handles.ParameterTable.getColumnModel.getColumnCount < this.BaseTableIndex+1
                    this.Handles.ParameterTable.addColumn(this.RemovedParameterTableColumn);
                    this.RemovedParameterTableColumn = [];
                end
                % display column in metrics table if necessary
                if this.Handles.MetricTable.getColumnModel.getColumnCount < this.BaseTableIndex+1
                    this.Handles.MetricTable.addColumn(this.RemovedMetricTableColumn);
                    this.RemovedMetricTableColumn = [];            
                end
            else
                % hide baseline in legend
                for ct = 1:length(hgroup)
                    hgroup(ct).Annotation.LegendInformation.IconDisplayStyle = 'off';
                end
                % hide baseline curve
                set(this.Handles.hResponsePlot.Responses(this.BaseAxesIndex),'visible','off');
                % hide column in parameter table if necessary
                if this.Handles.ParameterTable.getColumnModel.getColumnCount == this.BaseTableIndex+1
                    this.RemovedParameterTableColumn = this.Handles.ParameterTable.getColumnModel.getColumn(this.BaseTableIndex);
                    this.Handles.ParameterTable.removeColumn(this.RemovedParameterTableColumn);
                end
                % hide column in metrics table if necessary
                if this.Handles.MetricTable.getColumnModel.getColumnCount == this.BaseTableIndex+1
                    this.RemovedMetricTableColumn = this.Handles.MetricTable.getColumnModel.getColumn(this.BaseTableIndex);            
                    this.Handles.MetricTable.removeColumn(this.RemovedMetricTableColumn);
                end
            end
            hAxes = handle(legend(this.Handles.Axes));
            if ishandle(hAxes)
                methods(hAxes,'refresh')
            end
        end
        
    end
    
    methods (Access = protected)
        
        %% ----------
        % build GUI
        %% ----------
        function build(this, ParameterData)
            
            % main panel
            Panel = uipanel('parent',this.ParentFigure,'BackgroundColor', this.BackgroundColor);
            set(Panel,'units','character','BorderType','beveledout','BorderWidth',2);
            % 1-1: type text
            PlotTypeText = javaObjectEDT('com.mathworks.mwswing.MJLabel',pidtool.utPIDgetStrings('cst','plotpanel_plottype'));
            PlotTypeText.setName('PIDTUNER_PLOTTYPETEXT');
            PlotTypeText.setHorizontalAlignment(javax.swing.JLabel.RIGHT);
            pidtool.utPIDaddCSH('control',PlotTypeText,'pidtuner_plottype');
            [PlotTypeTextCOMPONENT, PlotTypeTextCONTAINER] = javacomponent(PlotTypeText,[.1,.1,.9,.9],Panel);
            set(PlotTypeTextCONTAINER,'units','character')
            % 1-2: type combobox
            PlotTypeComboBox = javaObjectEDT('com.mathworks.mwswing.MJComboBox',pidtool.utPIDgetStrings('cst','plotpanel_typecombo',2));
            PlotTypeComboBox.setName('PIDTUNER_PLOTTYPECOMBOBOX');
            PlotTypeComboBox.setSelectedIndex(0);
            [PlotTypeComboBoxCOMPONENT, PlotTypeComboBoxCONTAINER] = javacomponent(PlotTypeComboBox,[.1,.1,.9,.9],Panel);
            set(PlotTypeComboBoxCONTAINER,'units','character')
            % 1-1: type text
            PlotSystemText = javaObjectEDT('com.mathworks.mwswing.MJLabel',pidtool.utPIDgetStrings('cst','plotpanel_plotsystem'));
            PlotSystemText.setName('PIDTUNER_PLOTSYSTEMTEXT');
            PlotSystemText.setHorizontalAlignment(javax.swing.JLabel.RIGHT);
            pidtool.utPIDaddCSH('control',PlotSystemText,'pidtuner_plotsystem');
            [PlotSystemTextCOMPONENT, PlotSystemTextCONTAINER] = javacomponent(PlotSystemText,[.1,.1,.9,.9],Panel);
            set(PlotSystemTextCONTAINER,'units','character')
            % 1-2: type combobox
            PlotSystemComboBox = javaObjectEDT('com.mathworks.mwswing.MJComboBox',pidtool.utPIDgetStrings('cst','plotpanel_systemcombo',6));
            PlotSystemComboBox.setName('PIDTUNER_PLOTSYSTEMCOMBOBOX');
            PlotSystemComboBox.setSelectedIndex(0);
            [PlotSystemComboBoxCOMPONENT, PlotSystemComboBoxCONTAINER] = javacomponent(PlotSystemComboBox,[.1,.1,.9,.9],Panel);
            set(PlotSystemComboBoxCONTAINER,'units','character')
            % 1-3: view checkbox (selected by default)
            ShowBaseCheckBox = javaObjectEDT('com.mathworks.mwswing.MJCheckBox',...
                pidtool.utPIDgetStrings(this.Platform,'tunerdlg_showbase'),true);
            ShowBaseCheckBox.setName('PIDTUNER_SHOWBLOCKCHECKBOX');
            if strcmpi(this.Platform,'cst')
                pidtool.utPIDaddCSH('control',ShowBaseCheckBox,'pidtuner_comparecheckbox');
            else
                pidtool.utPIDaddCSH('slcontrol',ShowBaseCheckBox,'pidtuner_comparecheckbox');
            end
            [ShowBaseCheckBoxCOMPONENT, ShowBaseCheckBoxCONTAINER] = javacomponent(ShowBaseCheckBox,[.1,.1,.9,.9],Panel);
            set(ShowBaseCheckBoxCONTAINER,'units','character')
            % 1-4: more text
            MoreText = javaObjectEDT('com.mathworks.mwswing.MJLabel');
            MoreText.setName('PIDTUNER_MORETEXT');
            pidtool.utPIDaddCSH('control',MoreText,'pidtuner_showtable');
            MoreText.setHorizontalAlignment(javax.swing.SwingConstants.RIGHT);
            [MoreTextCOMPONENT, MoreTextCONTAINER] = javacomponent(MoreText,[.1,.1,.9,.9],Panel);
            set(MoreTextCONTAINER,'units','character')
            % 1-5: show more button
            MoreButton = javaObjectEDT('com.mathworks.mwswing.MJButton');
            MoreButton.setName('PIDTUNER_MOREBUTTON');
            MoreButton.setFlyOverAppearance(true);
            MoreButton.setFocusTraversable(false);
            [MoreButtonCOMPONENT, MoreButtonCONTAINER] = javacomponent(MoreButton,[.1,.1,.9,.9],Panel);
            set(MoreButtonCONTAINER,'units','character')
            
            % 2: axes
            Axes = axes('parent',Panel,'tag','PIDTUNER_AXES');

            % 3: tables
            Prefs = cstprefs.tbxprefs;

            % box
            ParameterTablePanel = javaObjectEDT('com.mathworks.mwswing.MJPanel');
            titleborder = javaMethodEDT('createTitledBorder','javax.swing.BorderFactory',pidtool.utPIDgetStrings('cst','plotpanel_parametertablebox'));
            javaObjectEDT(titleborder);
            ParameterTablePanel.setBorder(titleborder),
            ParameterTablePanel.setLayout(java.awt.BorderLayout(0,0));
            ParameterTablePanel.setFont(Prefs.JavaFontB);            
            % table model
            str1 = pidtool.utPIDgetStrings(this.Platform,'plotpanel_tunedtitle');
            str2 = pidtool.utPIDgetStrings(this.Platform,'plotpanel_basetitle');
            ParameterTableModel = javaObjectEDT('com.mathworks.toolbox.control.tableclasses.PIDTunerTableModel',ParameterData,{'',str1,str2},-1);
            % table
            ParameterTable = javaObjectEDT('com.mathworks.mwswing.MJTable',ParameterTableModel);
            ParameterTable.setName('PIDTUNER_PARAMETERTABLE');
            ParameterTable.setRowSelectionAllowed(false);
            % change tuned column renderer 
            tmp = javaObjectEDT('javax.swing.table.DefaultTableCellRenderer');
            tmp.setForeground(java.awt.Color(this.TunedAxesColor(1),this.TunedAxesColor(2),this.TunedAxesColor(3)));
            tmp.setBackground(java.awt.Color(this.BackgroundColor(1),this.BackgroundColor(2),this.BackgroundColor(3)));
            ParameterTable.getColumnModel.getColumn(this.TunedTableIndex).setCellRenderer(tmp);
            % change baseline column renderer 
            tmp = javaObjectEDT('javax.swing.table.DefaultTableCellRenderer');
            tmp.setForeground(java.awt.Color(0,0,0));
            tmp.setBackground(java.awt.Color(this.BackgroundColor(1),this.BackgroundColor(2),this.BackgroundColor(3)));
            ParameterTable.getColumnModel.getColumn(this.BaseTableIndex).setCellRenderer(tmp);
            % change head column renderer 
            tmp = javaObjectEDT('javax.swing.table.DefaultTableCellRenderer');
            tmp.setBackground(java.awt.Color(this.BackgroundColor(1),this.BackgroundColor(2),this.BackgroundColor(3)));
            ParameterTable.getColumnModel.getColumn(0).setCellRenderer(tmp);
            % scroll size
            ParameterTable.setPreferredScrollableViewportSize(java.awt.Dimension(100,size(ParameterData,1)*18))
            % default width
            ParameterTable.getColumnModel.getColumn(0).setPreferredWidth(180);
            % hide grid
            ParameterTable.setGridColor(java.awt.Color(this.BackgroundColor(1),this.BackgroundColor(2),this.BackgroundColor(3)));
            % add to scroll pane
            ParameterTableScrollPane = javaObjectEDT('com.mathworks.mwswing.MJScrollPane',ParameterTable);
            ParameterTablePanel.add(ParameterTableScrollPane,java.awt.BorderLayout.NORTH);            

            % box
            MetricTablePanel = javaObjectEDT('com.mathworks.mwswing.MJPanel');
            titleborder = javaMethodEDT('createTitledBorder','javax.swing.BorderFactory',pidtool.utPIDgetStrings('cst','plotpanel_metrictablebox'));
            javaObjectEDT(titleborder);
            MetricTablePanel.setBorder(titleborder),
            MetricTablePanel.setLayout(java.awt.BorderLayout(0,0));
            MetricTablePanel.setFont(Prefs.JavaFontB);            
            % table model
            tmp = blanks(4);            
            Data = {pidtool.utPIDgetStrings('cst','plotpanel_metric1'),tmp,tmp;...
                    pidtool.utPIDgetStrings('cst','plotpanel_metric2'),tmp,tmp;...
                    [pidtool.utPIDgetStrings('cst','plotpanel_metric3') ' (%)'],tmp,tmp;...
                    pidtool.utPIDgetStrings('cst','plotpanel_metric4'),tmp,tmp;...
                    pidtool.utPIDgetStrings('cst','plotpanel_metric5'),tmp,tmp;...
                    pidtool.utPIDgetStrings('cst','plotpanel_metric6'),tmp,tmp;...
                    pidtool.utPIDgetStrings('cst','plotpanel_metric7'),tmp,tmp};
            str1 = pidtool.utPIDgetStrings(this.Platform,'plotpanel_tunedtitle');
            str2 = pidtool.utPIDgetStrings(this.Platform,'plotpanel_basetitle');
            MetricTableModel = javaObjectEDT('com.mathworks.toolbox.control.tableclasses.PIDTunerTableModel',Data,{'',str1,str2},-1);                
            % table
            MetricTable = javaObjectEDT('com.mathworks.mwswing.MJTable',MetricTableModel);
            MetricTable.setName('PIDTUNER_METRICTABLE');
            MetricTable.setRowSelectionAllowed(false);
            % change tuned column renderer 
            tmp = javaObjectEDT('javax.swing.table.DefaultTableCellRenderer');
            tmp.setForeground(java.awt.Color(this.TunedAxesColor(1),this.TunedAxesColor(2),this.TunedAxesColor(3)));
            tmp.setBackground(java.awt.Color(this.BackgroundColor(1),this.BackgroundColor(2),this.BackgroundColor(3)));
            MetricTable.getColumnModel.getColumn(this.TunedTableIndex).setCellRenderer(tmp);
            % change baseline column renderer 
            tmp = javaObjectEDT('javax.swing.table.DefaultTableCellRenderer');
            tmp.setForeground(java.awt.Color(0,0,0));
            tmp.setBackground(java.awt.Color(this.BackgroundColor(1),this.BackgroundColor(2),this.BackgroundColor(3)));
            MetricTable.getColumnModel.getColumn(this.BaseTableIndex).setCellRenderer(tmp);
            % change head column renderer 
            tmp = javaObjectEDT('javax.swing.table.DefaultTableCellRenderer');
            tmp.setBackground(java.awt.Color(this.BackgroundColor(1),this.BackgroundColor(2),this.BackgroundColor(3)));
            MetricTable.getColumnModel.getColumn(0).setCellRenderer(tmp);
            % default width
            MetricTable.getColumnModel().getColumn(0).setPreferredWidth(180);
            % hide grid
            MetricTable.setGridColor(java.awt.Color(this.BackgroundColor(1),this.BackgroundColor(2),this.BackgroundColor(3)));
            % scroll size
            MetricTableScrollPane = javaObjectEDT('com.mathworks.mwswing.MJScrollPane',MetricTable);
            MetricTablePanel.add(MetricTableScrollPane,java.awt.BorderLayout.CENTER);            
            
            TablePanel = javaObjectEDT('com.mathworks.mwswing.MJPanel');
            TablePanel.setLayout(java.awt.BorderLayout(0,15));
            TablePanel.setFont(Prefs.JavaFontB);            
            TablePanel.add(ParameterTablePanel,java.awt.BorderLayout.NORTH);
            TablePanel.add(MetricTablePanel,java.awt.BorderLayout.CENTER);
            [TablePanelCOMPONENT, TablePanelCONTAINER] = javacomponent(TablePanel,[.1,.1,.9,.9],Panel);
            set(TablePanelCONTAINER,'units','character')

            h = handle(PlotTypeComboBox,'callbackproperties');
            hListener = handle.listener(h, 'ActionPerformed',{@(x,y) clickPlotTypeComboBox(this)});
            this.Handles.PlotTypeComboBoxListener = hListener;
            h = handle(PlotSystemComboBox,'callbackproperties');
            hListener = handle.listener(h, 'ActionPerformed',{@(x,y) clickPlotSystemComboBox(this)});
            this.Handles.PlotSystemComboBoxListener = hListener;
            h = handle(ShowBaseCheckBox,'callbackproperties');
            hListener = handle.listener(h, 'ActionPerformed',{@(x,y) clickShowBaseCheckBox(this)});
            this.Handles.ShowBaseCheckBoxListener = hListener;
            h = handle(MoreButton,'callbackproperties');
            hListener = handle.listener(h, 'ActionPerformed',{@(x,y) clickMoreButton(this)});
            this.Handles.MoreButtonListener = hListener;

            this.Handles.Panel = Panel;
            this.Handles.PlotTypeTextCOMPONENT = PlotTypeTextCOMPONENT;
            this.Handles.PlotTypeTextCONTAINER = PlotTypeTextCONTAINER';
            this.Handles.PlotTypeComboBoxCOMPONENT = PlotTypeComboBoxCOMPONENT;
            this.Handles.PlotTypeComboBoxCONTAINER = PlotTypeComboBoxCONTAINER';
            this.Handles.PlotSystemTextCOMPONENT = PlotSystemTextCOMPONENT;
            this.Handles.PlotSystemTextCONTAINER = PlotSystemTextCONTAINER';
            this.Handles.PlotSystemComboBoxCOMPONENT = PlotSystemComboBoxCOMPONENT;
            this.Handles.PlotSystemComboBoxCONTAINER = PlotSystemComboBoxCONTAINER';
            this.Handles.ShowBaseCheckBoxCOMPONENT = ShowBaseCheckBoxCOMPONENT;
            this.Handles.ShowBaseCheckBoxCONTAINER = ShowBaseCheckBoxCONTAINER';
            this.Handles.MoreTextCOMPONENT = MoreTextCOMPONENT;
            this.Handles.MoreTextCONTAINER = MoreTextCONTAINER';
            this.Handles.MoreButtonCOMPONENT = MoreButtonCOMPONENT;
            this.Handles.MoreButtonCONTAINER = MoreButtonCONTAINER';
            this.Handles.Axes = Axes;
            this.Handles.ParameterTableModel = ParameterTableModel;
            this.Handles.ParameterTable = ParameterTable;
            this.Handles.MetricTableModel = MetricTableModel;
            this.Handles.MetricTable = MetricTable;
            this.Handles.TablePanelCOMPONENT = TablePanelCOMPONENT;
            this.Handles.TablePanelCONTAINER = TablePanelCONTAINER;
            
            hResponsePlot = this.resetResponse;
            this.Handles.hResponsePlot = hResponsePlot;
        end
        
        function setConstants(this)
            this.PlotTypeContents = {'step','bode'};
            this.PlotSystemContents = {'r2y','r2u','id2y','od2y','open','plant'};
            StableStr = pidtool.utPIDgetStrings('cst','tunerdlg_stable');
            UnstableStr = pidtool.utPIDgetStrings('cst','tunerdlg_unstable');
            this.StabilityContents = {UnstableStr,StableStr};
        end
        
        %% ----------
        % GUI actions
        %% ----------
        function clickMoreButton(this)
            this.ShownTable = ~this.ShownTable;    
            tablesize = get(this.Handles.TablePanelCONTAINER,'position');
            if this.ShownTable
                % update metric table because it is not updated when closed
                this.updateMetrics(this.TunedTableIndex, this.TunedController.OLsys, ...
                    this.TunedController.r2y, this.TunedController.IsStable);
                % enlarge figure window
                POS = get(this.ParentFigure,'Position');
                POS(3) = POS(3) + tablesize(3) + 5;
                POSinPixels = hgconvertunits(this.ParentFigure, POS, 'character', 'pixels', this.Handles.Panel);
                % relocate figure window if it goes out of bound
                scrsz = get(0,'ScreenSize');
                if POSinPixels(1)+POSinPixels(3)>scrsz(3);
                    POSinPixels(1) = scrsz(3)-POSinPixels(3)-10;    
                end
                POS = hgconvertunits(this.ParentFigure, POSinPixels, 'pixels', 'character', this.Handles.Panel);
                set(this.ParentFigure,'Position',POS);
                drawnow
            else
                tmp = get(this.ParentFigure,'Position');
                tmp(3) = tmp(3) - tablesize(3) - 5;
                set(this.ParentFigure,'Position',tmp);
            end
            this.toggletable;    
        end

        function toggletable(this)
            if this.ShownTable
                set(this.Handles.TablePanelCONTAINER,'Visible','on')
                this.Handles.MoreButtonCOMPONENT.setIcon(com.mathworks.common.icons.CommonIcon.BACKWARD.getIcon);
                this.Handles.MoreTextCOMPONENT.setText(pidtool.utPIDgetStrings('cst','plotpanel_more_hide'));
            else
                set(this.Handles.TablePanelCONTAINER,'Visible','off')
                this.Handles.MoreButtonCOMPONENT.setIcon(com.mathworks.common.icons.CommonIcon.FORWARD.getIcon);
                this.Handles.MoreTextCOMPONENT.setText(pidtool.utPIDgetStrings('cst','plotpanel_more_show'));
            end
        end
        
        function hResponsePlot = resetResponse(this)
            PlotType = this.PlotTypeContents{this.Handles.PlotTypeComboBoxCOMPONENT.getSelectedIndex+1};
            switch PlotType
                case 'step'
                    hResponsePlot = stepplot(this.Handles.Axes,tf(1,[1 1]),tf(1,[1 1]));
                case 'bode'
                    hResponsePlot = bodeplot(this.Handles.Axes,tf(1,[1 1]),tf(1,[1 1]));
            end
            hResponsePlot.AxesGrid.Title = '';
            hResponsePlot.AxesGrid.Grid = 'on';
            hResponsePlot.Responses(this.BaseAxesIndex).setstyle('Color',this.BaseAxesColor);
            hResponsePlot.Responses(this.TunedAxesIndex).setstyle('Color',this.TunedAxesColor);
            hh = get(hResponsePlot,'Responses');
            set(hh(this.BaseAxesIndex),'Name',pidtool.utPIDgetStrings(this.Platform,'plotpanel_baseresp'));
            set(hh(this.TunedAxesIndex),'Name',pidtool.utPIDgetStrings(this.Platform,'plotpanel_tunedresp'));
            mRoot = hResponsePlot.AxesGrid.findMenu('waveforms');
            set(mRoot,'visible','off')
        end
        
        function setDisplayLegend(this)
            if this.ShownLegend
                PlotType = this.PlotTypeContents{this.Handles.PlotTypeComboBoxCOMPONENT.getSelectedIndex+1};
                PlotSystem = this.PlotSystemContents{this.Handles.PlotSystemComboBoxCOMPONENT.getSelectedIndex+1};
                switch PlotType
                    case 'step'
                        switch PlotSystem
                            case {'r2y' 'r2u' 'plant'} 
                                legend(this.Handles.Axes,'location','southeast')
                            case {'id2y' 'od2y'}
                                legend(this.Handles.Axes,'location','northeast')
                            otherwise
                                legend(this.Handles.Axes,'location','northwest')
                        end
                    case 'bode'
                        legend(this.Handles.Axes,'location','southwest')
                end
            else
                legend(this.Handles.Axes,'hide')
            end
            hgroup = handle(this.Handles.hResponsePlot.Responses(this.BaseAxesIndex).Group);
            if this.Handles.ShowBaseCheckBoxCOMPONENT.isSelected
                for ct = 1:length(hgroup)
                    hgroup(ct).Annotation.LegendInformation.IconDisplayStyle = 'on';
                end
            else
                for ct = 1:length(hgroup)
                    hgroup(ct).Annotation.LegendInformation.IconDisplayStyle = 'off';
                end
            end
            hAxes = handle(legend(this.Handles.Axes));
            if ishandle(hAxes)
                methods(hAxes,'refresh')
            end
        end
        
        function clickPlotTypeComboBox(this)
            hResponsePlot = this.resetResponse;
            this.Handles.hResponsePlot = hResponsePlot;
            this.clickPlotSystemComboBox;
        end

        function clickPlotSystemComboBox(this)
            if this.Handles.ShowBaseCheckBoxCOMPONENT.isSelected
                set(this.Handles.hResponsePlot.Responses(this.BaseAxesIndex),'visible','on');
            else
                set(this.Handles.hResponsePlot.Responses(this.BaseAxesIndex),'visible','off');
            end
            % plot response
            this.updateAxes(this.TunedAxesIndex, ...
                this.TunedController.OLsys, this.TunedController.r2y, ...
                this.TunedController.r2u, this.TunedController.id2y, ...
                this.TunedController.od2y, this.TunedController.Plant);
            if ~isempty(this.BaseController)
                this.updateAxes(this.BaseAxesIndex, ...
                    this.BaseController.OLsys, this.BaseController.r2y, ...
                    this.BaseController.r2u, this.BaseController.id2y,...
                    this.BaseController.od2y,this.BaseController.Plant);    
            end
            % legend
            this.setDisplayLegend;
        end
        
        function clickShowBaseCheckBox(this)
            this.showBaseResponse;
        end

    end        

end

