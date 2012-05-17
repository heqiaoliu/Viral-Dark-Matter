classdef Plot < handle
    % Class PLOT plots data contained within the parent SDI object.
    %
    % Methods
    % -------
    % plotInspector(hAxes)
    %   - Iterates over all runs and checks for the "visible" flag of each
    %     signal.  Every visible signal is plotted in the same axis.
    %
    % plotSignals(hAxes, signals)
    %   - Plot an array of Simulink.sdi.Signal objects.  Each signal is plotted in
    %     hfig in the same axis.
    %
    % plotDiff(hAxes, diffSignal, tolSignal)
    %   - Plots a timeseries object representing the difference of two other
    %     timeseries objects, and plots the tolerance timeseries used in the
    %     difference.
    %
    % NOTE: Upon return from these methods, hfig will have callbacks assigned
    %       to manage panning and zooming for scalability.
    %
    % Copyright 2009-2010 The MathWorks, Inc.
    
    properties (Access = 'public')
        HFig;
        HAxes;
        HLine;
        HZoom;
        HPan;
        XData;
        YData;
        Quality; % Used to adjust the relation between datapoints and
        % available number of pixes. To have more datapoints
        % use a value 1/factor
        
        % NOTE: line() and stairs() are not directly interchangeable.
        % stairs() will clear the plot first of any previous plots, not good here.
        % Use the old style stairs() interface to get a paired list of points,
        % and use line() to create the handle.
        Interp = false;   % Turn this on to do interpolated (smooth) curves        
    end
    
    properties
        SDIEngine;
    end
    
    methods
        
        function this = Plot(SDIEngine)
            this.SDIEngine = SDIEngine;
            this.Quality   = 0.25;            
        end
        
        function plotInspector(this, hAxes, varargin)
            
            if nargin < 3
               isNormalized = false;
            else
                isNormalized = varargin{1};                
            end
            
            if nargin == 4
                interp = varargin{2};                
            else
                interp = false;
            end
            
            if( ~strcmp(get(hAxes,'Type'),'axes') )
                DAStudio.error('SDI:sdi:InvalidAxesHandle', num2str(hAxes) );
            end

            tsr = Simulink.sdi.SignalRepository;
            
            runCount = tsr.getRunCount;
            
            for i = 1 : runCount
                runID = tsr.getRunID(int32(i));
                sigCount = tsr.getSignalCount(runID);
                
                for j = 1 : sigCount
                    vis = tsr.getVisibility(runID, int32(j));
                    if(vis)
                        data      = tsr.getSignal(runID, int32(j));
                        dataToPlot = data.DataValues.Data;
                        if ~isvector(dataToPlot)
                            sz = size(dataToPlot);
                            if(max(sz) == numel(dataToPlot))
                                dataToPlot = reshape(dataToPlot, 1, max(sz));
                            end
                        end
                        if ~isreal(dataToPlot)
                            dataToPlot = real(dataToPlot);
                        end
                        
                        if isNormalized
                            dataToPlot = this.transformAndScale(dataToPlot,                     ...
                                                                min((double(dataToPlot))),   ...
                                                                max((double(dataToPlot))));                            
                        end
                        
                        if interp
                            hl = line(data.DataValues.Time, dataToPlot, 'Parent', hAxes);
                        else
                            hold(hAxes, 'on');
                            hl = stairs(data.DataValues.Time, dataToPlot, 'Parent', hAxes);
                            hold(hAxes, 'off');
                        end
                        set(hl, 'Color', data.LineColor);
                        set(hl, 'LineStyle', data.LineDashed);
                        set(hl, 'Parent', hAxes);
                        % Pass the handle to the Simulink.sdi.plot function to plot the signals.
                        %pObj = Simulink.sdi.Plot;
                        this.setupCallbacks(hl, hAxes);   
                    end
                end
            end
            
            yLim = get(hAxes, 'ylim');
            buffer = (yLim(2) - yLim(1))/50;
            yLim = [yLim(1)-buffer yLim(2)+buffer];
            
            % set new limits
            set(hAxes, 'ylim', yLim);
        end

        
        function plotSignals(this, hAxes, signals2PlotList, varargin)
            
            if nargin < 4
                isNormalized = false;
            else
                isNormalized = varargin{1};
            end
            
            if nargin == 5
                interp = varargin{2};                
            else
                interp = false;
            end
            
            if( ~strcmp(get(hAxes,'Type'),'axes') )
                DAStudio.error('SDI:sdi:InvalidAxesHandle', num2str(hAxes) );
            end
          
            % initialize min max
            xmin = inf;
            xmax = -inf;
          
            for i = 1 : length(signals2PlotList)
                data = signals2PlotList(i);
                
                if isempty(data.DataValues)
                    return;
                end
                
                dataToPlot = data.DataValues.Data;
                if ~isvector(dataToPlot)
                    sz = size(dataToPlot);
                    if(max(sz) == numel(dataToPlot))
                        dataToPlot = reshape(dataToPlot, 1, max(sz));
                    end
                end
                
                if ~isreal(dataToPlot)
                    dataToPlot = real(dataToPlot);
                end
                            
                if isNormalized
                    dataToPlot = this.transformAndScale(dataToPlot,               ...
                                                        min((double(dataToPlot))),...
                                                        max((double(dataToPlot))));    
                end
                
                if interp
                    hl = line(data.DataValues.Time, dataToPlot, 'Parent', hAxes);
                else
                    hold(hAxes, 'on');
                    hl = stairs(data.DataValues.Time, dataToPlot, 'Parent', hAxes);
                    hold(hAxes, 'off');
                end
                
                % get new min max
                xmin = min(xmin, min(data.DataValues.Time));
                xmax = max(xmax, max(data.DataValues.Time));

                set(hl, 'Color', data.LineColor);
                set(hl, 'LineStyle', data.LineDashed);
                set(hl, 'Parent', hAxes);
                
                % Pass the handle to the Simulink.sdi.plot function to plot the signals.                
                this.setupCallbacks(hl, hAxes);
            end % for
            
            % rescale the limits
            yLim = get(hAxes, 'ylim');
            buffer = (yLim(2) - yLim(1))/50;
            yLim = [yLim(1)-buffer yLim(2)+buffer];
            
            % set new limits
            set(hAxes, 'ylim', yLim);
            
            % set x limits
            xLim = get(hAxes, 'xlim');
            buffer = (xLim(2) - xLim(1))/50;
            xLim = [xmin-buffer xmax+buffer];
            set(hAxes, 'xlim', xLim);
        end
        
        function plotZeroDiff(this, hAxes, lhsID)
            tsr = Simulink.sdi.SignalRepository;
            data = tsr.getSignal(int32(lhsID));
            
            if isempty(data.DataValues)
                return;
            end
            
            sz = size(data.DataValues.Data);
            toPlot = zeros(sz);
            if ~isvector(toPlot)
                if(max(sz) == numel(toPlot))
                    toPlot = reshape(toPlot, 1, max(sz));
                end
            end
            xPlot = data.DataValues.Time;
            hLine = plot(hAxes, xPlot, toPlot); 
            
            if ~isempty(xPlot) && max(xPlot) > 0
                set(hAxes,'Xlim', [0 max(xPlot)], 'Ylim', [-1 1]);
            end
            strDict = Simulink.sdi.StringDict;
            set(hLine, 'Color', 'r'); 
            h = legend(hAxes, strDict.mgDifference);
            set(h,'Box', 'off');
        end
        
        function plotDiff(this, hAxes, Diff, Tol, varargin)
            
            if nargin < 5
                isNormalized = false;
            else
                isNormalized = varargin{1};
            end
            
            if nargin == 6
                interp = varargin{2};                
            else
                interp = false;
            end
            
            if( ~strcmp(get(hAxes,'Type'),'axes') )
                DAStudio.error('SDI:sdi:InvalidAxesHandle', num2str(hAxes) );
            end
            
            if ( ~isa(Diff, 'timeseries') )
                DAStudio.error('SDI:sdi:InvalidTimeSeriesObject', ...
                    '2nd or 3rd parameter');
            end            
            
            dataToPlot = abs(Diff.Data);            
            if ~isvector(dataToPlot)
                sz = size(dataToPlot);
                if(max(sz) == numel(dataToPlot))
                    dataToPlot = reshape(dataToPlot, 1, max(sz));
                end
            end
            
            if isNormalized
                dataToPlot = this.transformAndScale(dataToPlot,                  ...
                                                    min((double(dataToPlot))),   ...
                                                    max((double(dataToPlot))));
            end
            
            % Plot Difference
            if interp
                hLineDiff = line(Diff.Time, dataToPlot, 'Visible', 'off', 'Parent', hAxes);
            else
                hold(hAxes, 'on');
                hLineDiff = stairs(Diff.Time, dataToPlot, 'Parent', hAxes);
                hold(hAxes, 'off');
            end
            set(hLineDiff, 'Color', 'r');            
            set(hLineDiff, 'Parent', hAxes);
            
            if ~isempty(Diff.Time) && (Diff.Time(end) > Diff.Time(1))
                set(hAxes,'XLim', [Diff.Time(1), Diff.Time(end)]);
            end
            
            this.setupCallbacks(hLineDiff, hAxes);
            
            dataToPlot = abs(Tol.Data);
            if ~isvector(dataToPlot)
                sz = size(dataToPlot);
                if(max(sz) == numel(dataToPlot))
                    dataToPlot = reshape(dataToPlot, 1, max(sz));
                end
            end
            if isNormalized
                dataToPlot = this.transformAndScale(dataToPlot,                  ...
                                                    min((double(dataToPlot))),   ...
                                                    max((double(dataToPlot))));
            end
            % Plot tolerance
            if interp
                hLineDiff2 = line(Tol.Time, dataToPlot,'visible', 'off', 'Parent', hAxes);
            else
                hold(hAxes, 'on');
                hLineDiff2 = stairs(Tol.Time, dataToPlot, 'Parent', hAxes);
                hold(hAxes, 'off');
            end
            set(hLineDiff2, 'Color', 'g');
            set(hLineDiff2, 'LineStyle', ':');
            set(hLineDiff2, 'Parent', hAxes);
            
            if ~isempty(Tol.Time) && (Tol.Time(end) > Tol.Time(1))
                set(hAxes,'XLim', [Tol.Time(1), Tol.Time(end)]);
            end
            
            this.setupCallbacks(hLineDiff2, hAxes);
            
            % rescale axis limits
            yLim = get(hAxes, 'ylim');
            buffer = (yLim(2) - yLim(1))/50;
            yLim = [yLim(1)-buffer yLim(2)+buffer];
            
            % set new limits
            set(hAxes, 'ylim', yLim);
            
        end % function plotDiff
        
        
        function clearPlot(this)
            % If this method is call before creating the axis
            % it will create a new figure if the axis are empty
            if ~isempty(this.HAxes) && ishandle(this.HAxes)
                cla(this.HAxes, 'reset');
            end
        end % function clearPlot
        
        function value = get.Interp( this)
            value = this.Interp;
        end
        
        function set.Interp( this, value)
            this.Interp = value;
        end

    end % methods
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Helper functions
    
    methods (Hidden = true)
        
        function getQuality(this)
            this.Quality
        end
        
        % TODO check that a number is passed.
        function setQuality(this, value)
            this.Quality = value;
        end
        
        
        function setupCallbacks(this, hLine, hAxes)
            
            % Assign the handle to the line object (its an lineseries instance).
            this.HLine = hLine;
            
            % Store the original data.
            this.XData = get(this.HLine, 'XData')';
            this.YData = get(this.HLine, 'YData')';
            this.HAxes = hAxes;
            
            % Get the parent and grandparents of HAxes
            parent1 = get(this.HAxes, 'parent');
            parent1Type = get(parent1, 'Type');
            parent2 = get(parent1, 'parent');            
            parent3 = get(parent2, 'parent');
            parent3Type = get(parent3, 'Type');
            parent4 = get(parent3, 'parent');
            parent4Type = get(parent4, 'Type');
            parent5 = get(parent4, 'parent');
            parent5Type = get(parent5, 'Type');
            
            % Get the parent figure
            if strcmp( parent1Type , 'figure')
                this.HFig  = parent1;
            elseif strcmp(parent3Type, 'figure')
                this.HFig = parent3;
            elseif strcmp(parent4Type, 'figure')
                this.HFig = parent4;
            elseif strcmp(parent5Type, 'figure')
                this.HFig = parent5;
            else
                DAStudio.error('SDI:sdi:WrongFigureHandle')
            end
            
            % Set the ActionPostCallback for the zoom.
            % this.HZoom = zoom(this.HAxes)
            this.HZoom = zoom(this.HFig);
            set(this.HZoom,'ActionPostCallback', @this.plotHelperCallback);
            
            % Set the ActionPostCallback for the pan.
            %this.HPan = pan(fig);
            this.HPan = pan(this.HFig);
            set(this.HPan,'ActionPostCallback', @this.plotHelperCallback)
            
            % Plot the data
            this.plotHelperCallback(this.HFig, this.HAxes);
            
        end %  function plot
    end
    
    methods (Access =  'private')
        
        function retdata = transformAndScale(this, data, minVal, maxVal)
            if (sign(minVal) == -1 && sign(maxVal) == -1)
                maxVal1 = abs(minVal);
                minVal1 = abs(maxVal);               
            elseif(sign(minVal) == -1 && sign(maxVal) == 1)
                minVal1 = 0;
                maxVal1 = max(abs(minVal), abs(maxVal));
            elseif(sign(minVal) == -1 && sign(maxVal) == 0)
                minVal1 = 0;
                maxVal1 = max(abs(minVal), abs(maxVal));
            elseif(sign(minVal) == 1 && sign(maxVal) == 1)
                minVal1 = abs(minVal);
                maxVal1 = abs(maxVal);
            elseif(sign(minVal) == 0 && sign(maxVal) == 1)
                minVal1 = 0;
                maxVal1 = abs(maxVal);
            else
                maxVal1 = abs(maxVal);
                minVal1 = abs(minVal);
            end
                        
            maxVal = maxVal1;
            minVal = minVal1;
            if ((maxVal - minVal) < eps)
                if (maxVal < eps)
                    retdata = zeros(size(data));
                    return;
                end
                retdata = ones(size(data));
                return;
            end
            if ~islogical(data)
                retdata = (sign(data)).*(abs(data) - minVal)/(maxVal - minVal);
            else
                retdata = data;
            end
        end
        
        function plotHelperCallback(this, hFig, event_obj)%#ok
            
            % Get the axes limits first.
            %xLim = get(this.HAxes, 'XLim');
            try
                xLim = get(event_obj.Axes, 'XLim');
            catch ME %#ok
                xLim =  get(event_obj, 'XLim');
            end
            
            % Note: set visible will sets the xLim to 0-1, therefore calling it
            % after  xLim = get(this.HAxes,'XLim')
            
            % g647477. Don't do anything if it's not a valid handle
            if ~ishandle(this.HLine)
                return;
            end
            
            set(this.HLine, 'Visible', 'off');
            
            % Find the upper and lower indices that corresponds to the xLim.
            lXIdx = this.findCondIdx(this.XData, xLim(1));
            uXIdx = this.findCondIdx(this.XData, xLim(2));
            
            % Get the original range of data within the specified xLim.
            xPreData = this.XData(lXIdx:uXIdx);
            yPreData = this.YData(lXIdx:uXIdx);
            
            % Resample the data proportianal to the available pixels
            [xPostData yPostData] = this.reSample(xPreData, yPreData);
            
            % Plot the data.
            set(this.HLine,'XData', xPostData);
            set(this.HLine,'YData', yPostData);
            
            % After manipulating the data set visible "on".
            set(this.HLine,'Visible', 'on');
           
        end % function plotHelperCallback
        
        
        function [xData yData] = reSample(this, xInData, yInData)
            
            % Get pixels
            % getpixelposition returns:
            % [distance from left, distance from bottom, width, height]
            aPos    = getpixelposition(this.HAxes);
            dlength = length(xInData);
            
            % Calculate increment for resolution
            inc = floor( dlength / aPos(3) );
            inc = floor(inc * this.Quality);
            
            % Min increment = 1. Increment cannot be less than 1.
            inc = max(inc, 1);
            
            % Calculate list of booleans for each point of interest
            ti = false(1, dlength);
            for i = 1 : inc : dlength
                ti(i) = true;
            end
            
            % Resample the data
            xData = xInData(ti);
            yData = yInData(ti);
            
        end %function reSample
        
        % Function used to find the upper and lower indices that corresponds to
        % the xLim.
        % TODO change to binary search
        function i = findCondIdx(~, arr, cond)
            for i = 1 : length(arr)
                if(arr(i)>= cond)
                    return;
                end
            end
        end   
        
       
    end % methods private
    
end % classdef Plot
