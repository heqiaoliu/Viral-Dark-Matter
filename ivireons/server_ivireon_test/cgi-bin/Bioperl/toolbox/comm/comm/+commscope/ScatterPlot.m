classdef ScatterPlot < commscope.AbstractScope & sigutils.pvpairs ...
        & sigutils.SaveLoad & sigutils.sorteddisp
%ScatterPlot Generate a scatter plot.
%   H = commscope.ScatterPlot returns a scatter plot scope H.  Scatter plot
%   scope can be used to view the scatter plot of a signal.
%
%   H = commscope.ScatterPlot('PropertyName',PropertyValue,...) returns a
%   scatter plot scope H, with property values set to PropertyValues.  See 
%   properties list below for valid PropertyNames.
%
%   commscope.ScatterPlot methods:
%       autoscale  - Autoscale the axes
%       close      - Close the scatter plot figure
%       copy       - Create a copy of the scatter plot scope
%       disp       - Display the properties of the scatter plot scope
%       plot       - Plot the scatter plot
%       reset      - Reset the scatter plot scope
%       update     - Update the scatter plot with new data
%
%   commscope.ScatterPlot properties:
%       Type              - 'Scatter Plot'. This is a read-only property.
%       SamplingFrequency - Sampling frequency of the input signal in Hz.
%       SamplesPerSymbol  - Number of samples used to represent a symbol.
%       SymbolRate        - The symbol rate of the input signal. This property  
%                           is read-only and is automatically computed based
%                           on SamplingFrequency and SamplesPerSymbol.
%       MeasurementDelay  - The time in seconds the scope will wait before
%                           starting to collect data.  
%       SamplingOffset    - The number of samples skipped at each sampling point
%                           relative to the MeasurementDelay.   
%       Constellation     - Expected constellation of the input signal.
%       RefreshPlot       - The switch that controls the plot refresh style.
%                           The choices are:
%                           'on'  - The scatter plot is refreshed every time
%                                   the update method is called.
%                           'off' - The scatter plot is not refreshed when 
%                                   the update method is called. 
%       SamplesProcessed  - The number of samples processed by the scope.  This
%                           value does not include the discarded samples during
%                           the MeasurementDelay period.  This property is
%                           read-only.  
%       PlotSettings      - Plot settings that control the scatter plot figure.  
%
%   Example:
%       hMod = modem.qammod('M', 16);       % Create a 16-QAM modulator object
%       % Create a normalized upsampling filter
%       hFilDesign = fdesign.pulseshaping(8,'Raised Cosine','Nsym,Beta',8,0.50);
%       hFil = design(hFilDesign); 
%       hFil.Numerator = hFil.Numerator / max(hFil.Numerator);
%       hScope = commscope.ScatterPlot;     % Create a scatter plot scope
%       hScope.Constellation = hMod.Constellation;
%       hScope.MeasurementDelay = 4/hScope.SymbolRate;
%       d = randi([0 15], 100, 1);          % Generate data symbols
%       sym = modulate(hMod, d);            % Generate modulated symbols
%       xmt = filter(hFil, upsample(sym, hScope.SamplesPerSymbol));
%       rcv = awgn(xmt, 30, 'measured');    % Add AWGN
%       update(hScope, rcv)                 % Update scope
%
%   See also commscope.eyediagram, commmeasure. 
    
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.6.3 $  $Date: 2009/01/05 17:45:20 $

    %===========================================================================
    % Public Read-Only properties
    properties (SetAccess = protected)
        % Type of the scope.  This is a read-only property.
        Type = 'Scatter Plot';
        % Plot settings control the scatter plot figure.  Line styles can be any
        % valid MATLAB plot line style.  The  following properties can be set: 
        %
        % 	SymbolStyle           - Line style of symbols
        %	SignalTrajectory      - The switch to control the visibility of the
        %                           signal trajectory.  The choices are 'on' or
        %                           'off'. 
        %	SignalTrajectoryStyle - Line style of signal trajectory
        %   Constellation         - The switch to control the visibility of the
        %                           constellation points.  The choices are 'on'
        %                           or 'off'. 
        %	ConstellationStyle    - Line style of signal trajectory
        %	Grid                  - The switch to control the visibility of the
        %                           grid. The choices are 'on' or 'off'. 
        PlotSettings;
    end
    
    %===========================================================================
    % Public properties
    properties
        % Expected constellation of the input signal.  
        Constellation = [1 i -1 -i];
    end
    
    %===========================================================================
    % Private properties
    properties (Access = protected)
        StartOffset
        Delay
        %Measurement settings and results.  
        %
        %	Percentile    - Percentile value to calculate PercentileEVM and
        %                   PercentileMER. 
        %	RMSEVM        - RMS EVM measurement result.  This is read-only.
        %	MaximumEVM    - Maximum EVM measurement result. This is read-only.
        %	PercentileEVM - Percentile EVM measurement result. This is read-only.
        %	MERdB         - MER measurement result (in dB). This is read-only.
        %	MinimumMER    - Minimum MER measurement result (in dB).  This is
        %                   read-only. 
        %	PercentileMER - Percentile MER measurement result (in dB).  This is
        %                   read-only. 
        Measurements;
    end
    
    %===========================================================================
    % Public methods
    methods
        function this = ScatterPlot(varargin)
            this.Measurements = commscope.SPMeasurements;
            createScatterPlotFigure(this);
            this.SamplesPerSymbol = 8;
            this.SamplingFrequency = 8000;
            this.StartOffset = this.SamplingOffset;

            if nargin
                % There are input arguments, so initialize with property-value
                % pairs.
                initPropValuePairs(this, varargin{:});
            end
        end
        %-----------------------------------------------------------------------
        function update(this, varargin)
            %UPDATE Update the scope data
            %   UPDATE(H, X) updates the collected data of the scope H with the
            %   input X.  If the RefreshPlot property is set to 'on', the UPDATE
            %   method also refreshes the scope figure.  
            %
            %   See also commscope.ScatterPlot, commscope.ScatterPlot/plot,
            %   commscope.ScatterPlot/reset, commscope.ScatterPlot/close,
            %   commscope.ScatterPlot/copy, commscope.ScatterPlot/disp, 
            %   commscope.ScatterPlot/autoscale.
            
            update@commscope.AbstractScope(this, varargin{:})
        end
        %-----------------------------------------------------------------------
        function varargout = plot(this)
            %PLOT  Display the scatter plot figure
            %   PLOT(H) displays the figure of the scatter plot scope H.  If a
            %   figure already exists, it is brought to the foreground.
            %   Otherwise, a new figure is created with the existing data.
            %
            %   See also commscope.ScatterPlot, commscope.ScatterPlot/update,
            %   commscope.ScatterPlot/reset, commscope.ScatterPlot/close,
            %   commscope.ScatterPlot/copy, commscope.ScatterPlot/disp, 
            %   commscope.ScatterPlot/autoscale.
            
            
            if ~ishghandle(this.ContainerHandle)
                hFig = createScatterPlotFigure(this);
            else
                hFig = ancestor(this.ContainerHandle, 'figure');
                plot(this.PlotSettings)
                figure(hFig)
            end
            
            if nargout
                varargout{1} = hFig;
            end
        end
        %-----------------------------------------------------------------------
        function reset(this)
            %RESET  Reset the scatter plot scope
            %   RESET(H) resets the scatter plot scope H.  Resetting H clears
            %   all the collected data.
            %
            %   See also commscope.ScatterPlot, commscope.ScatterPlot/update,
            %   commscope.ScatterPlot/plot, commscope.ScatterPlot/close,
            %   commscope.ScatterPlot/copy, commscope.ScatterPlot/disp, 
            %   commscope.ScatterPlot/autoscale.

            if ~this.IsLoading_
                reset(this.Measurements)
                reset(this.PlotSettings)
                this.StartOffset = this.SamplingOffset;
                this.SamplesProcessed = 0;
            end
        end
        %-----------------------------------------------------------------------
        function h = copy(this)
            %COPY   Create a copy of the scatter plot scope
            %   H = COPY(REF_OBJ) creates a new scatter plot scope H and copies
            %   the properties of H from properties of REF_OBJ.  
            %
            %   See also commscope.ScatterPlot, commscope.ScatterPlot/update,
            %   commscope.ScatterPlot/plot, commscope.ScatterPlot/close,
            %   commscope.ScatterPlot/reset, commscope.ScatterPlot/disp, 
            %   commscope.ScatterPlot/autoscale.

            h = sigutils.SaveLoad.loadobj(saveobj(this));
        end
        %-----------------------------------------------------------------------
        function autoscale(this)
            %AUTOSCALE Auroscale the scatter plot axes
            %   AUTOSCALE(H) sets the scatter plot axes to fit displayed
            %   data and expected constellation points.
            %
            %   See also commscope.ScatterPlot, commscope.ScatterPlot/update,
            %   commscope.ScatterPlot/plot, commscope.ScatterPlot/close,
            %   commscope.ScatterPlot/reset, commscope.ScatterPlot/disp.

            autoScaleAxisLimits(this.PlotSettings)
        end
    end
    
    %===========================================================================
    % Protected methods
    methods (Access = protected)
        function updateData(this, startIdx, rcv, xmt)
            
            sps = this.SamplesPerSymbol;
            sampStartIdx = startIdx+this.StartOffset;
            rcvSym = rcv(sampStartIdx:sps:end);

            if 0 && (nargin==4)
                % Disabled feature
                xmtSym = xmt(sampStartIdx:sps:end); 
                update(this.Measurements, rcvSym, xmtSym);
            end
            
            if strncmpi(this.RefreshPlot, 'on', 2)
                plot(this);
            end
            if this.RefreshPlotTurnedOn
                reset(this.PlotSettings);
            end
            update(this.PlotSettings, rcvSym, rcv(startIdx:end))
            
            L = length(rcv) - sampStartIdx + 1;
            this.StartOffset = mod(sps - mod(L, sps), sps);
        end
        %-----------------------------------------------------------------------
        function s = localSaveobj(this)
            % localSaveobj return a structure of protected data to be saved

            mc = metaclass(this);
            props = mc.Properties;
            
            % Add all protected properties
            s = struct;
            for p=1:length(props)
                pr = props{p};
                if ((strcmp(pr.SetAccess, 'protected') ...
                        || strcmp(pr.GetAccess, 'protected'))) && ...
                        ~pr.Transient
                    s.(pr.Name) = this.(pr.Name);
                end
            end
        end
        %-----------------------------------------------------------------------
        function this = localLoadobj(this, s)
            % localLoadobj load protected or any other data
            
            % Save PlotSettings for later
            hPlotSettings = s.PlotSettings;
            s = rmfield(s, 'PlotSettings');
            
            % Copy the rest of the fields
            props = fieldnames(s);
            for p=1:length(props)
                set(this, props{p}, s.(props{p}));
            end
            
            % Now upadte PlotSettings
            loadSPPlotObj(this.PlotSettings, hPlotSettings);
        end
        %-----------------------------------------------------------------------
        function sortedList = getSortedPropDispList(this) %#ok<MANU>
            % GETSORTEDPROPINITLIST returns a list of properties in the order in
            % which the properties must be initialized.
            
            sortedList = {...
                'Type', ...
                'SamplingFrequency', ...
                'SamplesPerSymbol'...
                'SymbolRate', ...
                'MeasurementDelay', ...
                'SamplingOffset', ...
                'Constellation', ...
                'SamplesProcessed', ...
                'RefreshPlot', ...
                'PlotSettings', ...
                };
        end
        %-----------------------------------------------------------------------
        function updateRefreshPlot(this, v)
            % Update the RefreshPlot property of PlotSettings
            
            updateRefreshPlot(this.PlotSettings, v)
        end
    end
    
    %===========================================================================
    % Private methods
    methods (Access = private)
        function hFig = createScatterPlotFigure(this)
            % Create the scatter plot figure. An alternative is to just create
            % the container.
            hFig = createFigure(this, 420, 550);
            createContainer(this, hFig);
            if isobject(this.PlotSettings)
                setContainer(this.PlotSettings, this.ContainerHandle);
                plot(this.PlotSettings);
            else
                this.PlotSettings = ...
                    commscope.SPPlot(this.ContainerHandle, ...
                    this.Constellation, ...
                    this.Measurements, ...
                    this.RefreshPlot);
            end
            
            % Make figure visible
            set(hFig, 'Visible', 'on')
        end
    end
    
    %===========================================================================
    % Protected methods
    methods (Access = protected)
        function figureClosedAction(this)
            unrenderGUI(this.PlotSettings)
        end
    end
    
    %===========================================================================
    % Set/Get methods
    methods
        function set.Constellation(this, v)
            setConstellationData(this.PlotSettings, v);
            this.Constellation = v;
        end
    end
end
