classdef (Hidden = true) UncertaintyDialog < handle
    % @UncertaintyDialog class definition
    
    %   Author(s): C. Buhr
    %   Copyright 2009-2010 The MathWorks, Inc.
    %	 $Revision: 1.1.8.4 $  $Date: 2010/05/10 16:58:50 $
    properties
        Parent  % sisodb
        Frame  % MJFrame
        NominalPanel % Struct
        FrequencySpecPanel % Struct
        ButtonPanel % Struct
        DestroyListener
        ConfigChangedListener
        SISOPrefChangeListener
        FreqSpecData % Struct
    end
    
    methods
        %%
        function this = UncertaintyDialog(sisodb)
            % Constructor
            this.Parent = sisodb;
            this.FreqSpecData = sisodb.Preferences.MultiModelFrequencySelectionData;
            
            % Build GUI components
            build(this)
            
            % Update gui
            updateNominalPanel(this);
            updateFreqSpecPanel(this);
            
            % Update gui
            installListeners(this)
            
            % Make Frame visible
            this.Frame.setVisible(true);

        end
        
        
        %%
        function installListeners(this)
            % Add Listener to plant change and nominal change
            % SISOdb begin destroyed
            this.DestroyListener = handle.listener(this.Parent,'ObjectBeingDestroyed',@(es,ed) cleanup(this));
            this.ConfigChangedListener = handle.listener(this.Parent.LoopData,'ConfigChanged',@(es,ed) localConfigChange(this));
        end
        

        %%
        function close(this)
            this.Frame.setVisible(false);
        end
        
        %%
        function cleanup(this)
            MFrame = this.Frame;
            delete(this);
            dispose(MFrame);
        end
        
    end
    
    
    methods (Access = private)
        
        %%
        function build(this)
            import java.awt.*;
            import javax.swing.*;
            import com.mathworks.mwswing.*;
            import com.mathworks.page.utils.VertFlowLayout;
            import javax.swing.table.*;
            import javax.swing.border.*;
            % Builds GUI
            MainFrame = javaObjectEDT('com.mathworks.mwswing.MJFrame');
            MainFrame.setTitle(ctrlMsgUtils.message('Control:compDesignTask:strMultiModelDialogTitle'));
            h = handle(MainFrame,'callbackproperties');
            set(h,'WindowClosingCallback',@(es,ed) close(this));
            
            MainPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel',BorderLayout(0,5));
            MainPanel.setBorder(EmptyBorder(10,10,5,10));
            MainFrame.getContentPane.add(MainPanel);
            
            NomPanel = buildNominalModelPanel(this);
            FreqPanel = buildFreqSpecPanel(this);
            BtnPanel = buildButtonPanel(this);
            
            % Panel
            panel = javaObjectEDT('com.mathworks.mwswing.MJPanel',BorderLayout(0,10));
            panel.add(NomPanel,BorderLayout.NORTH);
            panel.add(FreqPanel,BorderLayout.CENTER);
            
            MainPanel.add(panel,BorderLayout.CENTER);
            MainPanel.add(BtnPanel, BorderLayout.SOUTH);
            
            MainFrame.pack;
            this.Frame = MainFrame;
        end
        
        %%
        function help(this)
            MapFile = ctrlguihelp;
            helpview(MapFile,'siso_modelarray','CSHelpWindow')
        end
        
        %%
        function exportData(this)
            this.Parent.Preferences.MultiModelFrequencySelectionData = this.FreqSpecData; 
        end
        
        %%
        function updateFreqSpecPanel(this)
            if this.FreqSpecData.UseAutoMode
                this.FrequencySpecPanel.AutoSelectRadioButton.setSelected(true);
                this.FrequencySpecPanel.ManualSelectEditField.setEnabled(false);
            else
                this.FrequencySpecPanel.ManualSelectRadioButton.setSelected(true);
                this.FrequencySpecPanel.ManualSelectEditField.setEnabled(true);
            end
            this.FrequencySpecPanel.ManualSelectEditField.setText(this.FreqSpecData.UserModeString);
        end
        
        
        %%
        function updateNominalPanel(this)
            this.NominalPanel.NominalEditBox.setText(sprintf('%d',this.getNominal));
            setNominalSpinnerValue(this, this.getNominal);
        end
        
        %%
        function setNominal(this,Value)
            this.Parent.Loopdata.setNominalModelIndex(Value)
        end
        
        %%
        function Value = getNominal(this)
            Value = this.Parent.Loopdata.Plant.getNominalModelIndex;
        end
        
        %%
        function Value = getNumberOfModels(this)
            Value = length(this.Parent.Loopdata.Plant.getP);
        end
        
        
        %%
        function setNominalSpinnerValue(this, newNominal)
            Model = this.NominalPanel.NominalSpinner.getModel;
            tmp = Model.getChangeListeners;
            for ct=1:length(tmp)
                if isa(tmp(ct),'javax.swing.JSpinner$ModelListener')
                    Model.removeChangeListener(tmp(ct));
                end
            end
            Model.setValue(newNominal);
            Model.setMaximum(java.lang.Double(this.getNumberOfModels));
            for ct=1:length(tmp)
                if isa(tmp(ct),'javax.swing.JSpinner$ModelListener')
                    Model.addChangeListener(tmp(ct));
                end
            end
            
        end
        
        %%
        function Btnpanel = buildButtonPanel(this)
            % buildButtonPanel Create the button panel
            import java.awt.*;
            import javax.swing.*;
            import com.mathworks.mwswing.*;
            import javax.swing.border.*;
            
            Btnpanel = javaObjectEDT('com.mathworks.mwswing.MJPanel',FlowLayout(FlowLayout.RIGHT));
