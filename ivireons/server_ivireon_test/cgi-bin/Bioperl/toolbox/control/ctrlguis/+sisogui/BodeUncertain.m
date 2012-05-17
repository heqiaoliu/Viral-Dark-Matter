classdef BodeUncertain < handle
    % @BodeUncertain class definition
    
    %   Copyright 1986-2010 The MathWorks, Inc.
    %	 $Revision: 1.1.8.4 $  $Date: 2010/05/10 16:58:48 $
    properties (SetObservable)
        Parent
        
        %% States
        Visible
        UncertainType = 'Systems'; % Bounds, Systems
        ZLevel = -5.5;
        
                
        %% Data
        Frequency  % size n
        Magnitude  % size n x m  abs
        Phase      % size n x m  deg
        
        %
        
        %% Patch Info
        MagPatch
        PhasePatch
        FaceColor = [0.9804 .9*0.9804 0.8235];
        MagUpperLine
        MagLowerLine
        
        %% Lines Info
        MagLines
        PhaseLines
        LineColor = [0.9804 .9*0.9804 0.8235];
    end
    
    methods
        %%
        function this = BodeUncertain(Parent)
            % Constructor
            this.Parent = Parent;
            
        end
        
        function set.UncertainType(this,value)
            this.UncertainType = value;
            draw(this);
        end
        
        function set.Visible(this,value)
            this.Visible = value;
            draw(this);
        end
        
        %%
        function setData(this,mag,phase,w)
            this.Frequency = w(:);
            this.Magnitude = mag;
            this.Phase = phase;
            this.draw;
        end
        
        %%
        function setZLevel(this,ZLevel)
            this.ZLevel = ZLevel;
        end
        
        %%
        function draw(this)
            if isempty(this.MagPatch)
                BodeAxes = this.Parent.Axes.getaxes;
                this.MagPatch = patch(nan,nan,this.ZLevel,'Parent', BodeAxes(1),'FaceColor',this.FaceColor,'EdgeColor',this.FaceColor,'HitTest','off');
                this.PhasePatch = patch(nan,nan,this.ZLevel,'Parent', BodeAxes(2),'FaceColor',this.FaceColor,'EdgeColor',this.FaceColor,'HitTest','off');
                this.MagLines = line(nan,nan,this.ZLevel,'Parent', BodeAxes(1),'Color',this.LineColor,'XlimInclude','off');
                this.PhaseLines = line(nan,nan,this.ZLevel,'Parent', BodeAxes(2),'Color',this.LineColor,'XlimInclude','off');
            end
            
            
            if isVisible(this)
                if strcmpi(this.UncertainType,'Bounds')
                    set(this.MagLines,'visible','off')
                    set(this.PhaseLines,'visible','off')
                    set(this.MagPatch,'visible','on')
                    set(this.PhasePatch,'visible','on')
                    % what about nans or infs in response?
                    Frequency = this.Frequency;
                    MagUpper = max(this.Magnitude,[],2);
                    MagLower = min(this.Magnitude,[],2);
                    PhaseUpper = max(this.Phase,[],2);
                    PhaseLower = min(this.Phase,[],2);
                    
                    % Use the editors focus for drawing
                    XFocus = getfocus(this.Parent);
                    if isempty(XFocus)
                        InFocus = 1:length(this.Frequency);
                    else
                        InFocus = find(this.Frequency >= XFocus(1) & this.Frequency <= XFocus(2));
                    end
                    
                    Frequency = Frequency(InFocus);
                    MagUpper = MagUpper(InFocus);
                    MagLower = MagLower(InFocus);
                    PhaseUpper = PhaseUpper(InFocus);
                    PhaseLower = PhaseLower(InFocus);
                    
                    
                    FreqVect = [Frequency;Frequency(end:-1:1)];
                    zdata = this.ZLevel * ones(size(FreqVect));
                    % Dont forget to convert units
                    set(this.MagPatch,'YData', unitconv([MagUpper;MagLower(end:-1:1)],'abs',this.Parent.Axes.YUnits{1}),...
                        'XData', FreqVect,'ZData',zdata);
                    set(this.PhasePatch,'YData', unitconv([PhaseUpper;PhaseLower(end:-1:1)],'deg',this.Parent.Axes.YUnits{2}),...
                        'XData', FreqVect,'ZData',zdata)
                else
                    set(this.MagLines,'visible','on')
                    set(this.PhaseLines,'visible','on')
                    set(this.MagPatch,'visible','off')
                    set(this.PhasePatch,'visible','off')
                    
                    % Use the editors focus for drawing
                    XFocus = getfocus(this.Parent);
                    if isempty(XFocus)
                        InFocus = 1:length(this.Frequency);
                    else
                        InFocus = find(this.Frequency >= XFocus(1) & this.Frequency <= XFocus(2));
                    end
                    
                    Magdata = [];
                    Phasedata = [];
                    Freqdata = [];
                    for ct = 1:size(this.Magnitude,2)
                        Magdata = [Magdata; this.Magnitude(InFocus,ct);NaN];
                        Phasedata = [Phasedata; this.Phase(InFocus,ct);NaN];
                        Freqdata = [Freqdata; this.Frequency(InFocus);NaN]; 
                    end
                    zdata = this.ZLevel * ones(size(Freqdata));
                    set(this.MagLines,'YData', unitconv(Magdata,'abs',this.Parent.Axes.YUnits{1}),...
                        'XData', Freqdata,'ZData', zdata);
                    set(this.PhaseLines,'YData', unitconv(Phasedata,'deg',this.Parent.Axes.YUnits{2}),...
                        'XData', Freqdata,'ZData', zdata);
                end
            else
                set(this.MagLines,'visible','off')
                set(this.PhaseLines,'visible','off')
                set(this.MagPatch,'visible','off')
                set(this.PhasePatch,'visible','off')
            end
        end
            
        function b = isVisible(this,Type)
            if strcmpi(this.Visible,'on')
                if nargin == 1
                    b = true;
                else
                    if strcmpi(Type,this.UncertainType)
                        b = true;
                    else
                        b = false;
                    end
                end
            else
                b = false;
            end
        end
        
        function setColor(this,Color)
            hsvcolor = rgb2hsv(Color);
            Color = hsv2rgb(hsvcolor+[0,-.8,0]);
            this.FaceColor = Color;
            this.LineColor = Color;
            if ~isempty(this.MagPatch)
                set(this.MagPatch,'EdgeColor',this.FaceColor,'FaceColor',this.FaceColor)
                set(this.PhasePatch,'EdgeColor',this.FaceColor,'FaceColor',this.FaceColor)
            end
            if ~isempty(this.MagLines)
                set(this.MagLines,'Color',this.FaceColor)
                set(this.PhaseLines,'Color',this.FaceColor)
            end
            
            
        end
        
        
    end
    
    
    methods (Access = private)
        
        %%
        
        
    end
end
