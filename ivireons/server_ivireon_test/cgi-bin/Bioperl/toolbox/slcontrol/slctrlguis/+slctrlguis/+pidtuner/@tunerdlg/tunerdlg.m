classdef tunerdlg < pidtool.AbstractTunerDlg
    % TUNERDLG Dialog to design a PID block
    %
    
    % Author(s): R. Chen
    % Copyright 2009-2010 The MathWorks, Inc.
    % $Revision: 1.1.8.8.2.1 $ $Date: 2010/07/07 13:42:43 $
 
    properties
        AutoUpdateMode
    end
    
    methods(Access = 'public')
        
        % constructor
        function this = tunerdlg(GCBH)
            % super
            this = this@pidtool.AbstractTunerDlg;
            % default auto update mode
            this.AutoUpdateMode = 'OFF';
            % load preferences
            s = this.loadPreferences;
            % set default design mode 
            this.CurrentDesignMode = s.DefaultDesignMode;
            % check whether it is a PID block
            if ~any(strcmp(get(GCBH,'MaskType'),{'PID 1dof','PID 2dof'}))               
                uiwait(errordlg(pidtool.utPIDgetStrings('scd','tunerdlg_blktypeerror'),pidtool.utPIDgetStrings('cst','errordlgtitle'),'modal'));
                return
            end
            % start waitbar
            wb = waitbar(0.2,pidtool.utPIDgetStrings('scd','tunerdlg_wb_str1'),'Name',pidtool.utPIDgetStrings('scd','tunerdlg_wb_title'));
            % check if there is any unapplied change in the block dialog
            [HasUnappliedChanges, hDialog] = slctrlguis.pidtuner.utPIDhasUnappliedChanges(GCBH);
            if HasUnappliedChanges
                closewb(wb);
                uiwait(errordlg(pidtool.utPIDgetStrings('scd','tunerdlg_unappliedchanges'),pidtool.utPIDgetStrings('cst','errordlgtitle'),'modal'));
                return
            end
            % linearize the plant model (use try-catch for any error from linearization)
            try
                % use initial condition
                G = slctrlguis.pidtuner.utPIDlinearize(GCBH, []);
                IsDCGainZero = false;
                figure(wb);
            catch ME
                if strcmp(ME.identifier,'Slcontrol:pidtuner:tunerdlg_planterror')
                    dlg = slctrlguis.pidtuner.InitialConditionDlg(hDialog,this.BackgroundColor,'launch');
                    uiwait(dlg.Handles.Figure);
                    if dlg.AbortLinearization
                        closewb(wb);
                        delete(dlg);
                        return
                    else
                        G = zpk([],[],0);
                        IsDCGainZero = true;
                        delete(dlg);
                    end
                else
                    closewb(wb);
                    if strcmp(ME.identifier,'MATLAB:MException:MultipleErrors')
                        len = length(ME.cause);
                        if len<=10
                            errMessage = sprintf('%s\n',pidtool.utPIDgetStrings('scd','tunerdlg_summary1'));
                        else
                            len = 10;
                            errMessage = sprintf('%s\n',pidtool.utPIDgetStrings('scd','tunerdlg_summary2'));
                        end
                        for ct = 1:len
                            message = slprivate('removeHyperLinksFromMessage', ME.cause{ct}.message); 
                            m1 = sprintf('\n--> %s\n', message);
                            errMessage = [errMessage m1];
                        end                        
                    else
                        errMessage = slprivate('removeHyperLinksFromMessage', ME.message); 
                    end
                    errordlg(errMessage,pidtool.utPIDgetStrings('cst','errordlgtitle'),'modal');
                    return
                end
            end
            % create data source
            if strcmp(get(GCBH,'MaskType'),'PID 1dof')               
                this.DataSrc = slctrlguis.pidtuner.DataSrcBlk(GCBH,G);
            else
                this.DataSrc = slctrlguis.pidtuner.DataSrcBlk2DOF(GCBH,G);
            end
            % update waitbar
            if ishghandle(wb)
                waitbar(0.6,wb,pidtool.utPIDgetStrings('scd','tunerdlg_wb_str2'));
            end
            % build GUI components
            this.build(s);
            % carry out one-click design and store a snapshot
            this.design(true);
            % update waitbar
            if ishghandle(wb)
                waitbar(0.8,wb,pidtool.utPIDgetStrings('scd','tunerdlg_wb_str3'));
            end
            % initialize GUI component
            this.initialize;
            % add listeners
            this.addListeners;
            % build preference dialog
            PreferenceDlg = slctrlguis.pidtuner.PreferenceDlg(this.Handles.Figure, this.BackgroundColor);
            PreferenceDlg.setPreferences(s);
            len = length(this.Listeners);
            this.Listeners(len+1) = addlistener(PreferenceDlg,'PlotSettings','PostSet',@(x,y) plotchanged(this));
            this.Handles.PreferenceDlg = PreferenceDlg;
            % build import dialog
            ImportDlg = slctrlguis.pidtuner.ImportPlantDlg(GCBH, this.BackgroundColor);
            this.Listeners(len+2) = addlistener(ImportDlg,'Plant','PostSet',@(x,y) updatePlantModel(this));
            this.Handles.ImportDlg = ImportDlg;
            % add figure callbacks
            set(this.Handles.Figure,...
                'ResizeFcn',@(x,y) layout(this),...
                'CloseRequestFcn',@(x,y) close(this),...
                'DeleteFcn',@(x,y) close(this));
            % make figure visible (resize func is called now)
            set(this.Handles.Figure,'Visible','on')
            % set parameter table visibility again (due to g637916)
            set(this.Handles.PlotPanel.Handles.TablePanelCONTAINER,'Visible',s.DefaultTableMode);
            % close waitbar
            closewb(wb);
            % show import plant dialog if true
            if IsDCGainZero
                ImportDlg.setVisible('on',this.Handles.Figure);
            else
                % show welcome screen
                if strcmpi(s.DefaultWelcomeDialog,'on')
                    this.Handles.StartupDlg = pidtool.StartupDlg(this.Handles.Figure);
                else
                    this.Handles.StartupDlg = [];
                end
            end
        end
        
        % close function
        function close(this)
            try %#ok<*TRYNC>
                delete(this.Handles.ImportDlg.Handles.Figure);
                delete(this.Handles.ImportDlg);
            end
            close@pidtool.AbstractTunerDlg(this);
        end
        
        % update dialog title 
        function updateName(this)
        	Title = sprintf('%s (%s)',pidtool.utPIDgetStrings('cst','tunerdlg_title'),getfullname(this.DataSrc.GCBH)); 
            set(this.Handles.Figure,'Name',Title);
        end
        
        % update one-click PID design
        function design(this, varargin)
            % one click design with default PM
            options = pidtuneOptions;
            WC = this.DataSrc.oneclick(options.PhaseMargin);
            % set Current WC and PM
            this.CurrentWC = WC;
            this.CurrentPM = options.PhaseMargin;
            % update status text
            if this.DataSrc.IsStable
                this.setStatusText('');
            else
                this.setStatusText(pidtool.utPIDgetStrings('cst','tunerdlg_oneclick_failure'),'warning');
            end
            % save snap shot
            if nargin==2 && varargin{1}
                this.SnapshotWC = this.CurrentWC;
                this.SnapshotPM = this.CurrentPM;
            end
        end
        
        function fastdesign(this)
            fastdesign@pidtool.AbstractTunerDlg(this);
            if strcmp(this.AutoUpdateMode,'ON')
                % do not apply when slider knob is moving
                if ~this.Handles.DesignPanelBasic.MouseIsDragging && ~this.Handles.DesignPanelAdvanced.MouseIsDragging
                    this.apply;
                end
            end
        end
        
    end

    %Protected methods
    methods(Access = 'protected')

        build(this, s)
        layout(this)
        importplant(this)
        exportplant(this)
        s = loadPreferences(this)
        
        apply(this)
        updatePlantModel(this)
        
        % overloaded slider knob dragging callback
        function sliderMouseAction(this, hDesignPanel)
            sliderMouseAction@pidtool.AbstractTunerDlg(this, hDesignPanel);
            % when automatic update is required, apply only when the knob
            % is released
            if strcmp(this.AutoUpdateMode,'ON') && ~hDesignPanel.MouseIsDragging
                this.apply;
            end
        end
        
        function buildToolbar(this, legendOnOff, designmode)
            % Create toolbar
            this.Handles.Toolbar = uitoolbar('Parent',this.Handles.Figure,'HandleVisibility','off');
            set(this.Handles.Toolbar,'Tag','PIDTOOLBAR');
            % import plant
            Cdata = imread(fullfile(matlabroot,'toolbox','shared','controllib','graphics','Resources','pid_plantimport.png'),'BackgroundColor',this.BackgroundColor); %#ok<*MCTBX>
            this.Handles.ImportToolbar = uipushtool('Parent',this.Handles.Toolbar,'Cdata',Cdata,'HandleVisibility','off');
            set(this.Handles.ImportToolbar,'tooltip',pidtool.utPIDgetStrings('scd','toolbar_tooltip_ip'),'Tag','PIDTOOLBAR_IMPORT');
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
            % save last known good
            Cdata = imread(fullfile(matlabroot,'toolbox','shared','controllib','graphics','Resources','pid_savelsg.png'),'BackgroundColor',this.BackgroundColor);
            this.Handles.SaveLKGToolbar = uipushtool('Parent',this.Handles.Toolbar,'Cdata',Cdata,'HandleVisibility','off');
            set(this.Handles.SaveLKGToolbar,'Separator','on','tooltip',pidtool.utPIDgetStrings('cst','toolbar_tooltip_savelkg'),'Tag','PIDTOOLBAR_SAVELKG');
            % load last known good
            Cdata = imread(fullfile(matlabroot,'toolbox','shared','controllib','graphics','Resources','pid_loadlsg.png'),'BackgroundColor',this.BackgroundColor);
            this.Handles.LoadLKGToolbar = uipushtool('Parent',this.Handles.Toolbar,'Cdata',Cdata,'HandleVisibility','off');
            set(this.Handles.LoadLKGToolbar,'tooltip',pidtool.utPIDgetStrings('cst','toolbar_tooltip_loadlkg'),'Tag','PIDTOOLBAR_LOADLKG');
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
            % type and form
            str = [blanks(6) pidtool.utPIDgetStrings('cst','toolbar_formlabel') ': ' [upper(this.DataSrc.Form(1)) lower(this.DataSrc.Form(2:end))] ...
                   blanks(6) pidtool.utPIDgetStrings('cst','toolbar_typelabel') ': ' upper(this.DataSrc.Type)];
            this.Handles.ControllerInfoLabel = javaObjectEDT('com.mathworks.mwswing.MJLabel',str);
            this.Handles.ControllerInfoLabel.setName('PIDTUNER_TYPEFORMLABEL');
            javacomponent(this.Handles.ControllerInfoLabel,[.1,.1,.9,.9],this.Handles.Toolbar);
            % Callbacks
            set(this.Handles.ImportToolbar,'ClickedCallback',{@ImportCallback this});
            set(this.Handles.ExportToolbar,'ClickedCallback',{@ExportCallback this});
            set(this.Handles.LegendToolbar,'ClickedCallback',{@LegendCallback this});
            set(this.Handles.LoadLKGToolbar,'ClickedCallback',{@LoadLKGCallback this});
            set(this.Handles.SaveLKGToolbar,'ClickedCallback',{@SaveLKGCallback this});
            set(this.Handles.PreferenceToolbar,'ClickedCallback',{@PreferenceCallback this});
            set(this.Handles.ResetToolbar,'ClickedCallback',{@ResetCallback this});
            h = handle(this.Handles.DesignModeComboBox,'callbackproperties');
            hListener = handle.listener(h, 'ActionPerformed',{@DesignModeComboBoxCallback this});
            this.Handles.DesignModeComboBoxListener = hListener;
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

