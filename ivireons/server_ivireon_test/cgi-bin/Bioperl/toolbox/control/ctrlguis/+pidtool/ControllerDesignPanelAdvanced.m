classdef ControllerDesignPanelAdvanced < pidtool.AbstractControllerDesignPanel
    % @ControllerDesignPanelAdvanced subclass

    % Author(s): R. Chen
    % Copyright 2009-2010 The MathWorks, Inc.
    % $Revision: 1.1.8.6 $ $Date: 2010/03/26 17:21:24 $
    
    properties (SetObservable = true, AbortSet = true)
        % current phase margin
        PM
    end
    
    methods

        % Constructor
        function this = ControllerDesignPanelAdvanced()
            this = this@pidtool.AbstractControllerDesignPanel;
            this.build;
        end
        
        % set PM visibility (invisible in 'P' or 'I' only control)
        function setPMVisible(this, Visible)
            this.Handles.PhaseMarginLabel.setVisible(Visible);
            this.Handles.PhaseMarginSlider.setVisible(Visible);
            this.Handles.PhaseMarginSpinner.setVisible(Visible);
            this.Handles.PhaseMarginTextField.setVisible(Visible);
        end
        
        % initialize
        function initialize(this,Ts,WC,PM)
            % reset MaxWC based on time domain
            if Ts>0
                this.MaxWC = 3.14159/Ts;
            end
            % reset property
            this.WC = WC;
            this.PM = PM;
            % reset gui
            resetWCSlider(this,WC);
            this.setWCSpinnerValue(WC);
            this.Handles.CrossoverTextField.setText(sprintf('%0.3g rad/s',WC));    
            this.setPMSliderValue(PM);
            this.setPMSpinnerValue(PM);
            this.Handles.PhaseMarginTextField.setText(sprintf('%d deg',PM));    
        end
        
        % set crossover slider value without firing event
        function setWCSliderValue(this, newWC)
            if newWC<max(0.1*this.CenterWC,this.MinWC) || newWC>min(10*this.CenterWC,this.MaxWC)
                % if new WC exceed current slider limits, reset slider with the new WC as the center
                resetWCSlider(this, newWC);
            else
                % set slider knob to the right position
                newLocation = this.getFromWCToLocation(newWC);
                pidtool.AbstractControllerDesignPanel.setSliderWithoutFiringEvent(this.Handles.CrossoverSlider, newLocation);
                this.refreshCrossoverSliderLabel;
            end
        end

        % set crossover spinner value without firing event
        function setWCSpinnerValue(this, newWC)
            Model = this.Handles.CrossoverSpinner.getModel;
            tmp = Model.getChangeListeners;
            for ct=1:length(tmp)
                if isa(tmp(ct),'javax.swing.JSpinner$ModelListener')
                    Model.removeChangeListener(tmp(ct));
                end
            end
            Model.setValue(newWC);
            StepSize = java.lang.Double(10^(floor(log10(newWC))-2));
            Model.setStepSize(StepSize);            
            Model.setMinimum(java.lang.Double(this.MinWC));
            Model.setMaximum(java.lang.Double(this.MaxWC));
            for ct=1:length(tmp)
                if isa(tmp(ct),'javax.swing.JSpinner$ModelListener')
                    Model.addChangeListener(tmp(ct));
                end
            end
            
        end

        % set phase margin slider value without firing event
        function setPMSliderValue(this, newPM)
            pidtool.AbstractControllerDesignPanel.setSliderWithoutFiringEvent(this.Handles.PhaseMarginSlider, newPM);
        end
        
        % set phase margin spinner value without firing event
        function setPMSpinnerValue(this, newPM)
            Model = this.Handles.PhaseMarginSpinner.getModel;
            tmp = Model.getChangeListeners;
            for ct=1:length(tmp)
                if isa(tmp(ct),'javax.swing.JSpinner$ModelListener')
                    Model.removeChangeListener(tmp(ct));
                end
            end
            Model.setValue(newPM);
            for ct=1:length(tmp)
                if isa(tmp(ct),'javax.swing.JSpinner$ModelListener')
                    Model.addChangeListener(tmp(ct));
                end
            end
        end
        
        % refresh crossover slider labels
        function refreshCrossoverSliderLabel(this)
            % reset label
            newCenterWC = this.CenterWC;
            labelTable = java.util.Hashtable;
            if 0.1*newCenterWC>this.MinWC
                hObj = javaObjectEDT('com.mathworks.mwswing.MJLabel',sprintf('%0.3g',0.1*newCenterWC));
            else
                hObj = javaObjectEDT('com.mathworks.mwswing.MJLabel',sprintf('%0.3g',this.MinWC));
            end
            labelTable.put(java.lang.Integer(0),hObj);
            hObj = javaObjectEDT('com.mathworks.mwswing.MJLabel',sprintf('%0.3g',newCenterWC));
            labelTable.put(java.lang.Integer(50),hObj);
            if 10*newCenterWC<this.MaxWC
                hObj = javaObjectEDT('com.mathworks.mwswing.MJLabel',sprintf('%0.3g',10*newCenterWC));
            else
                hObj = javaObjectEDT('com.mathworks.mwswing.MJLabel',sprintf('%0.3g',this.MaxWC));                                                
            end
            labelTable.put(java.lang.Integer(100),hObj);
            this.Handles.CrossoverSlider.setLabelTable(labelTable);
        end
        
    end

    methods (Access = protected)

        function build(this)
            
            % main panel
            Prefs = cstprefs.tbxprefs;

            % build wc slider panel
            WCPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel');
            WCPanel.setLayout(java.awt.GridBagLayout);
            WCPanel.setFont(Prefs.JavaFontB);            
            % common properties of GBC
            GBc = java.awt.GridBagConstraints;
            GBc.insets = java.awt.Insets(0,0,0,0);
            % << button
            GBc.anchor = java.awt.GridBagConstraints.NORTHEAST;
            GBc.gridx = 0;
            GBc.gridy = 0;
            GBc.weightx = 0;
            GBc.gridwidth = 1;
            GBc.fill = java.awt.GridBagConstraints.NONE;
            SlowButton = javaObjectEDT('com.mathworks.mwswing.MJButton');
            SlowButton.setToolTipText(pidtool.utPIDgetStrings('cst','leftbutton_tooltip'));
            Icon = javaObjectEDT('javax.swing.ImageIcon',fullfile(matlabroot,'toolbox','shared','controllib','graphics','Resources','pid_slowarrow.png'));
            SlowButton.setIcon(Icon);
            SlowButton.setPreferredSize(java.awt.Dimension(32,24));
            SlowButton.setFlyOverAppearance(true);
            SlowButton.setFocusTraversable(false);
            SlowButton.setName('PIDTUNER_LEFTBUTTON');
            WCPanel.add(SlowButton,GBc);
            % WC slider
            GBc.anchor = java.awt.GridBagConstraints.CENTER;
            GBc.gridx = 1;
            GBc.gridy = 0;
            GBc.weightx = 1;
            GBc.gridwidth = 1;
            GBc.fill = java.awt.GridBagConstraints.HORIZONTAL;
            CrossoverSliderModel = javaObjectEDT('javax.swing.DefaultBoundedRangeModel',0,0,0,100);
            CrossoverSlider = javaObjectEDT('com.mathworks.mwswing.MJSlider',CrossoverSliderModel);
            CrossoverSlider.setName('PIDTUNER_CROSSOVERSLIDER');
            CrossoverSlider.setMinorTickSpacing(50);
            CrossoverSlider.setPaintTicks(true);
            CrossoverSlider.setFocusable(false);
            CrossoverSlider.setPaintLabels(true);
            WCPanel.add(CrossoverSlider,GBc);
            % >> button
            GBc.anchor = java.awt.GridBagConstraints.NORTHWEST;
            GBc.gridx = 2;
            GBc.gridy = 0;
            GBc.weightx = 0;
            GBc.gridwidth = 1;
            GBc.fill = java.awt.GridBagConstraints.NONE;
            FastButton = javaObjectEDT('com.mathworks.mwswing.MJButton');
            FastButton.setToolTipText(pidtool.utPIDgetStrings('cst','rightbutton_tooltip'));
            Icon = javaObjectEDT('javax.swing.ImageIcon',fullfile(matlabroot,'toolbox','shared','controllib','graphics','Resources','pid_fastarrow.png'));
            FastButton.setIcon(Icon);
            FastButton.setPreferredSize(java.awt.Dimension(32,24));
            FastButton.setFlyOverAppearance(true);
            FastButton.setFocusTraversable(false);
            FastButton.setName('PIDTUNER_RIGHTBUTTON');
            WCPanel.add(FastButton,GBc);
            
            % main panel
            Panel = javaObjectEDT('com.mathworks.mwswing.MJPanel');
            titleborder = javaMethodEDT('createTitledBorder','javax.swing.BorderFactory',pidtool.utPIDgetStrings('cst','tunerdlg_designbox'));
            javaObjectEDT(titleborder);
            Panel.setBorder(titleborder);
            Panel.setLayout(java.awt.GridBagLayout);
            Panel.setFont(Prefs.JavaFontB);            
            % common properties of GBC
            GBc = java.awt.GridBagConstraints;
            GBc.insets = java.awt.Insets(5,5,5,5);
            GBc.fill = java.awt.GridBagConstraints.HORIZONTAL;
            
            % row 1
            % WC text
            GBc.anchor = java.awt.GridBagConstraints.EAST;
            GBc.gridx = 0;
            GBc.gridy = 0;
            GBc.weightx = 0;
            GBc.gridwidth = 1;
            CrossoverLabel = javaObjectEDT('com.mathworks.mwswing.MJLabel',pidtool.utPIDgetStrings('cst','tunerdlg_wcslider'));
            CrossoverLabel.setName('PIDTUNER_CROSSOVERLABEL');
            pidtool.utPIDaddCSH('control',CrossoverLabel,'pidtuner_crossoverfreq');
            Panel.add(CrossoverLabel,GBc);
            
            % row 2
            % slider panel
            GBc.anchor = java.awt.GridBagConstraints.CENTER;
            GBc.gridx = 0;
            GBc.gridy = 1;
            GBc.weightx = 1;
            GBc.gridwidth = 1;
            Panel.add(WCPanel,GBc);
            % WC spinner
            GBc.anchor = java.awt.GridBagConstraints.NORTHWEST;
            GBc.gridx = 1;
            GBc.gridy = 1;
            GBc.weightx = 0;
            GBc.gridwidth = java.awt.GridBagConstraints.REMAINDER;
            CrossoverTextField = javaObjectEDT('com.mathworks.mwswing.MJTextField',sprintf('%0.3g rad/s',0),8);
            CrossoverTextField.setName('PIDTUNER_CROSSOVERTEXTFIELD');
            tmp = CrossoverTextField.getPreferredSize;
            tmp.height = tmp.height*1.1;
            CrossoverTextField.setPreferredSize(tmp);
            CrossoverSpinner = javaObjectEDT('com.mathworks.mwswing.MJSpinner');
            CrossoverSpinner.setName('PIDTUNER_CROSSOVERSPINNER');
            CrossoverSpinner.setEditor(CrossoverTextField);
            CrossoverSpinnerNumberModel = javaObjectEDT('javax.swing.SpinnerNumberModel',50,0,100,1); 
            CrossoverSpinner.setModel(CrossoverSpinnerNumberModel);
            Panel.add(CrossoverSpinner,GBc);

            % row 3
            % PM text
            GBc.anchor = java.awt.GridBagConstraints.EAST;
            GBc.gridx = 0;
            GBc.gridy = 2;
            GBc.weightx = 1;
            GBc.gridwidth = 2;
            PhaseMarginLabel = javaObjectEDT('com.mathworks.mwswing.MJLabel',pidtool.utPIDgetStrings('cst','tunerdlg_pmslider'));
            PhaseMarginLabel.setName('PIDTUNER_PHASEMARGINLABEL');
            pidtool.utPIDaddCSH('control',PhaseMarginLabel,'pidtuner_phasemargin');
            Panel.add(PhaseMarginLabel,GBc);
                        
            % row 4
            % PM slider
            GBc.anchor = java.awt.GridBagConstraints.CENTER;
            GBc.gridx = 0;
            GBc.gridy = 3;
            GBc.weightx = 1;
            GBc.gridwidth = 1;
            PhaseMarginSliderModel = javaObjectEDT('javax.swing.DefaultBoundedRangeModel',0,0,0,90);
            PhaseMarginSlider = javaObjectEDT('com.mathworks.mwswing.MJSlider',PhaseMarginSliderModel);
            PhaseMarginSlider.setName('PIDTUNER_PHASEMARGINSLIDER');
            PhaseMarginSlider.setMinorTickSpacing(45);
            PhaseMarginSlider.setPaintTicks(true);
            PhaseMarginSlider.setFocusable(false);
            labelTable = java.util.Hashtable;
            labelTable.put(java.lang.Integer(0),javaObjectEDT('com.mathworks.mwswing.MJLabel',sprintf('%d',0)));
            labelTable.put(java.lang.Integer(45),javaObjectEDT('com.mathworks.mwswing.MJLabel',sprintf('%d',45)));
            labelTable.put(java.lang.Integer(90),javaObjectEDT('com.mathworks.mwswing.MJLabel',sprintf('%d',90)));
            PhaseMarginSlider.setLabelTable(labelTable);
            PhaseMarginSlider.setPaintLabels(true);
            Panel.add(PhaseMarginSlider,GBc);
            % PM spinner
            GBc.anchor = java.awt.GridBagConstraints.NORTHWEST;
            GBc.gridx = 1;
            GBc.gridy = 3;
            GBc.weightx = 0;
            GBc.gridwidth = java.awt.GridBagConstraints.REMAINDER;
            PhaseMarginTextField = javaObjectEDT('com.mathworks.mwswing.MJTextField',sprintf('%d deg',0),8);
            PhaseMarginTextField.setName('PIDTUNER_PHASEMARGINTEXTFIELD');
            tmp = PhaseMarginTextField.getPreferredSize;
            tmp.height = tmp.height*1.1;
            PhaseMarginTextField.setPreferredSize(tmp);
            PhaseMarginSpinner = javaObjectEDT('com.mathworks.mwswing.MJSpinner');
            PhaseMarginSpinner.setName('PIDTUNER_PHASEMARGINSPINNER');
            PhaseMarginSpinner.setEditor(PhaseMarginTextField);
            PhaseMarginSpinnerNumberModel = javaObjectEDT('javax.swing.SpinnerNumberModel',45,0,90,1); 
            PhaseMarginSpinnerNumberModel.setMinimum(java.lang.Double(0)); 
            PhaseMarginSpinnerNumberModel.setMaximum(java.lang.Double(90)); 
            PhaseMarginSpinner.setModel(PhaseMarginSpinnerNumberModel);
            Panel.add(PhaseMarginSpinner,GBc);

            % handles
            this.Handles.Panel = Panel;
            this.Handles.CrossoverLabel = CrossoverLabel;
            this.Handles.CrossoverSlider = CrossoverSlider;
            this.Handles.CrossoverSliderModel = CrossoverSliderModel;
            this.Handles.CrossoverSpinner = CrossoverSpinner;
            this.Handles.CrossoverSpinnerModel = CrossoverSpinnerNumberModel;
            this.Handles.CrossoverTextField = CrossoverTextField;
            this.Handles.SlowButton = SlowButton;
            this.Handles.FastButton = FastButton;
            this.Handles.PhaseMarginLabel = PhaseMarginLabel;
            this.Handles.PhaseMarginSlider = PhaseMarginSlider;
            this.Handles.PhaseMarginSliderModel = PhaseMarginSliderModel;
            this.Handles.PhaseMarginSpinner = PhaseMarginSpinner;
            this.Handles.PhaseMarginSpinnerModel = PhaseMarginSpinnerNumberModel;
            this.Handles.PhaseMarginTextField = PhaseMarginTextField;

            % callbacks
            h = handle(CrossoverSlider,'callbackproperties');
            h.MousePressedCallback = {@(x,y) SliderMousePressedCallback(this)};
            h.MouseReleasedCallback = {@(x,y) SliderMouseReleasedCallback(this)};
            h.StateChangedCallback = {@localCrossoverSliderChange this};

            h = handle(CrossoverSpinner,'callbackproperties');
            h.StateChangedCallback = {@localCrossoverSpinnerChange this};
            
            h = handle(CrossoverTextField,'callbackproperties');
            h.ActionPerformedCallback = {@localCrossoverEditorChange this};
            
            h = handle(SlowButton,'callbackproperties');
            h.ActionPerformedCallback = {@localSlowButtonChange this};
            
            h = handle(FastButton,'callbackproperties');
            h.ActionPerformedCallback = {@localFastButtonChange this};
            
            h = handle(PhaseMarginSlider,'callbackproperties');
            h.MousePressedCallback = {@(x,y) SliderMousePressedCallback(this)};
            h.MouseReleasedCallback = {@(x,y) SliderMouseReleasedCallback(this)};
            h.StateChangedCallback = {@localPhaseMarginSliderChange this};

            h = handle(PhaseMarginSpinner,'callbackproperties');
            h.StateChangedCallback = {@localPhaseMarginSpinnerChange this};
            
            h = handle(PhaseMarginTextField,'callbackproperties');
            h.ActionPerformedCallback = {@localPhaseMarginEditorChange this};
           
        end
        
    end
    
