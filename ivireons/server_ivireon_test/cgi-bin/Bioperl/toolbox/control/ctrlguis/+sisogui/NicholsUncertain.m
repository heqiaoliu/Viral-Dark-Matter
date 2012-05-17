classdef NicholsUncertain < handle
    % @NicholsUncertain class definition
    
    %   Copyright 1986-2010 The MathWorks, Inc.
    %	 $Revision: 1.1.8.2 $  $Date: 2010/04/30 00:36:27 $
    properties (SetObservable)
        Parent     % Axesgroup
        Visible
        UncertainType = 'Systems'; % Bounds, Systems
        Frequency  % size n 
        Magnitude  % size n x m  abs
        Phase      % size n x m  deg
        PhaseUpper % size 1 x m
        PhaseLower % size 1 x m
        MagUpper   % size 1 x m
        MagLower   % size 1 x m
        UncertainPatch
        UncertainLines
        ZLevel = -25.5;
        FaceColor = [0.9804 .9*0.9804 0.8235];
    end
    
    methods
        %%
        function this = NicholsUncertain(Parent)
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
            this.Frequency = w;
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
            if isempty(this.UncertainPatch)
                NicholsAxes = getAxes(this);
                this.UncertainPatch = patch(nan,nan,this.ZLevel,'Parent',NicholsAxes, ...
                    'FaceColor',this.FaceColor,'EdgeColor',this.FaceColor);
                this.UncertainLines = line(nan,nan,this.ZLevel,'Parent', NicholsAxes,'Color',this.FaceColor);
                
            end
            if isVisible(this)
                if strcmpi(this.UncertainType,'Bounds')
                    set(this.UncertainLines,'visible','off')
                    set(this.UncertainPatch,'visible','on')
                    computeBounds(this)
                    [xdata,ydata,zdata] = computePatchFaces4(this);
                    
                    % Dont forget to convert units
                    set(this.UncertainPatch,'YData', unitconv(ydata,'abs','db'),...
                        'XData', unitconv(xdata,'deg',this.Parent.Axes.XUnits),'ZData',zdata);
                else
                    set(this.UncertainLines,'visible','on')
                    set(this.UncertainPatch,'visible','off')
                    Magdata = [];
                    Phasedata = [];
                    Freqdata = [];
                    for ct = 1:size(this.Magnitude,2)
                        Magdata = [Magdata; this.Magnitude(:,ct);NaN];
                        Phasedata = [Phasedata; this.Phase(:,ct);NaN];
                        
                    end
                    set(this.UncertainLines,'YData', unitconv(Magdata,'abs','db'),...
                        'XData', unitconv(Phasedata,'deg',this.Parent.Axes.XUnits),'ZData', this.ZLevel * ones(size(Phasedata)));
                end
            else
                set(this.UncertainLines,'visible','off')
                set(this.UncertainPatch,'visible','off')
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
            if ~isempty(this.UncertainPatch)
                set(this.UncertainPatch,'EdgeColor',this.FaceColor,'FaceColor',this.FaceColor)
            end
            if ~isempty(this.UncertainLines)
                set(this.UncertainLines,'Color',this.FaceColor)

            end
    
    
        end
    end
    
    
    
    methods (Access = private)
        
        function computeBounds(this)
            % what about nans or infs in response?
            this.MagUpper = max(this.Magnitude,[],2);
            this.MagLower = min(this.Magnitude,[],2);
            this.PhaseUpper = max(this.Phase,[],2);
            this.PhaseLower = min(this.Phase,[],2);
        end
        
        function PlotAx = getAxes(this)
            PlotAx = this.Parent.Axes.getaxes;
        end
        
        function computePatchFaces(this)
            % at most six points
            w = length(maglow);
            verts = [];
            for ct = 1:w;
                verts = [verts; [phaselow(ct),maglow(ct)]; [phaselow(ct),maghigh(ct)]; [phasehigh(ct),maghigh(ct)]; [phasehigh(ct), maglow(ct)]];
            end
            
            faces = [];
            
            for ct = 1:w-1;
                idx = (ct-1)*4+1:4*(ct+1);
                k = convhull(verts(idx,1),verts(idx,2));
                faces = [faces;  [idx(k),nan(1,8-length(k))]];
            end
            
        end
        
        function [xdata,ydata,zdata] = computePatchFaces2(this)
            PL = this.PhaseLower;
            PH = this.PhaseUpper;
            ML = this.MagLower;
            MH = this.MagUpper;
            numFaces = length(this.Frequency)-1;
            xdata = nan(8,numFaces);
            ydata = nan(8,numFaces);
            zdata = this.ZLevel*ones(6,numFaces);
            for ct = 1:numFaces
                Verts = [...
                    PL(ct),ML(ct); ...
                    PL(ct),MH(ct); ...
                    PH(ct),MH(ct); ...
                    PH(ct), ML(ct); ...
                    PL(ct+1),ML(ct+1); ...
                    PL(ct+1),MH(ct+1); ...
                    PH(ct+1),MH(ct+1); ...
                    PH(ct+1), ML(ct+1)];
                
                k = convhull(Verts(:,1),Verts(:,2));
                xdata(:,ct) = [Verts(k,1);repmat(Verts(k(end),1),8-length(k),1)];
                ydata(:,ct) = [Verts(k,2);repmat(Verts(k(end),2),8-length(k),1)];
                
                
            end
            
        end
        
        function [xdata,ydata,zdata] = computePatchFaces3(this)
            PL = this.PhaseLower;
            PH = this.PhaseUpper;
            ML = this.MagLower;
            MH = this.MagUpper;
            numFaces = length(this.Frequency);
            xdata = nan(4,numFaces);
            ydata = nan(4,numFaces);
            zdata = this.ZLevel*ones(6,numFaces);
            for ct = 1:numFaces
                Verts = [...
                    PL(ct),ML(ct); ...
                    PL(ct),MH(ct); ...
                    PH(ct),MH(ct); ...
                    PH(ct), ML(ct)];

                xdata(:,ct) = Verts(:,1);
                ydata(:,ct) = Verts(:,2);
                
                
            end
            
        end
        
        
        function [xdata,ydata,zdata] = computePatchFaces4(this)
            numFaces = length(this.Frequency);
            maxPoints = size(this.Magnitude,2);
            xdata = nan(maxPoints,numFaces);
            ydata = nan(maxPoints,numFaces);
            zdata = this.ZLevel*ones(maxPoints,numFaces);
            for ct = 1:numFaces
                try
                k = convhull(this.Phase(ct,:),this.Magnitude(ct,:));
                xdata(:,ct) = [this.Phase(ct,k)'; repmat(this.Phase(ct,k(end)),maxPoints-length(k),1)];
                ydata(:,ct) = [this.Magnitude(ct,k)'; repmat(this.Magnitude(ct,k(end)),maxPoints-length(k),1)];
                catch
                    
                end
                
                
            end
            
        end
        
        
    end
end

%--------------------------------------------------------------------------


