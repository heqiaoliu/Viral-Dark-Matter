classdef AbstractTunerDlg < handle
    % AbstractTunerDlg defines PID tuner in MATLAB and Simulink
    %
    
    % Author(s): R. Chen
    % Copyright 2009-2010 The MathWorks, Inc.
    % $Revision: 1.1.8.7 $ $Date: 2010/04/30 00:36:20 $
 
    properties
        
        Handles
        Listeners
        
        DataSrc             % internal data object
        
        DesignModeContents  % basic and extended
        CurrentDesignMode   % changeable by the toolbar combobox
        
        SnapshotWC          % WC snapshot
        SnapshotPM          % PM snapshot
        
        BackgroundColor     % use java L&F background color for UI controls
        FormContents        
        PIDTypeContents        
        PIDSTDTypeContents                
        
    end
    
    properties (SetObservable = true)
        CurrentWC
        CurrentPM
    end
    
    methods(Access = 'public')
        
        % Constructor
        function this = AbstractTunerDlg()
            this.setConstants;
        end
        
        % set visible
        function show(this)
            figure(this.Handles.Figure);
        end
        
        % update interactive PID design and refresh plot panel
        function fastdesign(this)
            % Callback when desired WC or PM is changed from the control
            % design panel and interactive design is executed
            % interactive design
            OK = this.DataSrc.fastdesign(this.CurrentWC,this.CurrentPM);
            % update plot panel
            if OK
                s = this.DataSrc.generateTunedStructure;
                this.Handles.PlotPanel.setTunedController(s);
                % clear status text
                this.setStatusText('');
            else
                % when fast design cannot generate a valid PID, set warning
                this.setStatusText(pidtool.utPIDgetStrings('cst','wrong_controller'),'warning');
            end
        end
        
        % set status text
        function setStatusText(this, text, type)
            if isempty(text)
                this.Handles.StatusLabel.setIcon([]);
                this.Handles.StatusLabel.setText('');
            else
                switch type
                    case 'info'
                        this.Handles.StatusLabel.setIcon(com.mathworks.common.icons.DialogIcon.INFO.getIcon);
                    case 'warning'
                        this.Handles.StatusLabel.setIcon(com.mathworks.common.icons.DialogIcon.WARNING.getIcon);
                    case 'error'
                        this.Handles.StatusLabel.setIcon(com.mathworks.common.icons.DialogIcon.ERROR.getIcon);
                end
                this.Handles.StatusLabel.setText(text);
            end
        end
        
        % close function
        function close(this)
            %CLOSE exit function
            set(this.Handles.Figure,'CloseRequestFcn',[]);
            set(this.Handles.Figure,'DeleteFcn',[]);
            delete(this.Handles.Figure);
            delete(this.DataSrc);
            delete(this.Handles.PlotPanel);
            delete(this.Handles.DesignPanelBasic);
            delete(this.Handles.DesignPanelAdvanced);
            delete(this.Handles.PreferenceDlg.Handles.Figure);
            delete(this.Handles.PreferenceDlg);
            delete(this)
        end
        
    end
    
    methods (Abstract)
        initialize(this)
    end

    methods (Access = 'protected', Abstract)
        build(this)
        layout(this)
        importplant(this)
        exportplant(this)
        s = loadPreferences(this)
    end
    
    %Protected methods
    methods(Access = 'protected')

        function setConstants(this)
            % available choices
            this.DesignModeContents = {'basic','extended'};
            this.FormContents = {'parallel','standard'};
            this.PIDTypeContents = {'p','i','pi','pd','pdf','pid','pidf'};
            this.PIDSTDTypeContents = {'p','pi','pd','pdf','pid','pidf'};
            % set default background color as java background color
            foo = javaObjectEDT('com.mathworks.mwswing.MJPanel');            
            Red = foo.getBackground.getRed;
            Green = foo.getBackground.getGreen;
            Blue = foo.getBackground.getBlue;
            this.BackgroundColor = [Red Green Blue]/255;
        end
        
        % set axes mode
        function sliderMouseAction(this, hDesignPanel)
            % when knob is pressed, set refresh mode to quick to speed up
            % plot refreshment; when knob is released, set the mode back to
            % normal and force DataSrc dirty to repaint
            hw = ctrlMsgUtils.SuspendWarnings; %#ok<*NASGU>
            hResponses = this.Handles.PlotPanel.Handles.hResponsePlot.Responses;
            if hDesignPanel.MouseIsDragging
                set(hResponses,'refreshMode','quick');
            else
                set(hResponses,'refreshMode','normal');
                for ct=1:length(hResponses)
                    hResponses(ct).DataSrc.send('SourceChanged');
                end
            end
        end

        % add listeners
        function addListeners(this)
            % listen to WC changed event from basic design panel
            this.Listeners = addlistener(this.Handles.DesignPanelBasic,'WC','PostSet',@(x,y) responseSpeedUpdated(this));
            % listen to WC and PM changed event from basic design panel
            this.Listeners(2) = addlistener(this.Handles.DesignPanelAdvanced,'WC','PostSet',@(x,y) wcUpdated(this));
            this.Listeners(3) = addlistener(this.Handles.DesignPanelAdvanced,'PM','PostSet',@(x,y) pmUpdated(this));
            % listen to slider mouse actions
            this.Listeners(4) = addlistener(this.Handles.DesignPanelBasic,'MouseIsDragging','PostSet',@(x,y) sliderMouseAction(this, this.Handles.DesignPanelBasic));
            this.Listeners(5) = addlistener(this.Handles.DesignPanelAdvanced,'MouseIsDragging','PostSet',@(x,y) sliderMouseAction(this, this.Handles.DesignPanelAdvanced));
            % listen to current WC/PM change
            this.Listeners(6) = addlistener(this,'CurrentWC','PostSet',@(x,y) fastdesign(this));
            this.Listeners(7) = addlistener(this,'CurrentPM','PostSet',@(x,y) fastdesign(this));
        end
        
        %% Build common GUI components
        function buildFigure(this)
            this.Handles.Figure = figure('Color',this.BackgroundColor,...
                 'IntegerHandle','off', ...
                 'Menubar','None',...
                 'Toolbar','None',...
                 'DockControl','off',...
                 'Name',pidtool.utPIDgetStrings('cst','tunerdlg_title'), ...
                 'NumberTitle','off', ...
                 'Unit','pixels', ...
                 'Visible','off', ...
                 'HandleVisibility','off',...
                 'UserData',this);
        end

        function buildStatusBar(this)
            this.Handles.StatusLabel = javaObjectEDT('com.mathworks.mwswing.MJLabel');            
            this.Handles.StatusLabel.setName('PIDTUNER_STATUSLABEL');
            this.Handles.StatusLabel.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
            StatusBarPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel',java.awt.BorderLayout(0,0));
            StatusBarPanel.add(this.Handles.StatusLabel,java.awt.BorderLayout.WEST);
            [~, StatusBarPanelCONTAINER] = javacomponent(StatusBarPanel,[0.1,0.1,0.9,0.9],this.Handles.Figure);
            set(StatusBarPanelCONTAINER,'units','character')
            this.Handles.StatusBarPanel = StatusBarPanel;
            this.Handles.StatusBarPanelCONTAINER = StatusBarPanelCONTAINER;
        end
        
        function buildDesignPanel(this)
            this.Handles.DesignPanelBasic = pidtool.ControllerDesignPanelBasic;
            this.Handles.DesignPanelAdvanced = pidtool.ControllerDesignPanelAdvanced;
            if strcmp(this.DataSrc.Type,'p') || strcmp(this.DataSrc.Type,'i')
                this.Handles.DesignPanelAdvanced.setPMVisible(false);
            end
            CardPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel',java.awt.CardLayout);
            CardPanel.add(this.Handles.DesignPanelBasic.Handles.Panel, 'Basic');
            CardPanel.add(this.Handles.DesignPanelAdvanced.Handles.Panel, 'Advanced');
            [~, CardPanelCONTAINER] = javacomponent(CardPanel,[0.1,0.1,0.9,0.9],this.Handles.Figure);
            set(CardPanelCONTAINER,'units','character')
            this.Handles.CardPanel = CardPanel;
            this.Handles.CardPanelCONTAINER = CardPanelCONTAINER;
        end
        
        function plotchanged(this)
        %PREFCHANGED listen to the 'Settings' property of preference dialog

        % Author(s): R. Chen
        % Copyright 2009-2010 The MathWorks, Inc.
        % $Revision: 1.1.8.7 $ $Date: 2010/04/30 00:36:20 $

        Settings = this.Handles.PreferenceDlg.PlotSettings;
        % set property in plot panel
        Panel = this.Handles.PlotPanel;
        Panel.TunedAxesColor = Settings.TunedColor;
        Panel.BaseAxesColor = Settings.BaseColor;
        % refresh plot
        Panel.Handles.hResponsePlot.Responses(Panel.TunedAxesIndex).setstyle('Color',Panel.TunedAxesColor);
        Panel.Handles.hResponsePlot.Responses(Panel.BaseAxesIndex).setstyle('Color',Panel.BaseAxesColor);
        % refresh table
        tmp = javaObjectEDT('javax.swing.table.DefaultTableCellRenderer');
        color = Settings.TunedColor;
        jcolor = java.awt.Color(color(1),color(2),color(3));
        tmp.setForeground(jcolor);
        tmp.setBackground(java.awt.Color(this.BackgroundColor(1),this.BackgroundColor(2),this.BackgroundColor(3)));
        Panel.Handles.ParameterTable.getColumnModel.getColumn(Panel.TunedTableIndex).setCellRenderer(tmp);
        Panel.Handles.ParameterTable.repaint;
        tmp = javaObjectEDT('javax.swing.table.DefaultTableCellRenderer');
        tmp.setForeground(jcolor);
        tmp.setBackground(java.awt.Color(this.BackgroundColor(1),this.BackgroundColor(2),this.BackgroundColor(3)));
        Panel.Handles.MetricTable.getColumnModel.getColumn(Panel.TunedTableIndex).setCellRenderer(tmp);
        Panel.Handles.MetricTable.repaint;
        end
        
    end
    
end

%% Listener Callbacks
function responseSpeedUpdated(this)
    % Callback when WC changed in basic mode
    if strcmpi(this.CurrentDesignMode,'basic')
        % update plot panel
        this.CurrentWC = this.Handles.DesignPanelBasic.WC;
    end
end

function wcUpdated(this)
    % Callback when WC changed in extended mode
    if strcmpi(this.CurrentDesignMode,'extended')
        % update plot panel
        this.CurrentWC = this.Handles.DesignPanelAdvanced.WC;
    end
end

function pmUpdated(this)
    % Callback when WC changed in extended mode
    if strcmpi(this.CurrentDesignMode,'extended')
        % update plot panel
        this.CurrentPM = this.Handles.DesignPanelAdvanced.PM;
    end
end
