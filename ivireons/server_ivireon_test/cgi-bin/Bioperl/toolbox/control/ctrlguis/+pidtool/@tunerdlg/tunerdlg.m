classdef tunerdlg < pidtool.AbstractTunerDlg
    % TUNERDLG Dialog to design a PID controller in MATLAB
    %
    
    % Author(s): R. Chen
    % Copyright 2009-2010 The MathWorks, Inc.
    % $Revision: 1.1.8.4.2.1 $ $Date: 2010/06/24 19:32:29 $
 
    methods
        
        %% constructor
        function this = tunerdlg(G,Type,Baseline)
            % super
            this = this@pidtool.AbstractTunerDlg;
            % load preference
            s = this.loadPreferences;
            % default design mode 
            this.CurrentDesignMode = s.DefaultDesignMode;
            % get plant information and controller information
            this.DataSrc = pidtool.DataSrcLTI(G,Type,Baseline);
            % build GUI components
            this.build(s);
            % one-click design
            this.design;
            % initialize GUI component
            this.initialize;
            % add default listeners
            this.addListeners;
            % build preference dialog
            PreferenceDlg = pidtool.PreferenceDlg(this.Handles.Figure,this.BackgroundColor);
            PreferenceDlg.setPlotPreferences(s);
            PreferenceDlg.setPIDPreferences(this.DataSrc);
            % listen to changes in preference dialog
            len = length(this.Listeners);
            this.Listeners(len+1) = addlistener(PreferenceDlg,'PlotSettings','PostSet',@(x,y) plotchanged(this));
            this.Listeners(len+2) = addlistener(PreferenceDlg,'PIDSettings','PostSet',@(x,y) pidchanged(this));
            this.Handles.PreferenceDlg = PreferenceDlg;
            % add figure callbacks
            set(this.Handles.Figure,...
                'ResizeFcn',@(x,y) layout(this),...
                'CloseRequestFcn',@(x,y) close(this),...
                'DeleteFcn',@(x,y) close(this));
            % make figure visible (resize func is called now)
            set(this.Handles.Figure,'Visible','on')
            % set parameter table visibility again (due to g637916)
            set(this.Handles.PlotPanel.Handles.TablePanelCONTAINER,'Visible',s.DefaultTableMode);
        end
        
        % update one-click PID design
        function design(this, options)
            if nargin==1
                options = pidtuneOptions;
            end
            if isempty(options.CrossoverFrequency)
                % one click
                WC = this.DataSrc.oneclick(options.PhaseMargin);
                % set Current WC
                this.CurrentWC = WC;
            else
                % fast design
                this.DataSrc.fastdesign(options.CrossoverFrequency,options.PhaseMargin);
                % set Current WC
                this.CurrentWC = options.CrossoverFrequency;
            end
            % set Current PM
            this.CurrentPM = options.PhaseMargin;
            % update status text
            if this.DataSrc.IsStable
                this.setStatusText('');
            else
                this.setStatusText(pidtool.utPIDgetStrings('cst','tunerdlg_oneclick_failure'),'warning');
            end
        end
        
        % close function
        function close(this)
            close@pidtool.AbstractTunerDlg(this);
        end
        
        % update dialog title 
        function updateName(this)
        	Title = sprintf('%s',pidtool.utPIDgetStrings('cst','tunerdlg_title')); 
            set(this.Handles.Figure,'Name',Title);
        end
        
    end
    
    %% Protected methods
    methods(Access = 'protected')
        build(this, s)
        layout(this)
        importplant(this)
        exportplant(this)
        pidchanged(this, type)
        s = loadPreferences(this)
        
        function buildToolbar(this, legendOnOff, designmode)
            % Create toolbar
            this.Handles.Toolbar = uitoolbar('Parent',this.Handles.Figure,'HandleVisibility','off');
            set(this.Handles.Toolbar,'Tag','PIDTOOLBAR');
            % import plant
            Cdata = imread(fullfile(matlabroot,'toolbox','shared','controllib','graphics','Resources','pid_plantimport.png'),'BackgroundColor',this.BackgroundColor);
            this.Handles.ImportToolbar = uipushtool('Parent',this.Handles.Toolbar,'Cdata',Cdata,'HandleVisibility','off');
            set(this.Handles.ImportToolbar,'tooltip',pidtool.utPIDgetStrings('cst','toolbar_tooltip_ip'),'Tag','PIDTOOLBAR_IMPORT');
            % export plant
            Cdata = imread(fullfile(matlabroot,'toolbox','shared','controllib','graphics','Resources','pid_plantexport.png'),'BackgroundColor',this.BackgroundColor);
            this.Handles.ExportToolbar = uipushtool('Parent',this.Handles.Toolbar,'Cdata',Cdata,'HandleVisibility','off');
            set(this.Handles.ExportToolbar,'tooltip',pidtool.utPIDgetStrings('cst','toolbar_tooltip_ep'),'Tag','PIDTOOLBAR_EXPORT');
            % plot tools
            this.Handles.ZoomInToolbar = uitoolfactory(this.Handles.Toolbar,'Exploration.ZoomIn');
            set(this.Handles.ZoomInToolbar,'Separator','on','Tag','PIDTOOLBAR_ZOOMIN');
            this.Handles.ZoomOutToolbar = uitoolfactory(this.Handles.Toolbar,'Exploration.ZoomOut');
            set(this.Handles.ZoomOutToolbar,'Tag','PIDTOOLBAR_ZOOMOUT');
            this.Handles.PanToolbar = uitoolfactory(this.Handles.Toolbar,'Exploration.Pan');
            set(this.Handles.PanToolbar,'Tag','PIDTOOLBAR_PAN');
            % legend
            Cdata = imread(fullfile(matlabroot,'toolbox','shared','controllib','graphics','Resources','pid_legend.png'),'BackgroundColor',this.BackgroundColor);
            this.Handles.LegendToolbar = uitoggletool('Parent',this.Handles.Toolbar,'Cdata',Cdata,'HandleVisibility','off');
            set(this.Handles.LegendToolbar,'tooltip',pidtool.utPIDgetStrings('cst','toolbar_tooltip_lg'),'Tag','PIDTOOLBAR_LEGEND');
            set(this.Handles.LegendToolbar,'State',legendOnOff);
            % preference
            Cdata = imread(fullfile(matlabroot,'toolbox','shared','controllib','graphics','Resources','pid_preference.png'),'BackgroundColor',this.BackgroundColor);
            this.Handles.PreferenceToolbar = uipushtool('Parent',this.Handles.Toolbar,'Cdata',Cdata,'HandleVisibility','off');
            set(this.Handles.PreferenceToolbar,'Separator','on','tooltip',pidtool.utPIDgetStrings('cst','toolbar_tooltip_pref'),'Tag','PIDTOOLBAR_PREFERENCE');
            % reset
            Cdata = imread(fullfile(matlabroot,'toolbox','shared','controllib','graphics','Resources','pid_reset.png'),'BackgroundColor',this.BackgroundColor);
            this.Handles.ResetToolbar = uipushtool('Parent',this.Handles.Toolbar,'Cdata',Cdata,'HandleVisibility','off');
            set(this.Handles.ResetToolbar,'tooltip',pidtool.utPIDgetStrings('cst','toolbar_tooltip_reset'),'Tag','PIDTOOLBAR_RESET');
            % design mode
            this.Handles.DesignModeLabel = javaObjectEDT('com.mathworks.mwswing.MJLabel',[blanks(4) pidtool.utPIDgetStrings('cst','toolbar_dsnmode') blanks(1)]);
            this.Handles.DesignModeLabel.setName('PIDTUNER_DESIGNMODELABEL');
            pidtool.utPIDaddCSH('control',this.Handles.DesignModeLabel,'pidtuner_designmode');
            javacomponent(this.Handles.DesignModeLabel,[.1,.1,.9,.9],this.Handles.Toolbar);
            this.Handles.DesignModeComboBox = javaObjectEDT('com.mathworks.mwswing.MJComboBox',pidtool.utPIDgetStrings('cst','prefdlg_ddm_combo',2));
            this.Handles.DesignModeComboBox.setName('PIDTUNER_DESIGNMODECOMBOBOX');
            this.Handles.DesignModeComboBox.setSelectedIndex(find(strcmp(designmode,this.DesignModeContents))-1);
            javacomponent(this.Handles.DesignModeComboBox,[.1,.1,.9,.9],this.Handles.Toolbar);
            tmp = this.Handles.DesignModeComboBox.getMaximumSize;
            tmp.width = 90;
            this.Handles.DesignModeComboBox.setMaximumSize(tmp);
            % form
            this.Handles.FormLabel = javaObjectEDT('com.mathworks.mwswing.MJLabel',[blanks(4) pidtool.utPIDgetStrings('cst','toolbar_formlabel') blanks(1)]);
            this.Handles.FormLabel.setName('PIDTUNER_FORMLABEL');
            pidtool.utPIDaddCSH('control',this.Handles.FormLabel,'pidtuner_form');
            javacomponent(this.Handles.FormLabel,[.1,.1,.9,.9],this.Handles.Toolbar);
            this.Handles.FormComboBox = javaObjectEDT('com.mathworks.mwswing.MJComboBox',pidtool.utPIDgetStrings('cst','form_combo',2));
            this.Handles.FormComboBox.setSelectedIndex(find(strcmp(this.DataSrc.Form,this.FormContents))-1);
            this.Handles.FormComboBox.setName('PIDTUNER_FORMCOMBOBOX');
            javacomponent(this.Handles.FormComboBox,[.1,.1,.9,.9],this.Handles.Toolbar);
            tmp = this.Handles.FormComboBox.getMaximumSize;
            tmp.width = 90;
            this.Handles.FormComboBox.setMaximumSize(tmp);
            % type
            this.Handles.TypeLabel = javaObjectEDT('com.mathworks.mwswing.MJLabel',[blanks(4) pidtool.utPIDgetStrings('cst','toolbar_typelabel') blanks(1)]);
            this.Handles.TypeLabel.setName('PIDTUNER_TYPELABEL');
            pidtool.utPIDaddCSH('control',this.Handles.TypeLabel,'pidtuner_type');
            javacomponent(this.Handles.TypeLabel,[.1,.1,.9,.9],this.Handles.Toolbar);
            this.Handles.TypeComboBox = javaObjectEDT('com.mathworks.mwswing.MJComboBox',pidtool.utPIDgetStrings('cst','pid_type_combo',7));
            this.Handles.TypeComboBox.setSelectedIndex(find(strcmp(this.DataSrc.Type,this.PIDTypeContents))-1);
            this.Handles.TypeComboBox.setName('PIDTUNER_TYPECOMBOBOX');
            javacomponent(this.Handles.TypeComboBox,[.1,.1,.9,.9],this.Handles.Toolbar);
            tmp = this.Handles.TypeComboBox.getMaximumSize;
            tmp.width = 60;
            this.Handles.TypeComboBox.setMaximumSize(tmp);
            % Callbacks
            set(this.Handles.ImportToolbar,'ClickedCallback',{@ImportCallback this});
            set(this.Handles.ExportToolbar,'ClickedCallback',{@ExportCallback this});
            set(this.Handles.LegendToolbar,'ClickedCallback',{@LegendCallback this});
            set(this.Handles.PreferenceToolbar,'ClickedCallback',{@PreferenceCallback this});
            set(this.Handles.ResetToolbar,'ClickedCallback',{@ResetCallback this});
            h = handle(this.Handles.DesignModeComboBox,'callbackproperties');
            hListener = handle.listener(h, 'ActionPerformed',{@DesignModeComboBoxCallback this});
            this.Handles.DesignModeComboBoxListener = hListener;
            h = handle(this.Handles.FormComboBox,'callbackproperties');
            hListener = handle.listener(h, 'ActionPerformed',{@FormComboBoxCallback this});
            this.Handles.FormComboBoxListener = hListener;
            h = handle(this.Handles.TypeComboBox,'callbackproperties');
            hListener = handle.listener(h, 'ActionPerformed',{@TypeComboBoxCallback this});
            this.Handles.TypeComboBoxListener = hListener;
        end
        
    end
    
