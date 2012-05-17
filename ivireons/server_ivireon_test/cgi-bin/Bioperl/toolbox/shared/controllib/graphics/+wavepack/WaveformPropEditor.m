classdef (Hidden = true) WaveformPropEditor < controllibutils.AbstractDelayedCallback 
   
%    Copyright 2008 The MathWorks, Inc.
%    $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:12:43 $

    properties
        Target
        TargetListeners
        JavaPeer
        Name
        LineColor
        LineStyle       
        LineWidth
        MarkerStyle
    end

    methods
        %% Constructor
        function this = WaveformPropEditor()
            this.buildPanel;

        end
        
        %% Used by property editor panel in plot tools
        function JavaPanel = initialize(this, TargetObjects)
            if iscell(TargetObjects)
                TargetObjects = [TargetObjects{:}];
            end
            % Revisit Unique
            this.setTarget(unique(TargetObjects)); 
            JavaPanel = this.JavaPeer.getPanel;
        end 

        %% Set the targeted waveforms to edit
        function setTarget(this,TargetObjects)
            % Set target for changes
            
            % RE: Should check data type of targetobjects
            this.removeTargetListeners
            this.Target = TargetObjects;
            this.installTargetListeners
            this.refreshPanel;
        end

        %% Install listeners to the target waveforms
        function installTargetListeners(this)
            % Install Listeners to target objects
            TargetObjects = this.Target;
            for ct = 1:length(TargetObjects)
                L = handle.listener(TargetObjects(ct),...
                    TargetObjects(ct).findprop('Name'),...
                    'PropertyPostSet',{@LocalRefreshName this});
                this.addTargetListener(L);
                L = handle.listener(TargetObjects(ct),...
                    TargetObjects(ct).findprop('Style'),...
                    'PropertyPostSet',{@LocalRefreshStyle this});
                this.addTargetListener(L);
            end

        end
        
        %% Remove listeners to the target waveforms
        function removeTargetListeners(this)
            % Remove Listeners to target objects
            if ~isempty(this.TargetListeners)
                delete(this.TargetListeners(ishandle(this.TargetListeners)))
                this.TargetListeners = [];
            end
        end

        %% Refresh the data in the edit panel
        function refreshPanel(this,Type)
            % Refresh Java Panel
            if nargin == 1
                % Revisit: update as one call
                this.refreshPanel('Name')
                this.refreshPanel('LineColor')
                this.refreshPanel('LineStyle')
                this.refreshPanel('LineWidth')
                this.refreshPanel('MarkerStyle')
            else
                switch Type
                    case 'Name'
                        Name = this.getName;
                        this.JavaPeer.setNameData(Name);
                    case 'LineColor'
                        Color = this.getLineColor;
                        if isempty(Color)
                            this.JavaPeer.setLineColorDataEmpty
                        else
                            this.JavaPeer.setLineColorData(java.awt.Color(Color(1),Color(2),Color(3)));
                        end
                    case 'LineStyle'
                        LineStyle = this.getLineStyle;
                        this.JavaPeer.setLineStyleData(LineStyle);
                    case 'LineWidth'
                        LineWidth = this.getLineWidth;
                        if isempty(LineWidth)
                            this.JavaPeer.setLineWidthData('');
                        else
                            % Make is show the text of an entry if one exists.
                            ComboValues = [0.5, 1.0, 2.0, 3.0, 4.0, 6.0, ...
                                8.0, 10.0, 15.0, 20.0, 25.0, 30.0];
                            ComboStrValues = {'0.5','1.0', '2.0', '3.0', '4.0', '6.0', ...
                                '8.0', '10.0', '15.0', '20.0', '25.0', '30.0'};
                            idx = find(LineWidth == ComboValues);
                            if isempty(idx)
                                this.JavaPeer.setLineWidthData(num2str(LineWidth));
                            else
                                this.JavaPeer.setLineWidthData(ComboStrValues{idx});
                            end
                        end
                    case 'MarkerStyle'
                        MarkerStyle = this.getMarkerStyle;
                        this.JavaPeer.setMarkerStyleData(MarkerStyle);
                end
            end

        end
        
        %% Get the line color for the targeted waveforms
        function LineColor = getLineColor(this)
            % Get Line Color from Target objects
            if isscalar(this.Target(1).Style.Colors)
                LineColor = this.Target(1).Style.Colors{1};
                for ct = 2:length(this.Target)
                    if ~isscalar(this.Target(ct).Style.Colors) || ...
                            ~isequal(LineColor,this.Target(ct).Style.Colors{1})
                        LineColor = [];
                        break
                    end
                end
            else
                LineColor = [];
            end
            this.LineColor = LineColor;
        end
        
        %% Get the line style for the targeted waveforms
        function LineStyle = getLineStyle(this)
            % Get Line Style from Target objects
            if isscalar(this.Target(1).Style.LineStyles)
                LineStyle = this.Target(1).Style.LineStyles{1};
                for ct = 2:length(this.Target)
                    if ~isscalar(this.Target(ct).Style.LineStyles) || ...
                            ~strcmp(LineStyle,this.Target(ct).Style.LineStyles{1})
                        LineStyle = '';
                        break
                    end
                end
            else
                LineStyle = '';
            end
            this.LineStyle = LineStyle;


        end
        
        
        %% Get the line width for the targeted waveforms
        function LineWidth = getLineWidth(this)
            
            if isscalar(this.Target(1).Style.LineWidth)
                LineWidth = this.Target(1).Style.LineWidth(1);
                for ct = 2:length(this.Target)
                    if ~isscalar(this.Target(ct).Style.LineWidth) || ...
                            ~isequal(LineWidth,this.Target(ct).Style.LineWidth(1))
                        LineWidth = [];
                        break
                    end
                end
            else
                LineWidth = [];
            end
            this.LineWidth = LineWidth;


        end
        
        %% Get the marker style for the targeted waveforms
        function MarkerStyle = getMarkerStyle(this)

            if isscalar(this.Target(1).Style.Markers)
                MarkerStyle = this.Target(1).Style.Markers{1};
                for ct = 2:length(this.Target)
                    if ~isscalar(this.Target(ct).Style.Markers) || ...
                            ~strcmp(MarkerStyle,this.Target(ct).Style.Markers{1})
                        MarkerStyle = '';
                        break
                    end
                end
            else
                MarkerStyle = '';
            end
            this.MarkerStyle = MarkerStyle;


        end
        
        %% Get the name for the targeted waveforms
        function Name = getName(this)
            % Get Name from Target objects
            Name = this.Target(1).Name;
            for ct = 2:length(this.Target)
                if ~strcmp(Name,this.Target(ct).Name)
                    Name = '';
                    break
                end
            end
            this.Name = Name;

        end
        
        
        %% Append a listener to the target listeners list
        function addTargetListener(this,L)
            % add Listener
            this.TargetListeners = [this.TargetListeners; L];

        end

        %% Build Prop edit panel
        function buildPanel(this)
            % Build panel
            this.JavaPeer = com.mathworks.toolbox.shared.controllib.propertyeditors.WaveformEditorPanelPeer;
            this.JavaPeer.createPanel;

            NameCallback = this.JavaPeer.getNameCallback;      
            this.addDelayedCallbackListener(NameCallback, {@LocalNameCallback this});
            LineColorCallback = this.JavaPeer.getLineColorCallback;
            this.addDelayedCallbackListener(LineColorCallback, {@LocalLineColorCallback this});
            LineStyleCallback = this.JavaPeer.getLineStyleCallback;
            this.addDelayedCallbackListener(LineStyleCallback, {@LocalLineStyleCallback this});
            LineWidthCallback = this.JavaPeer.getLineWidthCallback;
            this.addDelayedCallbackListener(LineWidthCallback, {@LocalLineWidthCallback this});
            MarkerStyleCallback = this.JavaPeer.getMarkerStyleCallback;
            this.addDelayedCallbackListener(MarkerStyleCallback, {@LocalMarkerStyleCallback this});

        end
              
    end