end

%% Callbacks
% <<
function localSlowButtonChange(hObject,ed,this) %#ok<*INUSL>
    this.CenterWC = min(max(0.1*this.CenterWC, this.MinWC*10),this.MaxWC);
    if this.CenterWC==this.MinWC*10
        this.Handles.SlowButton.setEnabled(false);
    end
    this.Handles.FastButton.setEnabled(true);
    localCrossoverSliderChange([],[],this);
    this.refreshCrossoverSliderLabel;
end

% >>
function localFastButtonChange(hObject,ed,this) %#ok<*INUSL>
    this.CenterWC = max(min(10*this.CenterWC, this.MaxWC/10),this.MinWC);
    if this.CenterWC==this.MaxWC/10
        this.Handles.FastButton.setEnabled(false);
    end
    this.Handles.SlowButton.setEnabled(true);
    localCrossoverSliderChange([],[],this);
    this.refreshCrossoverSliderLabel;
end

% WC knob
function localCrossoverSliderChange(hObject,ed,this) %#ok<*INUSL>
    % get real WC from slider location
    newLocation = this.Handles.CrossoverSlider.getValue;
    newWC = this.getFromLocationToWC(newLocation);
    % setText will not fire event
    this.Handles.CrossoverTextField.setText(sprintf('%0.3g rad/s',newWC));
    % when not dragging update spinner value 
    if ~this.Handles.CrossoverSlider.getValueIsAdjusting
        % set spinner value without trigging spinner callback
        setWCSpinnerValue(this, newWC);
    end
    % update WC
    this.WC = newWC;    