%             
%             Btn1 = javaObjectEDT('com.mathworks.mwswing.MJButton',ctrlMsgUtils.message('Controllib:general:strOK'));
%             Btn1.setName('OK')
%             h = handle( Btn1, 'callbackproperties');
%             set(h,'ActionPerformedCallback',@(es,ed) exportData(this));
            
            Btn2 = javaObjectEDT('com.mathworks.mwswing.MJButton',ctrlMsgUtils.message('Controllib:general:strClose'));
            Btn2.setName('Close');
            h = handle( Btn2, 'callbackproperties');
            set(h,'ActionPerformedCallback',@(es,ed) close(this));
            
            Btn3 = javaObjectEDT('com.mathworks.mwswing.MJButton',ctrlMsgUtils.message('Controllib:general:strHelp'));
            Btn3.setName('Help')
            h = handle( Btn3, 'callbackproperties');
            set(h,'ActionPerformedCallback',@(es,ed) help(this));
            
%             Btnpanel.add(Btn1);
            Btnpanel.add(Btn2);
            Btnpanel.add(Btn3);
            this.ButtonPanel = struct(...
                'CloseButton', Btn2, ...
                'HelpButton',Btn3);
        end
                
        %%
        function NomPanel = buildNominalModelPanel(this)
            import java.awt.*;
            import javax.swing.*;
            import com.mathworks.mwswing.*;
            import javax.swing.border.*;
            % buildNominalModelPanel Create the nominal Panel
            NomPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel');
            titleborder = javaMethodEDT('createTitledBorder','javax.swing.BorderFactory',...
                ctrlMsgUtils.message('Control:compDesignTask:strMultiModelNominalPanelTitle'));
            %          NominalSliderModel = javaObjectEDT('javax.swing.DefaultBoundedRangeModel',1,0,1,4);
            %          NominalSlider = javaObjectEDT('com.mathworks.mwswing.MJSlider',NominalSliderModel);
            %          NominalSlider.setName('NominalSlider');
            %          NominalSlider.setValue(1)
            %          NominalSlider.setSnapToTicks(true)
            
            % NomPanel.add(NominalSlider);
            NomPanel.setBorder(titleborder);
            %NomPanel.setLayout(FlowLayout(FlowLayout.LEFT));
            
            NominalLabel = javaObjectEDT('com.mathworks.mwswing.MJLabel', ...
                 ctrlMsgUtils.message('Control:compDesignTask:strMultiModelNominalPanelLabel'));
            NominalTextField = javaObjectEDT('com.mathworks.mwswing.MJTextField',sprintf('%d',getNominal(this)),8);
            NominalTextField.setName('NominalTEXTFIELD');
            tmp = NominalTextField.getPreferredSize;
            tmp.height = tmp.height*1.1;
            NominalTextField.setPreferredSize(tmp);
            NominalSpinner = javaObjectEDT('com.mathworks.mwswing.MJSpinner');
            NominalSpinner.setName('PIDTUNER_NominalSPINNER');
            NominalSpinner.setEditor(NominalTextField);
            NominalSpinnerNumberModel = javaObjectEDT('javax.swing.SpinnerNumberModel',getNominal(this),1,getNumberOfModels(this),1);
            NominalSpinnerNumberModel.setMinimum(java.lang.Double(1));
            NominalSpinnerNumberModel.setMaximum(java.lang.Double(getNumberOfModels(this)));
            NominalSpinner.setModel(NominalSpinnerNumberModel);
            
            NomPanel.add(NominalLabel);
            NomPanel.add(NominalSpinner);
            
            h = handle(NominalSpinner,'callbackproperties');
            h.StateChangedCallback = {@localNominalSpinnerChange this};
            
            h = handle(NominalTextField,'callbackproperties');
            h.ActionPerformedCallback = {@localNominalEditorChange this};
            this.NominalPanel = struct(...
                'Panel', NomPanel, ...
                'NominalEditBox',NominalTextField,...
                'NominalSpinner',NominalSpinner);
        end
        
        %%
        function FreqPanel = buildFreqSpecPanel(this)
            import java.awt.*;
            import javax.swing.*;
            import com.mathworks.mwswing.*;
            import com.mathworks.page.utils.VertFlowLayout;
            import javax.swing.border.*;
            % buildFreqSpecPanel Create the Frequency Specification Panel
            %% Middle Panel
            Panel2 = javaObjectEDT('com.mathworks.mwswing.MJPanel',BorderLayout);
            titleborder = javaMethodEDT('createTitledBorder',...
                'javax.swing.BorderFactory',ctrlMsgUtils.message('Control:compDesignTask:strMultiModelFreqPanelTitle'));
            Panel2.setBorder(titleborder);
            
           % Label1 = MJLabel(sprintf('Specify frequencies for multi-model computations:'));
            
            RadioButton1 = javaObjectEDT('com.mathworks.mwswing.MJRadioButton', ...
                ctrlMsgUtils.message('Control:compDesignTask:strMultiModelFreqPanelLabel1'));
            h = handle(RadioButton1, 'callbackproperties');
            h.ActionPerformedCallback = {@localAutoSelect this};
            RadioButton2 = javaObjectEDT('com.mathworks.mwswing.MJRadioButton',...
                ctrlMsgUtils.message('Control:compDesignTask:strMultiModelFreqPanelLabel2'));
            h = handle(RadioButton2, 'callbackproperties' );
            h.ActionPerformedCallback = {@localUserSpecified this};
            
            %% Create button group,
            %% This allows only one radio button in the group selected at a time
            RadioBtnGroup = ButtonGroup;
            RadioBtnGroup.add(RadioButton1);
            RadioBtnGroup.add(RadioButton2);
            
            FreqSpecEdit = javaObjectEDT('com.mathworks.mwswing.MJTextField',20);
            awtinvoke(FreqSpecEdit,'setName','UserFreqField');
            h = handle(FreqSpecEdit, 'callbackproperties' );
            h.ActionPerformedCallback = {@localSetFreq this};
            
            
            Btn = javaObjectEDT('com.mathworks.mwswing.MJButton',ctrlMsgUtils.message('Controllib:general:strApply'));
            Btn.setName('Apply');
            h = handle( Btn, 'callbackproperties');
            set(h,'ActionPerformedCallback',@(es,ed) exportData(this));
            
            SubPanel2a = javaObjectEDT('com.mathworks.mwswing.MJPanel',FlowLayout(FlowLayout.LEFT));
            SubPanel2a.add(RadioButton2);
            SubPanel2a.add(FreqSpecEdit);
            
            SubPanel2b=javaObjectEDT('com.mathworks.mwswing.MJPanel',VertFlowLayout(VertFlowLayout.LEFT));
            SubPanel2b.setBorder(EmptyBorder(0,15,0,0));
            
            JunkPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel');
            JunkPanel.add(RadioButton1);
            SubPanel2b.add(JunkPanel);
            SubPanel2b.add(SubPanel2a);
            
            SubPanel2 = javaObjectEDT('com.mathworks.mwswing.MJPanel',FlowLayout(FlowLayout.LEFT));
            SubPanel2.add(SubPanel2b);
            
            SubPanel3 = javaObjectEDT('com.mathworks.mwswing.MJPanel',FlowLayout(FlowLayout.RIGHT));
            SubPanel3.add(Btn);
            
            %Panel2.add(Label1,BorderLayout.NORTH);
            Panel2.add(SubPanel2,BorderLayout.CENTER);
            
            
            Panel2.add(SubPanel3,BorderLayout.SOUTH);
            
            FreqPanel = Panel2;
            
            
            this.FrequencySpecPanel = struct(...
                'Panel', FreqPanel, ...
                'AutoSelectRadioButton',RadioButton1,...
                'ManualSelectRadioButton',RadioButton2, ...
                'ManualSelectEditField', FreqSpecEdit,...
                'ApplyButton', Btn);
        end
        
        
    end
