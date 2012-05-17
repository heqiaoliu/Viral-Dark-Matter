classdef (Hidden = true) PopupPanel < handle
    % PopupPanel class definition
    % This class creates the pop-up panel widget
    
    %   Copyright 2008-2009 The MathWorks, Inc.
    %	 $Revision: 1.1.8.2 $  $Date: 2010/03/26 17:49:23 $
    properties
        Parent  % Panel or Figure
        Position = [0,0,1,1] % Normalized units
        Visible = 'off'
        Minimized = true
    end
    
    properties (SetAccess = private, GetAccess = private)
        Panel
        PanelContainer
        ShowHideButton
        ShowHideButtonContainer
        ScrollPane
        Listeners
        MinimizeIcon
        MaximizeIcon
    end

    methods (Static = true)
        function MessageTextPane = createMessageTextPane(Str,FontName,FontSize)
            % Font size in Points
            if nargin == 1;
                FontName = get(0,'DefaultTextFontName');
                FontSize = get(0,'DefaultTextFontSize');
            elseif nargin == 2;
                FontSize = get(0,'DefaultTextFontSize');
            end
                
            Msg = sprintf('<span style=\"font-size: %dpt\" face=\"%s\"> %s</span>',FontSize,FontName,Str);
            MessageTextPane = javaObjectEDT('com.mathworks.mwswing.MJTextPane');
            MessageTextPane.setContentType('text/html');
            MessageTextPane.setEditable(0);
            MessageTextPane.setText(Msg);
            MessageTextPane.setBackground(javax.swing.UIManager.getColor('info'))
            
        end
        
    end
    
    methods
  
        %% Constructor
        function this = PopupPanel(Parent)
            this.Parent = Parent;
            this.build;
        end
        
        %% 
        function build(this)
            
            % Create Icons
            pathstr = fullfile(matlabroot,'toolbox','shared','controllib','graphics', ...
                'Resources','MaximizeButton.GIF');
            this.MaximizeIcon = javaObjectEDT('javax.swing.ImageIcon',pathstr);
            
            pathstr = fullfile(matlabroot,'toolbox','shared','controllib','graphics', ...
                'Resources','MinimizeButton.GIF');
            this.MinimizeIcon = javaObjectEDT('javax.swing.ImageIcon',pathstr);
            
            % Create Show/Hide Button
            this.ShowHideButton = javaObjectEDT('com.mathworks.mwswing.MJButton',this.MaximizeIcon);
            this.ShowHideButton.setFocusPainted(false);
            mar =  this.ShowHideButton.getMargin();
            mar.top = 0;
            mar.bottom = 0;
            this.ShowHideButton.setMargin(mar);
            this.ShowHideButton.setBorder(javax.swing.BorderFactory.createLineBorder(java.awt.Color(0,0,0,0)))
            [hcomponent, this.ShowHideButtonContainer] = javacomponent(this.ShowHideButton, [0,0,1,1], this.Parent);
            
            % Create Popup Panel
            this.Panel = javaObjectEDT('com.mathworks.mwswing.MJPanel');
%             this.Panel.setBorder(javax.swing.BorderFactory.createRaisedBevelBorder);
            this.Panel.setBorder(javax.swing.BorderFactory.createMatteBorder(1,1,1,1,javax.swing.UIManager.getColor('TextField.darkShadow')))

            
            this.Panel.setLayout(java.awt.GridBagLayout)
            gbc           = java.awt.GridBagConstraints;
            gbc.fill      = java.awt.GridBagConstraints.BOTH;
            gbc.gridheight= 1;
            gbc.gridwidth = 1;
            gbc.gridx     = 0;
            gbc.gridy     = 0;
            gbc.insets    = java.awt.Insets(0,0,0,0);
            gbc.weightx   = 1;
            gbc.weighty   = 1;

            % Create ScrollPane for Popup Panel
