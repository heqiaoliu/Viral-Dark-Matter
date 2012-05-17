classdef SPPlot < handle & sigutils.SaveLoad & sigutils.sorteddisp
    %SPPlot Construct a scatter plot plot manager object
    
    % Copyright 2008 The MathWorks, Inc.
    % $Revision: 1.1.6.2 $  $Date: 2009/01/05 17:45:17 $

    %===========================================================================
    % Public properties
    properties
        SymbolStyle = 'b.';
        SignalTrajectory = 'off';
        SignalTrajectoryStyle = 'c-';
        Constellation = 'off';
        ConstellationStyle = 'r+';
        Grid = 'on';
    end
    
    %===========================================================================
    % Private properties
    properties (Access = protected)
        SymbolHandle = -1;
        TrajectoryHandle = -1;
        ConstellationHandle = -1;
        ConstellationData = [NaN, NaN];
        SymbolData = [NaN, NaN];
        TrajectoryData = [NaN, NaN];
        GUI;
        MeasurementsObj;
        RefreshPlot;
    end
    
    %===========================================================================
    % Private/Transient properties
    properties (Access = private, Transient)
        Listeners;
    end
    
    %===========================================================================
    % Public Hidden methods
    methods (Hidden)
        function this = SPPlot(hParent, constellation, hMeasurements, refreshPlot)
            if nargin
                this.GUI = commscope.SPWidget(hParent, hMeasurements.Percentile);
                render(this)
                this.MeasurementsObj = hMeasurements;
                this.RefreshPlot = strncmpi(refreshPlot, 'on', 2);
                this.ConstellationData = constellation;
            else
                % This mode is used during load
                this.GUI = commscope.SPWidget(0, 0);
            end
        end
        %-----------------------------------------------------------------------
        function loadSPPlotObj(this, hPlot)
            this.SymbolStyle = hPlot.SymbolStyle;
            this.SignalTrajectory = hPlot.SignalTrajectory;
            this.SignalTrajectoryStyle = hPlot.SignalTrajectoryStyle;
            this.Constellation = hPlot.Constellation;
            this.ConstellationStyle = hPlot.ConstellationStyle;
            this.Grid = hPlot.Grid;
            this.SymbolData = hPlot.SymbolData;
            this.TrajectoryData = hPlot.TrajectoryData;
        end
        %-----------------------------------------------------------------------
        function update(this, ySym, yTraj)
            % Update scatter plot
            y = ySym(:);
            this.SymbolData = [real(y), imag(y)];
            
            % Update signal trajectory
            y = yTraj(:);
            this.TrajectoryData = [real(y), imag(y)];
            
            % Update measurements
            updateMeasurementValues(this.GUI, this.MeasurementsObj);
        end
        %-----------------------------------------------------------------------
        function reset(this)
            % Update scatter plot
            this.SymbolData = [NaN, NaN];
            
            % Update signal trajectory
            this.TrajectoryData = [NaN, NaN];
            
            % Adjust axis limits
            if isGUIRendered(this)
                autoScaleAxisLimits(this)
            end
            
            % Update measurements
            updateMeasurementValues(this.GUI, this.MeasurementsObj);
        end
        %-----------------------------------------------------------------------
        function plot(this)
            if ~isGUIRendered(this)
                render(this)
                % Update measurements
                updateMeasurementValues(this.GUI, this.MeasurementsObj);
            else
                updatePlot(this)
            end
        end
        %-----------------------------------------------------------------------
        function setContainer(this, hParent)
            setParent(this.GUI, hParent);
        end
        %-----------------------------------------------------------------------
        function setConstellationData(this, v)
            this.ConstellationData = v;
        end
        %-----------------------------------------------------------------------
        function setAxisLimits(this, limits)
            hAxis = get(this.TrajectoryHandle, 'Parent');
            axis(hAxis, [limits limits]);
        end
        %-----------------------------------------------------------------------
        function autoScaleAxisLimits(this)
            if isGUIRendered(this)
                % Determine the axis limits based on the constellation
                xData = get(this.ConstellationHandle, 'XData');
                yData = get(this.ConstellationHandle, 'YData');
                limits = max(max(abs(xData)), max(abs(yData)));
                limFact = 1.50;
                limits = limits * limFact;
                
                % If there is data, consider that too
                if strncmp(this.SignalTrajectory, 'on', 2)
                    xData = get(this.TrajectoryHandle, 'XData');
                    yData = get(this.TrajectoryHandle, 'YData');
                else
                    xData = get(this.SymbolHandle, 'XData');
                    yData = get(this.SymbolHandle, 'YData');
                end
                limitsData = max(max(abs(xData)), max(abs(yData)));
                
                limFact = 1.07;
                limitsData = limitsData * limFact;
                
                limits = max([limitsData limits]);
                
                dummy = 10^(ceil(log10(1/limits)) - 1);
                limits = ceil(limits / dummy) * dummy;
                
                if isnan(limits)
                    limits = 1;
                end
                
                hAxis = get(this.ConstellationHandle, 'Parent');
                axis(hAxis, [-limits limits -limits limits]);
            end
        end
        %-----------------------------------------------------------------------
        function unrenderGUI(this)
            unrender(this.GUI);
        end
        %-----------------------------------------------------------------------
        function updateRefreshPlot(this, v)
            % Update the RefreshPlot property of PlotSettings
            
            this.RefreshPlot = strncmpi(v, 'on', 2);
        end
    end
    
    %===========================================================================
    % Protected methods
    methods (Access = protected)
        function s = localSaveobj(this)
            % localSaveobj return a structure of protected data to be saved
            s.SymbolData = this.SymbolData;
            s.TrajectoryData = this.TrajectoryData;
        end
        %-----------------------------------------------------------------------
        function this = localLoadobj(this, s)
            % localLoadobj load protected or any other data
            this.SymbolData = s.SymbolData;
            this.TrajectoryData = s.TrajectoryData;
        end
    end
    
    %===========================================================================
    % Private methods
    methods (Access = private)
        function render(this)
            % Render the GUI widgets
            render(this.GUI, this);
            
            % Get the axis to plot scatter plot
            hAxis = getAxisHandle(this.GUI);
            
            % Create trajectory line
            data = this.TrajectoryData;
            this.TrajectoryHandle = ...
                plot(hAxis, ...
                data(:,1), data(:,2), this.SignalTrajectoryStyle, ...
                'Visible', this.SignalTrajectory, ...
                'Tag', 'TrajectoryData');
            
            % Create symbols line
            data = this.SymbolData;
            this.SymbolHandle = ...
                plot(hAxis, ...
                data(:,1), data(:,2), this.SymbolStyle, ...
                'Tag', 'SymbolData');
            
            % Create constellation line
            data = this.ConstellationData;
            this.ConstellationHandle = ...
                plot(hAxis, ...
                data(:,1), data(:,2), this.ConstellationStyle, ...
                'Visible', this.Constellation, ...
                'Tag', 'ConstellationData');
            
            % Protect the axis (Not sure about this)
            set(ancestor(hAxis, 'figure'), 'NextPlot', 'new');
            set(hAxis, 'NextPlot', 'new');
            
            % Set the grid
            grid(hAxis, this.Grid);
            
            % Adjust axis limits
            autoScaleAxisLimits(this);
        end
        %-----------------------------------------------------------------------
        function updatePlot(this)
            % Update constellation line
            v = this.ConstellationData;
            set(this.ConstellationHandle, 'XData', v(:,1), 'YData', v(:,2))
            % Update symbol line
            v = this.SymbolData;
            set(this.SymbolHandle, 'XData', v(:,1), 'YData', v(:,2))
            % Update trajectory line
            v = this.TrajectoryData;
            set(this.TrajectoryHandle, 'XData', v(:,1), 'YData', v(:,2))
        end
        %-----------------------------------------------------------------------
        function flag = isGUIRendered(this)
            flag = isRendered(this.GUI);
        end
    end
    
    %===========================================================================
    % Set/Get methods
    methods
        function set.ConstellationData(this, constellation)
            v = constellation(:);
            v = [real(v), imag(v)];
            if isGUIRendered(this) && this.RefreshPlot
                set(this.ConstellationHandle, 'XData', v(:,1), 'YData', v(:,2))
            end
            this.ConstellationData = v;
            % Adjust axis limits
            autoScaleAxisLimits(this);
        end
        %-----------------------------------------------------------------------
        function set.SymbolData(this, v)
            if isGUIRendered(this) && this.RefreshPlot
                set(this.SymbolHandle, 'XData', v(:,1), 'YData', v(:,2))
            end
            this.SymbolData = v;
        end
        %-----------------------------------------------------------------------
        function set.TrajectoryData(this, v)
            if isGUIRendered(this) && this.RefreshPlot
                set(this.TrajectoryHandle, 'XData', v(:,1), 'YData', v(:,2))
            end
            this.TrajectoryData = v;
        end
        %-----------------------------------------------------------------------
        function set.SignalTrajectory(this, v)
            validatestring(v, {'on', 'off'}, ...
                '',...%commscope.ScatterPlot.SignalTrajectory', ...
                'SignalTrajectory property of class commscope.ScatterPlot');

            if isGUIRendered(this)
                set(this.TrajectoryHandle, 'Visible', v)
            end
            this.SignalTrajectory = v;
            if strcmp(v, 'on')
                showTrajectory(this.GUI)
            else
                hideTrajectory(this.GUI)
            end
        end
        %-----------------------------------------------------------------------
        function set.Constellation(this, v)
            validatestring(v, {'on', 'off'}, ...
                '',...%commscope.ScatterPlot.Constellation', ...
                'Constellation property of class commscope.ScatterPlot');
                
            if isGUIRendered(this)
                set(this.ConstellationHandle, 'Visible', v)
            end
            this.Constellation = v;
            if strcmp(v, 'on')
                showConstellation(this.GUI)
            else
                hideConstellation(this.GUI)
            end
        end
        %-----------------------------------------------------------------------
        function set.Grid(this, v)
            validatestring(v, {'on', 'off'}, ...
                '',...%commscope.ScatterPlot.Grid', ...
                'Grid property of class commscope.ScatterPlot');

            if isGUIRendered(this)
                % Get the axis handle
                hAxis = getAxisHandle(this.GUI);
                
                % Set the grid
                grid(hAxis, v);
            end
            
            % Set the property
            this.Grid = v;

            % Update the GUI
            if strcmp(v, 'on')
                showGrid(this.GUI)
            else
                hideGrid(this.GUI)
            end
        end
        %-----------------------------------------------------------------------
        function set.ConstellationStyle(this, v)
            if isGUIRendered(this)
                setStyle(this.ConstellationHandle, v);
            end
            this.ConstellationStyle = v;
        end
        %-----------------------------------------------------------------------
        function set.SymbolStyle(this, v)
            if isGUIRendered(this)
                setStyle(this.SymbolHandle, v);
            end
            this.SymbolStyle = v;
        end
        %-----------------------------------------------------------------------
        function set.SignalTrajectoryStyle(this, v)
            if isGUIRendered(this)
                setStyle(this.TrajectoryHandle, v);
            end
            this.SignalTrajectoryStyle = v;
        end
        %-----------------------------------------------------------------------
        function set.MeasurementsObj(this, v)
            updatePercentile(this.GUI,v.Percentile);
            this.Listeners = addlistener(v,'Percentile','PostSet',...
                @(src,evnt)updateMeasurementsTable(this.GUI,v));
            this.MeasurementsObj = v;
        end
    end
end

%===============================================================================
% Helper functions
function setStyle(h, s)
% Parse style using plot
hAxes = get(h, 'Parent');
hTemp = plot(hAxes, 1:10, s, 'Visible', 'off');
% Now set
set(h, 'Marker', get(hTemp, 'Marker'))
set(h, 'Color', get(hTemp, 'Color'))
set(h, 'LineStyle', get(hTemp, 'LineStyle'))
end

% [EOF]