function LoadLKGCallback(hObject,eventdata,this) %#ok<*INUSL>
    this.CurrentWC = this.SnapshotWC;
    this.CurrentPM = this.SnapshotPM;
    this.Handles.DesignPanelBasic.CenterWC = this.CurrentWC;
    this.Handles.DesignPanelBasic.setWCSliderValue(this.CurrentWC);
    this.Handles.DesignPanelAdvanced.CenterWC = this.CurrentWC;
    this.Handles.DesignPanelAdvanced.setWCSliderValue(this.CurrentWC);
    this.Handles.DesignPanelAdvanced.setWCSpinnerValue(this.CurrentWC);
    this.Handles.DesignPanelAdvanced.Handles.CrossoverTextField.setText(sprintf('%0.3g rad/s',this.CurrentWC));
    this.Handles.DesignPanelAdvanced.setPMSliderValue(this.CurrentPM);
    this.Handles.DesignPanelAdvanced.setPMSpinnerValue(this.CurrentPM);
    this.Handles.DesignPanelAdvanced.Handles.PhaseMarginTextField.setText(sprintf('%0.3g deg',this.CurrentPM));
end

function SaveLKGCallback(hObject,eventdata,this) %#ok<*INUSL>
    this.SnapshotWC = this.CurrentWC;
    this.SnapshotPM = this.CurrentPM;
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

function closewb(wb)
    if ishghandle(wb)
        delete(wb);
    end
end