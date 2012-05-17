classdef ControllerDesignPanelBasic < pidtool.AbstractControllerDesignPanel
    % @ControllerDesignPanelBasic subclass

    % Author(s): R. Chen
    % Copyright 2009-2010 The MathWorks, Inc.
    % $Revision: 1.1.8.5 $ $Date: 2010/03/26 17:21:25 $
    
    methods

        % Constructor
        function this = ControllerDesignPanelBasic()
            this = this@pidtool.AbstractControllerDesignPanel;
            this.build;
        end
        
        % initialize
        function initialize(this, Ts, WC)
            % reset MaxWC based on time domain
            if Ts>0
                this.MaxWC = 3.14159/Ts;
            end
            % reset property
            this.WC = WC;
            % reset gui
            resetWCSlider(this,WC);
        end
        
        % set response speed slider value without firing event
        function setWCSliderValue(this, newWC)
            newLocation = this.getFromWCToLocation(newWC);
            pidtool.AbstractControllerDesignPanel.setSliderWithoutFiringEvent(this.Handles.ResponseSpeedSlider, newLocation);
            this.Handles.WCValueLabel.setText(sprintf('%s %0.3g sec',pidtool.utPIDgetStrings('cst','tunerdlg_respslider'),2/newWC));                    
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
            SlowButton = javaObjectEDT('com.mathworks.mwswing.MJButton');
            SlowButton.setName('PIDTUNER_SLOWBUTTON');
            SlowButton.setToolTipText(pidtool.utPIDgetStrings('cst','slowbutton_tooltip'));
            Icon = javaObjectEDT('javax.swing.ImageIcon',fullfile(matlabroot,'toolbox','shared','controllib','graphics','Resources','pid_slowarrow.png'));
            SlowButton.setIcon(Icon);
            SlowButton.setPreferredSize(java.awt.Dimension(32,24));
            SlowButton.setFlyOverAppearance(true);
            SlowButton.setFocusTraversable(false);
            WCPanel.add(SlowButton,GBc);
            % WC slider
            GBc.anchor = java.awt.GridBagConstraints.CENTER;
            GBc.gridx = 1;
            GBc.gridy = 0;
            GBc.weightx = 1;
            GBc.gridwidth = 1;
            GBc.fill = java.awt.GridBagConstraints.HORIZONTAL;
            ResponseSpeedSliderModel = javaObjectEDT('javax.swing.DefaultBoundedRangeModel',0,0,0,100);
            ResponseSpeedSlider = javaObjectEDT('com.mathworks.mwswing.MJSlider',ResponseSpeedSliderModel);
            ResponseSpeedSlider.setName('PIDTUNER_RESPONSESPEEDSLIDER');
            ResponseSpeedSlider.setMinorTickSpacing(50);
            ResponseSpeedSlider.setPaintTicks(true);
            ResponseSpeedSlider.setFocusable(false);
            LabelSlower = javaObjectEDT('com.mathworks.mwswing.MJLabel',pidtool.utPIDgetStrings('cst','tunerdlg_respslider_left'));
            LabelFaster = javaObjectEDT('com.mathworks.mwswing.MJLabel',pidtool.utPIDgetStrings('cst','tunerdlg_respslider_right'));
            labelTable = java.util.Hashtable;
            labelTable.put(java.lang.Integer(0),LabelSlower);
            labelTable.put(java.lang.Integer(100),LabelFaster);
            ResponseSpeedSlider.setLabelTable(labelTable);
            ResponseSpeedSlider.setPaintLabels(true);
            WCPanel.add(ResponseSpeedSlider,GBc);
            % >> button
            GBc.anchor = java.awt.GridBagConstraints.NORTHWEST;
            GBc.gridx = 2;
            GBc.gridy = 0;
            GBc.weightx = 0;
            GBc.gridwidth = 1;
            GBc.fill = java.awt.GridBagConstraints.NONE;
            FastButton = javaObjectEDT('com.mathworks.mwswing.MJButton');
            FastButton.setName('PIDTUNER_FASTBUTTON');
            FastButton.setToolTipText(pidtool.utPIDgetStrings('cst','fastbutton_tooltip'));
            Icon = javaObjectEDT('javax.swing.ImageIcon',fullfile(matlabroot,'toolbox','shared','controllib','graphics','Resources','pid_fastarrow.png'));
            FastButton.setIcon(Icon);
            FastButton.setPreferredSize(java.awt.Dimension(32,24));
            FastButton.setFlyOverAppearance(true);
            FastButton.setFocusTraversable(false);
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
            GBc.insets = java.awt.Insets(5,0,5,0);
            GBc.fill = java.awt.GridBagConstraints.HORIZONTAL;
            
            % row 1
            % WC label
            GBc.anchor = java.awt.GridBagConstraints.CENTER;
            GBc.gridx = 0;
            GBc.gridy = 0;
            GBc.weightx = 0;
            GBc.gridwidth = 1;
            WCValueLabel = javaObjectEDT('com.mathworks.mwswing.MJLabel',sprintf('%s %0.3g',pidtool.utPIDgetStrings('cst','tunerdlg_respslider'),0));
            WCValueLabel.setName('PIDTUNER_RESPTIMELABEL');
            WCValueLabel.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
            pidtool.utPIDaddCSH('control',WCValueLabel,'pidtuner_responsespeed');
            Panel.add(WCValueLabel,GBc);
            % row 2
            GBc.anchor = java.awt.GridBagConstraints.CENTER;
            GBc.gridx = 0;
            GBc.gridy = 1;
            GBc.weightx = 1;
            GBc.gridwidth = 1;
            Panel.add(WCPanel,GBc);
            
            % handles
            this.Handles.Panel = Panel;
            this.Handles.ResponseSpeedSlider = ResponseSpeedSlider;
            this.Handles.ResponseSpeedSliderModel = ResponseSpeedSliderModel;
            this.Handles.SlowButton = SlowButton;
            this.Handles.FastButton = FastButton;
            this.Handles.WCValueLabel = WCValueLabel;
            
            % callbacks
            h = handle(ResponseSpeedSlider,'callbackproperties');
            h.MousePressedCallback = {@(x,y) SliderMousePressedCallback(this)};
            h.MouseReleasedCallback = {@(x,y) SliderMouseReleasedCallback(this)};
            h.StateChangedCallback = {@localResponseSpeedSliderChange this};

            h = handle(SlowButton,'callbackproperties');
            h.ActionPerformedCallback = {@localSlowButtonChange this};
            
            h = handle(FastButton,'callbackproperties');
            h.ActionPerformedCallback = {@localFastButtonChange this};

        end
    end
    
