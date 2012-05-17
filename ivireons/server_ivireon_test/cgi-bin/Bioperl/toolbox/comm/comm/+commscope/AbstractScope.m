classdef AbstractScope < commdevice.abstractDevice
    %AbstractScope Abstract class for communication scopes
    
    % Copyright 2008-2009 The MathWorks, Inc.
    % $Revision: 1.1.6.4 $  $Date: 2009/05/23 07:48:21 $

    %===========================================================================
    % Public properties
    properties
        % The time in seconds the scope will wait before starting to collect
        % data. 
        MeasurementDelay = 0;
        % The number of samples skipped at each sampling point relative to the
        % MeasurementDelay.  
        SamplingOffset = 0;
        % The switch that controls the plot refresh style.  The choices are:
        %           'on'  - The eye diagram plot is refreshed every time
        %                   the update method is called.
        %           'off' - The eye diagram plot is not refreshed when the
        %                   update method is called. 
        RefreshPlot = 'on';
    end
    
    %===========================================================================
    % Public Read-only properties
    properties (SetAccess = protected)
    % The number of samples processed by the eye diagram object.  This value
    % does not include the discarded samples during the MeasurementDelay period.
    % This property is not writable.
    SamplesProcessed = 0
    end
    
    %===========================================================================
    % Protected/Transient properties
    properties (Access = protected, Transient)
        ContainerHandle = -1;
    end
    
    %===========================================================================
    % Protected properties
    properties (Access = protected)
        RefreshPlotTurnedOn = false;
        MeasDelaySamps = 0;
    end
    
    %===========================================================================
    % Public methods
    methods
        function update(this, varargin)
            %UPDATE Update the communications scope data
            %   UPDATE(H, X) updates the collected data of the scope H with the
            %   input X.  If the RefreshPlot property is set to 'on', the UPDATE
            %   method also refreshes the scope figure.
            %
            %   See also commscope, commscope.ScatterPlot.
            
            error(nargchk(2,inf,nargin,'struct'));
            
            numSamps = this.SamplesProcessed;
            delay = this.MeasDelaySamps;
            rcvLen = length(varargin{1});
            
            if ( (numSamps+rcvLen) > delay )
                % Discard samples which are received before MeasurementDelay expired
                if ( numSamps < delay )
                    startIdx = delay - numSamps + 1;
                    rcvLen = rcvLen - startIdx + 1;
                else
                    startIdx = 1;
                end
                
                updateData(this, startIdx, varargin{:})
            end
            
            this.SamplesProcessed = this.SamplesProcessed + rcvLen;
        end
        %-----------------------------------------------------------------------
        function close(this)
            %CLOSE Close the figure of a communications scope
            %   CLOSE(H) closes the figure of the communications scope H.
            %
            %   See also commscope, commscope.ScatterPlot.
            close(ancestor(this.ContainerHandle, 'figure'));
        end
    end

    %===========================================================================
    % Public abstract methods
    methods (Abstract)
        plot(this, varargin)
    end
    
    %===========================================================================
    % Protected abstract methods
    methods (Access = protected, Abstract)
        updateData(this, startIdx, varargin)
        figureClosedAction(this)
    end
    
    %===========================================================================
    % Protected methods
    methods (Access = protected)
        function createContainer(this, hParent, pos)
            % Create a container for the scope
            
            if nargin == 2
                % The position is not specified, cover the whole figure
                pos = [0 0 1 1];
            end
            
            % Create a uipanel
            this.ContainerHandle = uipanel(hParent, ...
                'BorderType', 'none', ...
                'Position', pos);
            
        end
        %-----------------------------------------------------------------------
        function hFig = createFigure(this, width, length)
            % Create a figure for the scope
            
            % Create a figure
            hFig = figure('IntegerHandle', 'on', ...
                'NextPlot', 'new', ...
                'NumberTitle', 'on', ...
                'Name', sprintf('%s', this.Type), ...
                'DockControls', 'off', ...
                'Tag', sprintf('%s', this.Type), ...
                'Position', [0 0 width length], ...
                'Visible', 'off');
            
            % Move to the left upper corner
            movegui(hFig, 'northwest')
            
            % Assign a listener for close/delete
            addlistener(hFig, 'ObjectBeingDestroyed', ...
                @(hSrc, ed) deleteContainer(this));
        end
        %-----------------------------------------------------------------------
        function deleteContainer(this)
            % Delete the scope figure
            
            % Do other figure close related actions
            figureClosedAction(this)

            % Reset the scope handle to invalid
            this.ContainerHandle = -1;
        end
        %-----------------------------------------------------------------------
        function updateRefreshPlot(this, v) %#ok<INUSD,MANU>
            % Overwrite this method if extra action is needed for
            % set.RefreshPot
            
            % NO OP
        end
    end
    
    %===========================================================================
    % Set/Get methods
    methods
        function set.MeasurementDelay(this, v)
            propName = 'MeasurementDelay';
            validateattributes(v, {'double'}, ...
                {'real', 'scalar', 'nonnegative', 'finite', 'nonnan', ...
                'nonempty'}, ...
                [class(this) '.' propName], propName);
            
            this.MeasurementDelay = v;
            this.MeasDelaySamps = ceil(v * this.SamplingFrequency); %#ok<MCSUP>
            reset(this);
        end
        %-----------------------------------------------------------------------
        function set.SamplingOffset(this, v)
            propName = 'SamplingOffset';
            validateattributes(v, {'double'}, ...
                {'nonnegative', 'real', 'scalar', 'finite', 'nonnan', ...
                'nonempty', 'integer'}, ...
                [class(this) '.' propName], propName);
            
            this.SamplingOffset = v;
            reset(this);
        end
        %-----------------------------------------------------------------------
        function set.SamplesProcessed(this, v)
            propName = 'SamplesProcessed';
            validateattributes(v, {'double'}, ...
                {'nonnegative', 'real', 'scalar', 'finite', 'nonnan', ...
                'nonempty', 'integer'}, ...
                [class(this) '.' propName], propName);
            
            this.SamplesProcessed = v;
        end
        %-----------------------------------------------------------------------
        function set.RefreshPlot(this, v)
            propName = 'RefreshPlot';
            validatestring(v, {'on', 'off'}, ...
                [class(this) '.' propName], propName);
            
            if strncmpi(this.RefreshPlot, 'off', 3) && strncmpi(v, 'on', 2)
                this.RefreshPlotTurnedOn = true; %#ok<MCSUP>
            end
            updateRefreshPlot(this, v)
            this.RefreshPlot = v;
        end
    end
end