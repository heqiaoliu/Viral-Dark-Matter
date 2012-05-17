classdef abstractPulse <  sigutils.sorteddisp & sigutils.pvpairs ...
        & sigutils.SaveLoad
%ABSTRACTPULSE Abstract class for pulse sources
%   ABSTRACTPULSE class is an abstract class for pulse sources, such as an NRZ
%   or RZ pulse source.  
%
%   ABSTRACTPULSE class has the following properties.  Properties and methods
%   specified as abstract must be implemented by the subclass.
%
%   Property Name      Description
%   ----------------------------------------------------------------------------
%   OutputLevels     - Amplitude levels in a vector for symbol values 0:M-1.
%                      This is an abstract property.  
%   SymbolDuration   - Number of samples used to represent a symbol.  Note that
%                      this property must be an integer number.
%   RiseTime         - 10%-90% rise time of the pulse normalized by sampling
%                      time, i.e. in samples.  Note that this property can be a
%                      non-integer number.
%   FallTime         - 90%-10% fall time of the pulse normalized by sampling
%                      time, i.e. in samples.  Note that this property can be a
%                      non-integer number.
%
%   commdevice.abstractPulse methods:
%     generate - This is an abstract method used to generate a modulated signal
%                based on the pulse definition and the input data.  If jitter is
%                specified, this method also injects jitter to the output
%                signal.  It accepts three argument: H, the object handle, DATA,
%                the data symbol numbers, and JITTER, the jitter values.
%
%   See COMMSRC.NRZ for an example subclass of COMMDEVICE.ABSTRACTPULSE.
%
%   See also COMMSRC, COMMSRC.NRZ, COMMSRC.RZ.

% Copyright 2008-2009 The MathWorks, Inc.
% $Revision: 1.1.6.4 $  $Date: 2009/05/23 07:48:23 $

    %===========================================================================
    % Abstract public properties
    properties (Abstract)
        OutputLevels;   % Amplitude levels in a vector for symbol values 0:M-1
    end

    %===========================================================================
    % Public properties
    properties
        SymbolDuration = 100;	% Number of samples used to represent a symbol.  
                                % Note that this property must be an integer
                                % number. 
        RiseTime = 0;           % 10%-90% rise time of the pulse normalized by 
                                % sampling time, i.e. in samples.  Note that
                                % this property can be a non-integer number.
        FallTime = 0;           % 90%-10% fall time of the pulse normalized by 
                                % sampling time, i.e. in samples.  Note that
                                % this property can be a non-integer number.
    end
    
    %===========================================================================
    % Protected properties
    properties (SetAccess = protected)
        Type;   % Type of the class.  Read-only property.  Must be set at the 
                % construction time by the subclass.
    end

    %===========================================================================
    % Private properties
    properties (SetAccess = protected, GetAccess = protected)
        RiseRate = inf;     % Rise rate in amplitude per sample
        FallRate = inf;     % Fall rate in amplitude per sample
        LastData = 0;       % Stores the last input data symbol's index 
        LastJitter = 0;     % Stores the last input jitter sample
    end
    
    %===========================================================================
    % Public methods
    methods
        function reset(this)