end

% WC spinner
function localCrossoverSpinnerChange(hObject,ed,this) %#ok<*INUSL>
    % get WC
    newWC = hObject.getModel.getValue;
    % update slider knob position
    setWCSliderValue(this, newWC);
    % setText will not fire event
    this.Handles.CrossoverTextField.setText(sprintf('%0.3g rad/s',newWC));
    % update WC
    this.WC = newWC;
end

% WC editor
function localCrossoverEditorChange(hObject,ed,this)
    % get WC
    newWC = str2double(strrep(char(hObject.getText),'rad/s',''));
    if isnan(newWC) || ~isscalar(newWC) || ~isreal(newWC) || newWC<this.MinWC || newWC>this.MaxWC || ~isfinite(newWC)
        hObject.setText(sprintf('%0.3g rad/s',this.WC));
        return
    end
    % setText will not fire event    
    hObject.setText(sprintf('%0.3g rad/s',newWC));
    % update slider knob position
    setWCSliderValue(this, newWC);
    % update spinner value
    setWCSpinnerValue(this, newWC);
    % update WC
    this.WC = newWC;
end

% PM knob
function localPhaseMarginSliderChange(hObject,ed,this)
    % get PM from slider location
    newPM = hObject.getValue;
    % setText will not fire event
    this.Handles.PhaseMarginTextField.setText(sprintf('%d deg',newPM));
    % when not dragging update spinner value 
    if ~this.Handles.PhaseMarginSlider.getValueIsAdjusting
        % set spinner value without trigging spinner callback
        setPMSpinnerValue(this, newPM);
    end
    % update PM
    this.PM = newPM;    