%             this.ScrollPane = javaObjectEDT('com.mathworks.mwswing.MJScrollPane');
            this.ScrollPane = javaObjectEDT('com.mathworks.widgets.LightScrollPane');
            this.ScrollPane.setBorder(javax.swing.border.EmptyBorder(0,0,0,0))
%             this.ScrollPane.setViewportBorder(javax.swing.BorderFactory.createMatteBorder(0,0, 0,0, javax.swing.UIManager.getColor('TextField.darkShadow')))    
            this.ScrollPane.setVerticalScrollBarPolicy(this.ScrollPane.VERTICAL_SCROLLBAR_AS_NEEDED);
            this.ScrollPane.setHorizontalScrollBarPolicy(this.ScrollPane.HORIZONTAL_SCROLLBAR_NEVER);
            this.Panel.add(this.ScrollPane,gbc);
            
            [hcomponent, this.PanelContainer] = javacomponent( this.Panel, [0,0,1,1], this.Parent);
            
            
            % Callbacks
            h = handle(this.ShowHideButton, 'callbackproperties');
            h.ActionPerformedCallback = {@localButtonCallback, this};
            
            % When parent figure is destroyed, delete this object
            % 'ObjectBeingDestroyed' is a MCOS event.
            addlistener(this.Parent, 'ObjectBeingDestroyed',@(es,ed) localDelete(this));
            
        end
        
        %% SetPosition
        function setPosition(this,Pos)
            this.Position = Pos;
            this.layout;
        end
        
        %% Layout
        function layout(this)
            Pos = hgconvertunits(this.Parent,this.Position, ...
                'normalized','pixels',this.Parent);
            ParentPos =hgconvertunits(this.Parent,get(this.Parent,'Position'),...
                get(this.Parent,'units'),'pixels',this.Parent);

            Cx = Pos(1);
            Cy = Pos(2);
            CW = Pos(3);
            CH = min(Pos(4),(ParentPos(4)-Cy));
            
            % Button width and height
            BW = 18;
            BH = 18;
            
            ButtonPos = [Cx, Cy+CH-BH, BW, BH];
            set(this.ShowHideButtonContainer,'Position',ButtonPos);
            
            PanelPos = [Cx+BW, Cy, max(CW-BW,eps), CH];
            set(this.PanelContainer,'Position',PanelPos);
            this.Panel.setMinimumSize(java.awt.Dimension(PanelPos(4),PanelPos(3)));
            this.Panel.setMaximumSize(java.awt.Dimension(PanelPos(4),PanelPos(3)));
            
        end
        
        
        %% hidePanel
        function hidePanel(this)
            this.Minimized = true;
            set(this.PanelContainer,'Visible','off')
            this.ShowHideButton.setIcon(this.MaximizeIcon);
            
        end
        
        %% showPanel
        function showPanel(this)
            this.Minimized = false;
            this.ShowHideButton.setIcon(this.MinimizeIcon);
            set(this.PanelContainer,'Visible','on')

        end

        
        %% setPanel
        function setPanel(this,Component)
            this.ScrollPane.setViewportView(Component)            
        end
        
        
        %% setVisible
        function setVisible(this,Flag)
            this.Visible = Flag;
            if Flag
                set(this.ShowHideButtonContainer,'Visible','on')
                if this.Minimized
                    set(this.PanelContainer,'Visible','off')
                else
                    set(this.PanelContainer,'Visible','on')
                end
            else
                set(this.ShowHideButtonContainer,'Visible','off')
                set(this.PanelContainer,'Visible','off')
            end
        end
        
        %% addListeners
        function addListeners(this,L)
           this.Listeners = [this.Listeners; L];
        end
        
        %% getListeners
        function L = getListeners(this)
            L = this.Listeners;
        end
  
        
    end
end


%% Show/Hide Button callback
function localButtonCallback(es,ed,this) %#ok<INUSL>

% Change minimized state
this.Minimized = ~this.Minimized;

% Show or hide panel
if this.Minimized
    this.hidePanel;
else
    this.showPanel;
end

end

% destroy listener
function localDelete(this)
    delete(this);
end