end

%--------------------------------------------------------------------------


% Nominal spinner
function localNominalSpinnerChange(hObject,ed,this) %#ok<*INUSL>
% get Nominal
newNominal = hObject.getModel.getValue;
% setText will not fire event
this.NominalPanel.NominalEditBox.setText(sprintf('%d',newNominal));
% update Nominal
this.setNominal(newNominal);
end

% Nominal editor
function localNominalEditorChange(hObject,ed,this)
% get Nominal
newNominal = str2double(char(hObject.getText));
if isnan(newNominal) || ~isscalar(newNominal) || ~isreal(newNominal) || ...
        newNominal<0 || newNominal>this.getNumberOfModels || ...
        ~isfinite(newNominal) ||~(mod(newNominal,1) == 0)
    hObject.setText(sprintf('%d',this.getNominal));
else
    % update spinner value
    setNominalSpinnerValue(this, newNominal);
    % update Nominal
    this.setNominal(newNominal);
end
end

% Configuration Change
function localConfigChange(this)

if getNumberOfModels(this) < 2
    close(this)
else
    this.NominalPanel.NominalEditBox.setText(sprintf('%d',this.getNominal));
    setNominalSpinnerValue(this, this.getNominal);
end

end



% ------------------------------------------------------------------------%
% Function: localAutoSelect
% Purpose:  AutoSelect-Radio Button
% ------------------------------------------------------------------------%
function localAutoSelect(hsrc,event,this)

this.FrequencySpecPanel.ManualSelectEditField.setEnabled(false);
this.FreqSpecData.UseAutoMode = true;


end


% ------------------------------------------------------------------------%
% Function: localUserSpecified
% Purpose:  User Specified-Radio Button
% ------------------------------------------------------------------------%
function localUserSpecified(hsrc,event,this)

this.FrequencySpecPanel.ManualSelectEditField.setEnabled(true);
this.FreqSpecData.UseAutoMode = false;

end

% ------------------------------------------------------------------------%
% Function: localSetFreq
% Purpose:  User Specified Text Field
% ------------------------------------------------------------------------%
function localSetFreq(hsrc,event,this)

% Revisit need error data handling here
Data = evalin('base',char(this.FrequencySpecPanel.ManualSelectEditField.getText));

this.FreqSpecData.UserModeString = char(this.FrequencySpecPanel.ManualSelectEditField.getText);
this.FreqSpecData.UserModeData = Data(:);

end