end


function LocalNameCallback(es,ed,this)
if ~isempty(ed)
    set(this.TargetListeners,'Enabled','off')
    for ct = 1:length(this.Target)
        this.Target(ct).Name = char(ed);
    end
    set(this.TargetListeners,'Enabled','on')
end
end

function LocalLineColorCallback(es,ed,this)
if ~isempty(ed)
    set(this.TargetListeners,'Enabled','off')
    for ct = 1:length(this.Target)
        this.Target(ct).setstyle('Color',[ed.getRed,ed.getGreen,ed.getBlue]/255)
    end
    set(this.TargetListeners,'Enabled','on')
end
end

function LocalLineStyleCallback(es,ed,this)
if ~isempty(ed)
    set(this.TargetListeners,'Enabled','off')
    for ct = 1:length(this.Target)
        this.Target(ct).setstyle('LineStyle',char(ed))
    end
    set(this.TargetListeners,'Enabled','on')
end
end

function LocalLineWidthCallback(es,ed,this)
if ~isempty(ed)
    set(this.TargetListeners,'Enabled','off')
    for ct = 1:length(this.Target)
        NewWidth = str2double(char(ed));
        if isnumeric(NewWidth) && isfinite(NewWidth)
            this.Target(ct).setstyle('LineWidth',str2double(char(ed)))
        else
            this.refreshPanel('LineWidth')
        end
    end
    set(this.TargetListeners,'Enabled','on')
end
end

function LocalMarkerStyleCallback(es,ed,this)
if ~isempty(ed)
    set(this.TargetListeners,'Enabled','off')
    for ct = 1:length(this.Target)
        this.Target(ct).setstyle('Marker',char(ed))
    end
    set(this.TargetListeners,'Enabled','on')
end
end


function LocalRefreshName(es,ed,this)
this.refreshPanel('Name');
end

function LocalRefreshStyle(es,ed,this)
    this.refreshPanel();
end