end

%% GUI Callbacks
function DesignModeComboBoxCallback(hObject,eventdata,this) %#ok<*INUSL>
    % set to new mode
    this.CurrentDesignMode = this.DesignModeContents{hObject.getSelectedIndex+1};
    % update design panel
    if strcmpi(this.CurrentDesignMode,'basic')
        this.Handles.DesignPanelBasic.CenterWC = this.Handles.DesignPanelAdvanced.CenterWC;
        this.Handles.DesignPanelBasic.setWCSliderValue(this.CurrentWC);
    else
        this.Handles.DesignPanelAdvanced.CenterWC = this.Handles.DesignPanelBasic.CenterWC;
        this.Handles.DesignPanelAdvanced.setWCSliderValue(this.CurrentWC);
        this.Handles.DesignPanelAdvanced.setWCSpinnerValue(this.CurrentWC);
        this.Handles.DesignPanelAdvanced.Handles.CrossoverTextField.setText(sprintf('%0.3g rad/s',this.CurrentWC));
        this.Handles.DesignPanelAdvanced.setPMSliderValue(this.CurrentPM);
        this.Handles.DesignPanelAdvanced.setPMSpinnerValue(this.CurrentPM);
        this.Handles.DesignPanelAdvanced.Handles.PhaseMarginTextField.setText(sprintf('%d deg',this.CurrentPM));
    end
    % reset layout
    this.layout;
