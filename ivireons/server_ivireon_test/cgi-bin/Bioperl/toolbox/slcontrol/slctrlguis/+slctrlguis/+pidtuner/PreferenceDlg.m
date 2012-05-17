classdef PreferenceDlg < handle
    % @PreferenceDlg defines preference dialog for PID Tuner

    % Author(s): R. Chen
    % Copyright 2009-2010 The MathWorks, Inc.
    % $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:53:51 $
    
    properties

        ParentFigure
        Handles

    end

    properties(SetObservable)
        
        PlotSettings                       
    
    end
    
    methods

        % Constructor
        function this = PreferenceDlg(fig, color)
            this.ParentFigure = fig;
            this.build(color);
        end
        
        % refresh GUI
        function setPreferences(this, s)
            color = s.TunedColor;
            jcolor = java.awt.Color(color(1),color(2),color(3));
            this.Handles.TunedColorColorPicker.setValue(jcolor);
            color = s.BlockColor;
            jcolor = java.awt.Color(color(1),color(2),color(3));
            this.Handles.BlockColorColorPicker.setValue(jcolor);
        end
        
        % set visibility
        function setVisible(this, Visible)
            scrsz = get(this.ParentFigure,'position');
            center = [scrsz(1)+scrsz(3)/2 scrsz(2)+scrsz(4)/2];
            set(this.Handles.Figure,'Position',[center(1)-30 center(2)-6 60 12]);
            set(this.Handles.Figure,'Visible',Visible);
        end
        
    end
    
    methods (Access = protected)

        function build(this, Color)
            
            Prefs = cstprefs.tbxprefs;
            
            %% create figure
            fig = figure('Color',Color,...
                 'IntegerHandle','off', ...
                 'Menubar','None',...
                 'Toolbar','None',...
                 'DockControl','off',...
                 'Name',pidtool.utPIDgetStrings('cst','prefdlg_title'), ...
                 'NumberTitle','off', ...
                 'Visible','off', ...
                 'Tag','ImportPlantDlg',...
                 'HandleVisibility','off');
            % set default dialog size
            set(fig,'units','character')

            %% panel
            Panel = javaObjectEDT('com.mathworks.mwswing.MJPanel');
            titleborder = javaMethodEDT('createTitledBorder','javax.swing.BorderFactory',pidtool.utPIDgetStrings('cst','prefdlg_title'));
            javaObjectEDT(titleborder);
            Panel.setBorder(titleborder);
            Panel.setLayout(java.awt.GridBagLayout);
            Panel.setFont(Prefs.JavaFontB);            
            
            %% common properties of GBC
            GBc = java.awt.GridBagConstraints;
            GBc.insets = java.awt.Insets(10,5,10,5);
            GBc.fill = java.awt.GridBagConstraints.HORIZONTAL;
            
            % row 1: 
            TunedColorLabel = javaObjectEDT('com.mathworks.mwswing.MJLabel',pidtool.utPIDgetStrings('cst','prefdlg_tunedcolor_label'));
            TunedColorLabel.setName('PREFERENCEDLG_TUNEDCOLORLABEL');
            pidtool.utPIDaddCSH('control',TunedColorLabel,'pidtuner_prefdlg_tunedcolor');
            TunedColorLabel.setHorizontalAlignment(javax.swing.SwingConstants.RIGHT);
            GBc.gridx = 0;
            GBc.weightx = 0;
            GBc.gridy = 0;
            GBc.anchor = java.awt.GridBagConstraints.EAST;
            Panel.add(TunedColorLabel,GBc);
            TunedColorColorPicker = javaObjectEDT('com.mathworks.mlwidgets.graphics.ColorPicker',...
                com.mathworks.mlwidgets.graphics.ColorPicker.NO_OPTIONS,...
                com.mathworks.mlwidgets.graphics.ColorPicker.LINE_ICON,...
                'Color');
            TunedColorColorPicker.setName('PREFERENCEDLG_TUNEDCOLORCOMBOBOX');
            GBc.gridx = 1;
            GBc.weightx = 1;
            GBc.gridy = 0;
            GBc.anchor = java.awt.GridBagConstraints.WEST;
            GBc.fill = java.awt.GridBagConstraints.NONE;
            Panel.add(TunedColorColorPicker,GBc);
            % row 2: 
            BlockColorLabel = javaObjectEDT('com.mathworks.mwswing.MJLabel',pidtool.utPIDgetStrings('cst','prefdlg_blockcolor_label'));
            BlockColorLabel.setName('PREFERENCEDLG_BLOCKCOLORLABEL');
            pidtool.utPIDaddCSH('control',BlockColorLabel,'pidtuner_prefdlg_blockcolor');
            BlockColorLabel.setHorizontalAlignment(javax.swing.SwingConstants.RIGHT);
            GBc.gridx = 0;
            GBc.weightx = 0;
            GBc.gridy = 1;
            GBc.anchor = java.awt.GridBagConstraints.EAST;
            Panel.add(BlockColorLabel,GBc);
            BlockColorColorPicker = javaObjectEDT('com.mathworks.mlwidgets.graphics.ColorPicker',...
                com.mathworks.mlwidgets.graphics.ColorPicker.NO_OPTIONS,...
                com.mathworks.mlwidgets.graphics.ColorPicker.LINE_ICON,...
                'Color');
            BlockColorColorPicker.setName('PREFERENCEDLG_BLOCKCOLORCOMBOBOX');
            GBc.gridx = 1;
            GBc.weightx = 1;
            GBc.gridy = 1;
            GBc.anchor = java.awt.GridBagConstraints.WEST;
            GBc.fill = java.awt.GridBagConstraints.NONE;
            Panel.add(BlockColorColorPicker,GBc);
            % row 5: 
            GBc.gridx = 0;
            GBc.weightx = 0;
            GBc.gridy = 2;
            GBc.gridwidth = 2;
            GBc.weighty = 1;
            Panel.add(javaObjectEDT('com.mathworks.mwswing.MJPanel'),GBc);

            % add panel to figure
            [~, PanelCONTAINER] = javacomponent(Panel,[.1,.1,.9,.9],fig);
            set(PanelCONTAINER,'units','character');
            
            %% Button Panel
            ButtonPanel = uipanel('parent',fig,'bordertype','none','units','character','BackgroundColor', Color);
            % Help
            CSHButton = javaObjectEDT('com.mathworks.mwswing.MJButton',...
                javaObjectEDT('javax.swing.ImageIcon',fullfile(matlabroot,'toolbox','matlab','icons','csh_icon.png')));
            CSHButton.setName('PREFERENCEDLG_CSHBUTTON');
            CSHButton.setFlyOverAppearance(true);
            CSHButton.setFocusTraversable(false);
            [~, CSHButtonCONTAINER] = javacomponent(CSHButton,[.1,.1,.9,.9],ButtonPanel);
            set(CSHButtonCONTAINER,'units','character')
            % OK
            OKButton = javaObjectEDT('com.mathworks.mwswing.MJButton',pidtool.utPIDgetStrings('cst','button_ok'));
            OKButton.setName('PREFERENCEDLG_OKBUTTON');
            [~, OKButtonCONTAINER] = javacomponent(OKButton,[.1,.1,.9,.9],ButtonPanel);
            set(OKButtonCONTAINER,'units','character')
            % Cancel
            CancelButton = javaObjectEDT('com.mathworks.mwswing.MJButton',pidtool.utPIDgetStrings('cst','button_cancel'));
            CancelButton.setName('PREFERENCEDLG_CANCELBUTTON');
            [~, CancelButtonCONTAINER] = javacomponent(CancelButton,[.1,.1,.9,.9],ButtonPanel);
            set(CancelButtonCONTAINER,'units','character')
            % Apply
            ApplyButton = javaObjectEDT('com.mathworks.mwswing.MJButton',pidtool.utPIDgetStrings('cst','button_apply'));
            ApplyButton.setName('PREFERENCEDLG_APPLYBUTTON');
            [~, ApplyButtonCONTAINER] = javacomponent(ApplyButton,[.1,.1,.9,.9],ButtonPanel);
            set(ApplyButtonCONTAINER,'units','character')
            
            this.Handles.Figure = fig;
            this.Handles.TunedColorLabel = TunedColorLabel;
            this.Handles.TunedColorColorPicker = TunedColorColorPicker;
            this.Handles.BlockColorLabel = BlockColorLabel;
            this.Handles.BlockColorColorPicker = BlockColorColorPicker;
            this.Handles.PanelCONTAINER = PanelCONTAINER;
            this.Handles.ButtonPanel = ButtonPanel;
            this.Handles.CSHButtonCONTAINER = CSHButtonCONTAINER;
            this.Handles.OKButtonCONTAINER = OKButtonCONTAINER;
            this.Handles.CancelButtonCONTAINER = CancelButtonCONTAINER;
            this.Handles.ApplyButtonCONTAINER = ApplyButtonCONTAINER;
            
            %% figure callbacks
            set(fig,...
                'ResizeFcn',@(x,y) layout(this),...
                'CloseRequestFcn',@(x,y) close(this));

            %% Button Callbacks
            h = handle(CSHButton,'callbackproperties');
            hListener = handle.listener(h, 'ActionPerformed',{@CSHButtonCallback this});
            this.Handles.CSHButtonListener = hListener;
            h = handle(OKButton,'callbackproperties');
            hListener = handle.listener(h, 'ActionPerformed',{@OKButtonCallback this});
            this.Handles.OKButtonListener = hListener;
            h = handle(CancelButton,'callbackproperties');
            hListener = handle.listener(h, 'ActionPerformed',{@CancelButtonCallback this});
            this.Handles.CancelButtonListener = hListener;
            h = handle(ApplyButton,'callbackproperties');
            hListener = handle.listener(h, 'ActionPerformed',{@ApplyButtonCallback this});
            this.Handles.ApplyButtonListener = hListener;

        end
        
        function layout(this)
            p = get(this.Handles.Figure,'Position');
            fw = p(3);  fh = p(4);
            set(this.Handles.ButtonPanel,'Position',[0, 0, fw, 3]);
            set(this.Handles.CSHButtonCONTAINER,'Position',[1,0.5,5,2]);
            set(this.Handles.OKButtonCONTAINER,'Position',[max(0.01,fw-46),0.5,14,2]);
            set(this.Handles.CancelButtonCONTAINER,'Position',[max(0.01,fw-31),0.5,14,2]);
            set(this.Handles.ApplyButtonCONTAINER,'Position',[max(0.01,fw-16),0.5,14,2]);
            set(this.Handles.PanelCONTAINER,'Position',[2, 3, max(0.01,fw-4), max(0.01,fh-3.5)]);
        end

        function apply(this)
            % obtain current settings
            TunedColor = this.Handles.TunedColorColorPicker.getValue;            
            BlockColor = this.Handles.BlockColorColorPicker.getValue;            
            % update PlotSettings property
            this.PlotSettings = struct( ...
                'TunedColor',[TunedColor.getRed,TunedColor.getGreen,TunedColor.getBlue]/255,...
                'BaseColor',[BlockColor.getRed,BlockColor.getGreen,BlockColor.getBlue]/255);
        end
        
        function close(this)
            try %#ok<*TRYNC>
                set(this.Handles.Figure,'Visible','off');
            end
        end
    end
    
end

%% Callback
function CSHButtonCallback(hObject,eventdata,this) %#ok<*INUSD>
    helpview(fullfile(docroot,'csh_icon_message.html'),'CSHelpWindow');
end

function OKButtonCallback(hObject,eventdata,this) %#ok<*INUSL>
    this.apply;
    this.close;
end

function CancelButtonCallback(hObject,eventdata,this) %#ok<*INUSL>
    this.close;
end

function ApplyButtonCallback(hObject,eventdata,this) %#ok<*INUSL>
    this.apply;
end