%RESET	Reset the internal states of a pulse generator object
%   RESET(H) Resets the internal states of a pulse generator object H.
%
%   See also COMMSRC.RZ, COMMSRC.NRZ.

            this.LastData = 0;
            this.LastJitter = 0;
        end
    end

    %===========================================================================
    % Protected methods
    methods (Access = protected)
        function [jitter dataLen] = parseGenerateArgs(this, data, varargin)
            % Parse and validate the arguments of the generate method

            dataLen = length(data);
            % Check if jitter is defined
            if nargin == 3
                jitter = varargin{1};
            else
                % If jitter is not defined, then assume no jitter
                jitter = zeros(dataLen, 1);
            end

            % Validate input
            sigdatatypes.checkBinaryColVec('GENERATE', 'DATA', data);
            sigdatatypes.checkFiniteRealDblColVec('GENERATE', 'JITTER', jitter);
            if any(diff(jitter) >= this.SymbolDuration)
                error('comm:commsrc:abstractPulse:JitterLargerThanTsym', ...
                    ['Unrealizable JITTER value.  Type '...
                    '''doc commsrc.pattern'' for valid jitter values.'])
            end
            jitterLen = length(jitter);
            if dataLen ~= jitterLen
                error('comm:commsrc:abstractPulse:DataJitterLenMismatch', ...
                    'DATA and JITTER must be the same size.')
            end
        end
        
        %-----------------------------------------------------------------------
        function [clk nClk rClk] = getJitteredClock(this, dataLen, jitter)
            % Calculate clock instances.  The generate method requires the
            % integer and fractional parts for each clock instance.  This method
            % first generates a golden clock, adds jitter (CLK), and then
            % calculates the integer (NCLK) and fractional (RCLK) parts of the
            % clock.
            
            % First generate golden clock.
            sampsPerSymbol = this.SymbolDuration;
            goldenClk = (sampsPerSymbol:sampsPerSymbol:dataLen*sampsPerSymbol)';

            % Add jitter to the golden clock and calculate integer and
            % fractional parts
            nLastJitter = ceil(this.LastJitter);
            rLastJitter = nLastJitter - this.LastJitter;
            clk = [-rLastJitter; goldenClk + (jitter-nLastJitter)] + 1;
            nClk = ceil(clk);
            rClk = nClk - clk;
        end
    end

    %===========================================================================
    % Abstract private methods
    methods (Abstract, Access = protected)
        % Subclasses should implement this method to calculate the values of
        % private properties used to generate the pulse.  This method should be
        % called at construction time and also whenever a public property is
        % changed.
        calcPulse(this)
    end

    %===========================================================================
    % Abstract public methods
    methods (Abstract)
        % Subclasses should implement this method to generate the pulse.  The
        % method should accept clock instances vector and data bits vector.
        out = generate(this, clk, data)
    end

    %===========================================================================
    % Set/Get methods
    methods
        function set.RiseTime(this, Tr)
            % Check for validity
            sigdatatypes.checkFiniteNonNegDblScalar(this, 'RiseTime', Tr);

            % Store the old value in case calcPulse errors out, then set.
            oldValue = this.RiseTime;
            this.RiseTime = Tr;
            
            % Recalculate pulse.  If calcPulse errors out, then restore to the
            % original value and error out from this function.
            try
                calcPulse(this);
            catch exception
                this.RiseTime = oldValue;
                throw(exception)
            end
        end
        
        %-----------------------------------------------------------------------
        function set.FallTime(this, Tf)
            % Check for validity
            sigdatatypes.checkFiniteNonNegDblScalar(this, 'FallTime', Tf);

            % Store the old value in case calcPulse errors out, then set.
            oldValue = this.FallTime;
            this.FallTime = Tf;
            
            % Recalculate pulse.  If calcPulse errors out, then restore to the
            % original value and error out from this function.
            try
                calcPulse(this);
            catch exception
                this.FallTime = oldValue;
                throw(exception)
            end
        end
        
        %-----------------------------------------------------------------------
        function set.SymbolDuration(this, Ts)
            % Check for validity
            sigdatatypes.checkFinitePosIntScalar(this, 'SymbolDuration', Ts);

            % Store the old value in case calcPulse errors out, then set.
            oldValue = this.SymbolDuration;
            this.SymbolDuration = Ts;
            
            % Recalculate pulse.  If calcPulse errors out, then restore to the
            % original value and error out from this function.
            try
                calcPulse(this);
            catch exception
                this.SymbolDuration = oldValue;
                throw(exception)
            end
        end
    end
end
%---------------------------------------------------------------------------
% [EOF]