end

function ImportCallback(hObject,eventdata,this) %#ok<*INUSL>
    this.importplant;
end

function ExportCallback(hObject,eventdata,this) %#ok<*INUSL>
    this.exportplant;
end

function LegendCallback(hObject,eventdata,this) %#ok<*INUSL>
    this.Handles.PlotPanel.setLegendVisible(strcmpi(get(hObject,'State'),'on'))
end

function PreferenceCallback(hObject,eventdata,this) %#ok<*INUSL>
    this.Handles.PreferenceDlg.setVisible('on');
end

function ResetCallback(hObject,eventdata,this) %#ok<*INUSL>
    % one-click design
    this.design;
    % reset plot panel
    s = this.DataSrc.generateTunedStructure;
    this.Handles.PlotPanel.setTunedController(s);
    % reset design panel
    this.Handles.DesignPanelBasic.initialize(0, this.CurrentWC);
    this.Handles.DesignPanelAdvanced.initialize(0, this.CurrentWC, this.CurrentPM);
    % set status text
    this.setStatusText(pidtool.utPIDgetStrings('cst','tunerdlg_reset_info'),'info');
end

function TypeComboBoxCallback(hObject,eventdata,this) %#ok<*INUSL>
    datasrc = this.DataSrc;
    Type = this.PIDTypeContents{this.Handles.TypeComboBox.getSelectedIndex+1};
    % update only when there is a change
    if ~strcmp(datasrc.Type,Type)
        if strcmp(this.DataSrc.Form,'standard') && strcmp(Type,'i') %#ok<*STCI>
            this.Handles.TypeComboBox.setSelectedItem(upper(this.DataSrc.Type));
            this.setStatusText(pidtool.utPIDgetStrings('cst','tunerdlg_typechanged_warn'),'warn');
            return
        end
        % get new PID configuration
        datasrc.Type = Type;
        % reset slider visibility
        PMVisible = ~(strcmp(Type,'p') || strcmp(Type,'i'));
        this.Handles.DesignPanelAdvanced.setPMVisible(PMVisible);
        % reset PIDTuningData
        datasrc.setPIDTuningData;
        % fastdesign
        this.fastdesign;
        % set status text
        this.setStatusText(pidtool.utPIDgetStrings('cst','tunerdlg_typechanged_info'),'info');
    end
end

function FormComboBoxCallback(hObject,eventdata,this) %#ok<*INUSL>
    datasrc = this.DataSrc;
    Form = this.FormContents{this.Handles.FormComboBox.getSelectedIndex+1};
    % update only when there is a change
    if ~strcmp(datasrc.Form,Form)
        if strcmp(Form,'standard') && strcmp(this.DataSrc.Type,'i') %#ok<*STCI>
            this.Handles.FormComboBox.setSelectedIndex(0);
            this.setStatusText(pidtool.utPIDgetStrings('cst','tunerdlg_formchanged_warn'),'warn');
            return
        end
        % get new PID configuration
        datasrc.Form = Form;
        % reset PIDTuningData
        datasrc.setPIDTuningData;
        % fastdesign
        this.fastdesign;
        % reset gain names
        this.Handles.PlotPanel.updateGainNames(Form);
        % set status text
        this.setStatusText(pidtool.utPIDgetStrings('cst','tunerdlg_formchanged_info'),'info');
    end
end