end

% PM spinner
function localPhaseMarginSpinnerChange(hObject,ed,this)
    % get PM 
    newPM = hObject.getModel.getValue;
    % setText will not fire event
    this.Handles.PhaseMarginTextField.setText(sprintf('%d deg',newPM));
    % set slider value without trigging slider callback
    setPMSliderValue(this, newPM);
    % update PM
    this.PM = newPM;    
end

% PM editor
function localPhaseMarginEditorChange(hObject,ed,this)
    % get PM 
    newPM = str2double(strrep(char(hObject.getText),'deg',''));
    if isnan(newPM) || ~isscalar(newPM) || ~isreal(newPM) || newPM<0 || newPM>90 || ~isfinite(newPM)
        hObject.setText(sprintf('%d deg',this.PM));
        return
    else
        newPM = round(newPM);
    end
    % reset setText will not fire event
    hObject.setText(sprintf('%d deg',newPM));
    % set spinner value without trigging spinner callback
    setPMSpinnerValue(this, newPM);
    % set slider value without trigging slider callback
    setPMSliderValue(this, newPM);
    % update PM
    this.PM = newPM;    
end

% reset WC knob to middle
function resetWCSlider(this, newWC)
    % reset slider knob to center
    this.CenterWC = newWC;
    pidtool.AbstractControllerDesignPanel.setSliderWithoutFiringEvent(this.Handles.CrossoverSlider, 50);
    this.refreshCrossoverSliderLabel;
end