end

%% Callbacks
% <<
function localSlowButtonChange(hObject,ed,this) %#ok<*INUSL>
    this.CenterWC = min(max(0.1*this.CenterWC, this.MinWC*10),this.MaxWC);
    if this.CenterWC<=this.MinWC*10
        this.Handles.SlowButton.setEnabled(false);
    end
    this.Handles.FastButton.setEnabled(true);
    localResponseSpeedSliderChange([],[],this)
end

% >>
function localFastButtonChange(hObject,ed,this) %#ok<*INUSL>
    this.CenterWC = max(min(10*this.CenterWC, this.MaxWC/10),this.MinWC);
    if this.CenterWC>=this.MaxWC/10
        this.Handles.FastButton.setEnabled(false);
    end
    this.Handles.SlowButton.setEnabled(true);
    localResponseSpeedSliderChange([],[],this)
end

% knob
function localResponseSpeedSliderChange(hObject,ed,this) %#ok<*INUSL>
    % get real WC from slider location
    newLocation = this.Handles.ResponseSpeedSlider.getValue;
    newWC = this.getFromLocationToWC(newLocation);
    this.Handles.WCValueLabel.setText(sprintf('%s %0.3g sec',pidtool.utPIDgetStrings('cst','tunerdlg_respslider'),2/newWC));
    % update WC
    this.WC = newWC;
end

% reset knob to middle
function resetWCSlider(this, newWC)
    % reset slider knob to center
    this.CenterWC = newWC;
    pidtool.AbstractControllerDesignPanel.setSliderWithoutFiringEvent(this.Handles.ResponseSpeedSlider, 50);
    this.Handles.WCValueLabel.setText(sprintf('%s %0.3g sec',pidtool.utPIDgetStrings('cst','tunerdlg_respslider'),2/newWC));                    
end
