classdef MER < commmeasure.ErrVecMeasure & sigutils.sorteddisp & sigutils.pvpairs
%MER Modulation Error Ratio measurement
%   H = commmeasure.MER returns a default modulation error ratio (MER) object H.
%   The MER object can be used to measure MER, minimum MER, and percentile MER,
%   all in dB.  The measurements are taken starting from the construction time
%   or the last reset.  
%
%   H = commmeasure.MER('PropertyName',PropertyValue,...) returns an MER object
%   H, with property values set to PropertyValues.  See properties list below
%   for valid PropertyNames.
%
%   commmeasure.MER methods:
%       update     - Update the MER measurements with new data
%       reset      - Reset the MER object
%       copy       - Copy the MER object
%
%   commmeasure.MER properties:
%       TYPE            - 'MER Measurements'. This is read-only.
%       MERdB           - MER measurement result (in dB).  This is read-only.
%       MinimumMER      - Minimum MER measurement result (in dB).  This is read-only.
%       Percentile      - Percentile value to calculate PercentileMER.
%       PercentileMER   - Percentile MER measurement result (in dB).  This is read-only.
%       NumberOfSymbols - Number of processed symbols. This is read-only.
%
%   Example:
%       % Measure MER of a noisy 16-QAM modulated signal.  Determine 90th
%       % percentile point, which is the value where 90% of the individual
%       % symbol MER values are above that point.
%       hMod = modem.qammod('M', 16);  % Create a 16-QAM modulator object
%       hMER = commmeasure.MER('Percentile', 90);
%       xmt = modulate(hMod, randi([0 15], 1000, 1)); % Generate modulated symbols
%       rcv = awgn(xmt, 20, 'measured');        % Add AWGN
%       update(hMER, rcv, xmt)                  % Update measurements
%
%   See also commmeasure, commmeasure.EVM.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/02/13 15:10:54 $
    
    %===========================================================================
    % Read-only properties
    properties (SetAccess = protected)
        % Minimum MER measurement result (in dB).  This is read-only.
        % The minimum value of MER is the minimum power ratio measured at each
        % symbol interval.  The measurement is taken starting from the
        % construction time or the last reset.
        MinimumMER = inf;
    end
    
    %===========================================================================
    % Dependent properties
    properties (SetAccess = private, Dependent)
        % MER measurement result (in dB).  This is read-only.
        % The Modulation Error Ratio (MER) is a power ratio expressed in dB,
        % where the sum of squares of the magnitudes of the ideal symbol vectors
        % is divided by the sum of squares of the magnitudes of the symbol error
        % vectors.  The measurement is taken starting from the construction time
        % or the last reset.
        MERdB
        % Percentile MER measurement result (in dB).  This is read-only.
        % The PercentileMER is the point where Percentile percent of the
        % individual MER values, measured at each symbol interval, is above that
        % point. 
        % 
        % For example, if Percentile is set to 95, then 95% of the symbol MER
        % measurements will be above the PercentileMER value.
        PercentileMER
    end
    
    %===========================================================================
    % Public methods
    methods
        function this = MER(varargin)
            
            this = this@commmeasure.ErrVecMeasure(varargin);
            this.Type = 'MER Measurements';
            [this.PercentileObj.MinValue this.PercentileObj.MaxValue] = ...
                getExpectedRange(this);
            this.PercentileObj.Tail = 'higher';
            this.PercentileObj.StepSize = 0.01;

            if nargin
                % There are input arguments, so initialize with property-value
                % pairs.
                initPropValuePairs(this, varargin{:});
            end
        end
        %-----------------------------------------------------------------------
        function update(this, rcv, xmt)
            %UDPATE Update the MER measurements with new data
            %   UPDATE(H, RCV, XMT) update the MER object H with new data.  RCV
            %   is the symbols under test and XMT is the ideal symbols.
            %
            %   Example:
            %   % Measure MER of a noisy 16-QAM modulated signal.  Determine 90th 
            %   % percentile point, which is the value where 90% of the individual 
            %   % symbol MER values are above that point. 
            %   hMod = modem.qammod('M', 16);  % Create a 16-QAM modulator object
            %   hMER = commmeasure.MER('Percentile', 90);
            %   xmt = modulate(hMod, randi([0 15], 1000, 1)); % Generate modulated symbols
            %   rcv = awgn(xmt, 20, 'measured');        % Add AWGN
            %   update(hMER, rcv, xmt)                  % Update measurements
            %
            %   See also commmeasure.MER, commmeasure.MER/reset,
            %   commmeasure.MER/copy.

            % Calculate error vector magnitude and update sum of error magnitues
            errMagSqr = abs(rcv - xmt).^2;
            this.SumErrMagSqr = this.SumErrMagSqr + sum(errMagSqr);
            
            % Calculate reference magnitudes
            refMagSqr = abs(xmt).^2;
            this.SumRefMagSqr = this.SumRefMagSqr + sum(refMagSqr);
            
            % Update number of processed symbols
            this.NumberOfSymbols = this.NumberOfSymbols + length(rcv);
            this.PrivNumberOfSymbols = this.PrivNumberOfSymbols + length(rcv);

            % Calculate dB MER for individual symbols
            symMER = 10*log10((this.SumRefMagSqr/this.PrivNumberOfSymbols)...
                ./errMagSqr);
            
            % Calculate minimum MER
            this.MinimumMER = min([min(symMER) this.MinimumMER]);
            
            % Calculate percentile MER
            update(this.PercentileObj, symMER);
        end
        %-----------------------------------------------------------------------
        function reset(this, varargin)
            %RESET Reset the MER object
            %   RESET(H) reset the MER object H.  This operation removes all the
            %   previously collected data from the object memory.
            %
            %   RESET(H, MEAS1, ...) reset the MEAS1 measurement of the EVM
            %   object H.  MEAS1 can be 'MERdB', 'MinimumMER', or
            %   'PercentileMER'.  NumberOfSymbols property is not reset.
            %   This format is useful for implementing frame based
            %   measurements.
            %
            %   Example:
            %   % Measure MER of a noisy 16-QAM modulated signal.  
            %   hMod = modem.qammod('M', 16);  % Create a 16-QAM modulator object
            %   hMER = commmeasure.MER;
            %   xmt = modulate(hMod, randi([0 15], 1000, 1)); % Generate modulated symbols
            %   rcv = awgn(xmt, 20, 'measured');        % Add AWGN
            %   update(hMER, rcv, xmt)                  % Update measurements
            %   frameMin = hMER.MinimumMER;             % Cash maximum for this frame
            %   reset(hMER, 'MinimumMER')               % Reset minimum MER measurement
            %   xmt = modulate(hMod, randi([0 15], 1000, 1)); % Generate modulated symbols
            %   rcv = awgn(xmt, 20, 'measured');        % Add AWGN
            %   update(hMER, rcv, xmt)                  % Update measurements
            %   % Calculate average of minimum MER values over frames
            %   meanFrameMin = (frameMin + hMER.MinimumMER) /2
            %
            %   See also commmeasure.MER, commmeasure.MER/update,
            %   commmeasure.MER/copy.

            if nargin == 1
                resetAll = true;
            else
                resetAll = false;
            end
            
            for p=1:nargin-1
                validatestring(varargin{p}, {'MERdB', 'MinimumMER', 'PercentileMER'}, ...
                    'reset',...%'commmeasure.MER.reset', ...
                    'reset method of class commmeasure.MER', p+1);
            end
            
            varargin = lower(varargin);
            if resetAll || ~isempty(strmatch('merdb', varargin))
                this.SumErrMagSqr = 0;
                this.SumRefMagSqr = 0;
                this.PrivNumberOfSymbols = 0;
            end
            if resetAll || ~isempty(strmatch('minimummer', varargin))
                this.MinimumMER = Inf;
            end
            if resetAll || ~isempty(strmatch('percentilemer', varargin))
                reset(this.PercentileObj)
            end
            if resetAll
                this.NumberOfSymbols = 0;
            end
            
        end
        %-----------------------------------------------------------------------
        function h = copy(this)
            %COPY Copy the MER object
            %   HCOPY = COPY(H) copy the MER object H and return in HCOPY.  H
            %   and HCOPY are independent but identical objects, i.e. modifying
            %   the H object does not affect HCOPY object.
            %
            %   See also commmeasure.MER, commmeasure.MER/update,
            %   commmeasure.MER/reset.

            for p=1:length(this)
                hTemp = commmeasure.MER;
                hTemp.NumberOfSymbols = this.NumberOfSymbols;
                hTemp.PrivNumberOfSymbols = this.PrivNumberOfSymbols ;
                hTemp.PercentileObj = copy(this.PercentileObj);
                hTemp.SumErrMagSqr = this.SumErrMagSqr;
                hTemp.SumRefMagSqr = this.SumRefMagSqr;
                hTemp.MinimumMER = this.MinimumMER;
                h(p) = hTemp; %#ok<AGROW>
            end
        end
    end
    
    %===========================================================================
    % Protected methods
    methods (Access = protected)
        function [minVal maxVal] = getExpectedRange(this) %#ok<MANU>
            minVal = -100;
            maxVal = 100;
        end
        %-----------------------------------------------------------------------
        function sortedList = getSortedPropDispList(this) %#ok<MANU>
            % Get the sorted list of the properties to be displayed.  Overwrite
            % this method in the subclass to customize.
            
            sortedList = {...
                'Type', ...
                'MERdB', ...
                'MinimumMER', ...
                'Percentile', ...
                'PercentileMER', ...
                'NumberOfSymbols'};
        end
    end
    
    %===========================================================================
    % Set/Get methods
    methods
        function v = get.PercentileMER(this)
            try
                v = this.PercentileObj.PercentilePoint;
            catch me
                if strcmpi(me.identifier, 'comm:commmeasure:Percentile:HighMinValue')
                    warning(generatemsgid('NoPercentileHigh'), ...
                        ['Percentile value cannot be calculated.  The data '...
                        'may have too little noise.  You can turn this '...
                        'warning off by typing ''warning(''off'', '...
                        '''comm:commmeasure:MER:NoPercentileHigh'')''.']);
                    v = NaN;
                elseif strcmpi(me.identifier, 'comm:commmeasure:Percentile:LowMaxValue')
                    warning(generatemsgid('NoPercentileLow'), ...
                        ['Percentile value cannot be calculated.  The data '...
                        'may have too much noise.  You can turn this '...
                        'warning off by typing ''warning(''off'', '...
                        '''comm:commmeasure:MER:NoPercentileLow'')''.']);
                    v = NaN;
                else
                    rethrow(me)
                end
            end
        end
        function v = get.MERdB(this)
            if this.SumErrMagSqr
                v = 10*log10(this.SumRefMagSqr/this.SumErrMagSqr);
            else
                v = NaN;
            end
        end            
    end
end
