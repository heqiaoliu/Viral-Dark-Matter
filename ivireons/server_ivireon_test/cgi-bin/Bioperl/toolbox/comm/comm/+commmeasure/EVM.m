classdef EVM < commmeasure.ErrVecMeasure & sigutils.sorteddisp & sigutils.pvpairs
%EVM Error Vector Magnitude measurements
%   H = commmeasure.EVM returns a default error vector magnitude (EVM) object H.
%   The EVM object can be used to measure RMS EVM, maximum EVM, and percentile
%   EVM, all in percentages.  The measurements are taken starting from the
%   construction time or the last reset.
%
%   H = commmeasure.EVM('PropertyName',PropertyValue,...) returns an EVM object
%   H, with property values set to PropertyValues.  See properties list below
%   for valid PropertyNames.
%
%   commmeasure.EVM methods:
%       update     - Update the EVM measurements with new data
%       reset      - Reset the EVM object
%       copy       - Copy the EVM object
%
%   commmeasure.EVM properties:
%       TYPE                - 'EVM Measurements'. This is read-only.
%       NormalizationOption - EVM normalization method.  
%       AveragePower        - Average constellation power.
%       PeakPower           - Peak constellation power.
%       RMSEVM              - RMS EVM measurement result.  This is read-only.
%       MaximumEVM          - Maximum EVM measurement result.  This is 
%                             read-only.
%       Percentile          - Percentile value to calculate PercentileEVM.
%       PercentileEVM       - Percentile EVM measurement result.  This is 
%                             read-only.
%       NumberOfSymbols     - Number of processed symbols. This is read-only.
%
%   Example:
%       % Measure EVM of a noisy 16-QAM modulated signal.  Determine 90th 
%       % percentile point, which is the value where 90% of the individual 
%       % symbol EVM values are below that point. 
%       hMod = modem.qammod('M', 16);  % Create a 16-QAM modulator object
%       hEVM = commmeasure.EVM;
%       hEVM.Percentile = 90;
%       xmt = modulate(hMod, randi([0 15], 1000, 1)); % Generate modulated symbols
%       rcv = awgn(xmt, 20, 'measured');        % Add AWGN
%       update(hEVM, rcv, xmt)                  % Update measurements
%       hEVM
%
%   See also commmeasure, commmeasure.MER.
    
    %   Copyright 2008-2009 The MathWorks, Inc.
    %   $Revision: 1.1.6.5 $  $Date: 2009/05/23 07:48:15 $
    
    %===========================================================================
    % Read-only properties
    properties (SetAccess = protected)
        % Maximum EVM measurement result.  This is a read-only property.
        % The maximum value of EVM (in percent) is the maximum error deviation
        % measured at each symbol interval.  The measurement is taken starting
        % from the construction time or the last reset.
        MaximumEVM = 0;
    end
    
    %===========================================================================
    % Dependent properties
    properties (SetAccess = private, Dependent)
        % RMS EVM measurement result.  This is read-only.
        % The RMSEVM (in percent) is a measure of the root-mean-square relative
        % EVM measured over all symbols.  The measurement is taken starting from
        % the construction time or the last reset.
        RMSEVM
        % Percentile EVM measurement result.  This is read-only.
        % The PercentileEVM (in percent) is the point where Percentile percent
        % of the individual EVM values, measured at each symbol interval, are
        % below that point. 
        % 
        % For example, if Percentile is set to 95, then 95% of the symbol EVM
        % measurements will be below the PercentileEVM value.
        PercentileEVM
    end
    
    %===========================================================================
    % Public properties
    properties
        % EVM normalization method
        % Specify the normalization method used in EVM calculation as one of 
        % [{'Average reference signal power'} | 'Average constellation
        % power' | 'Peak constellation power'].
        NormalizationOption = 'Average reference signal power';
    end
    
    %===========================================================================
    % Public dependent properties
    properties (Dependent)
        % Average constellation power
        AveragePower
        % Peak constellation power
        PeakPower
    end
    
    %===========================================================================
    % Private properties
    properties (Access = private)
        % Private storage for average constellation power.  Used to bypass
        % set checks.
        PrivAveragePower = 1;
        % Private storage for peak constellation power.  Used to bypass
        % set checks.
        PrivPeakPower = 1;
    end
    
    %===========================================================================
    % Public methods
    methods
        function this = EVM(varargin)
            
            this = this@commmeasure.ErrVecMeasure(varargin);
            this.Type = 'EVM Measurements';
            [this.PercentileObj.MinValue this.PercentileObj.MaxValue] = ...
                getExpectedRange(this);
            this.PercentileObj.StepSize = 0.01;

            if nargin
                % There are input arguments, so initialize with property-value
                % pairs.
                initPropValuePairs(this, varargin{:});
            end
        end
        %-----------------------------------------------------------------------
        function update(this, rcv, xmt)
            %UDPATE Update the EVM measurements with new data
            %   UPDATE(H, RCV, XMT) update the EVM object H with new data.  RCV
            %   is the symbols under test and XMT is the ideal symbols.
            %
            %   Example:
            %   % Measure EVM of a noisy 16-QAM modulated signal.  Determine 90th 
            %   % percentile point, which is the value where 90% of the individual 
            %   % symbol EVM values are below that point. 
            %   hMod = modem.qammod('M', 16);  % Create a 16-QAM modulator object
            %   hEVM = commmeasure.EVM;
            %   hEVM.Percentile = 90
            %   xmt = modulate(hMod, randi([0 15], 1000, 1)); % Generate modulated symbols
            %   rcv = awgn(xmt, 20, 'measured');        % Add AWGN
            %   update(hEVM, rcv, xmt)                  % Update measurements
            %
            %   See also commmeasure.EVM, commmeasure.EVM/reset,
            %   commmeasure.EVM/copy.
            
            % Calculate error vector magnitude and update sum of error magnitues
            errMagSqr = abs(rcv - xmt).^2;
            this.SumErrMagSqr = this.SumErrMagSqr + sum(errMagSqr);
            
            % Update number of processed symbols
            this.NumberOfSymbols = this.NumberOfSymbols + length(rcv);
            this.PrivNumberOfSymbols = this.PrivNumberOfSymbols + length(rcv);

            % Calculate percent EVM for individual symbols
            switch this.NormalizationOption
                case 'Average reference signal power'
                % Calculate reference magnitudes
                refMagSqr = abs(xmt).^2;
                this.SumRefMagSqr = this.SumRefMagSqr + sum(refMagSqr);
                % Calculate percent EVM for individual symbols by
                % normalizing with average reference signal power
                symEVM = sqrt(errMagSqr/...
                    (this.SumRefMagSqr/this.PrivNumberOfSymbols))*100;
                case 'Average constellation power'
                % Calculate percent EVM for individual symbols by
                % normalizing with average constellation power
                symEVM = sqrt(errMagSqr/this.AveragePower)*100;
                case 'Peak constellation power'
                % Calculate percent EVM for individual symbols by
                % normalizing with peak constellation power
                symEVM = sqrt(errMagSqr/this.PeakPower)*100;
            end
            
            % Calculate maximum percent EVM
            this.MaximumEVM = max([max(symEVM) this.MaximumEVM]);
            
            % Caculate percentile percent EVM
            update(this.PercentileObj, symEVM);
        end
        %-----------------------------------------------------------------------
        function reset(this, varargin)
            %RESET Reset the EVM object
            %   RESET(H) reset the EVM object H.  This operation removes all the
            %   previously collected data from the object memory.
            %
            %   RESET(H, MEAS1, ...) reset the MEAS1 measurement of the EVM
            %   object H.  MEAS1 can be 'RMSEVM', 'MaximumEVM', or
            %   'PercentileEVM'.  NumberOfSymbols property is not reset.
            %   This format is useful for implementing frame based
            %   measurements.
            %
            %   Example:
            %   % Measure EVM of a noisy 16-QAM modulated signal.  
            %   hMod = modem.qammod('M', 16);  % Create a 16-QAM modulator object
            %   hEVM = commmeasure.EVM;
            %   xmt = modulate(hMod, randi([0 15], 1000, 1)); % Generate modulated symbols
            %   rcv = awgn(xmt, 20, 'measured');        % Add AWGN
            %   update(hEVM, rcv, xmt)                  % Update measurements
            %   frameMax = hEVM.MaximumEVM;             % Cash maximum for this frame
            %   reset(hEVM, 'MaximumEVM')               % Reset maximum EVM measurement
            %   xmt = modulate(hMod, randi([0 15], 1000, 1)); % Generate modulated symbols
            %   rcv = awgn(xmt, 20, 'measured');        % Add AWGN
            %   update(hEVM, rcv, xmt)                  % Update measurements
            %   % Calculate average of maximum EVM values over frames
            %   meanFrameMax = (frameMax + hEVM.MaximumEVM) /2 
            %   
            %   See also commmeasure.EVM, commmeasure.EVM/update,
            %   commmeasure.EVM/copy.

            if nargin == 1
                resetAll = true;
            else
                resetAll = false;
            end
            
            for p=1:nargin-1
                validatestring(varargin{p}, {'RMSEVM', 'MaximumEVM', 'PercentileEVM'}, ...
                    'reset',...%'commmeasure.EVM.reset', ...
                    'reset method of class commmeasure.EVM', p+1);
            end
            
            varargin = lower(varargin);
            if resetAll || ~isempty(strmatch('rmsevm', varargin))
                this.SumErrMagSqr = 0;
                this.SumRefMagSqr = 0;
                this.PrivNumberOfSymbols = 0;
            end
            if resetAll || ~isempty(strmatch('maximumevm', varargin))
                this.MaximumEVM = 0;
            end
            if resetAll || ~isempty(strmatch('percentileevm', varargin))
                reset(this.PercentileObj)
            end
            if resetAll
                this.NumberOfSymbols = 0;
            end            
        end
        %-----------------------------------------------------------------------
        function h = copy(this)
            %COPY Copy the EVM object
            %   HCOPY = COPY(H) copy the EVM object H and return in HCOPY.  H
            %   and HCOPY are independent but identical objects, i.e. modifying
            %   the H object does not affect HCOPY object.
            %
            %   See also commmeasure.EVM, commmeasure.EVM/update,
            %   commmeasure.EVM/reset.

            for p=1:length(this)
                hTemp = commmeasure.EVM;
                hTemp.SumRefMagSqr = this.SumRefMagSqr;
                hTemp.NumberOfSymbols = this.NumberOfSymbols;
                hTemp.PrivNumberOfSymbols = this.PrivNumberOfSymbols ;
                hTemp.PercentileObj = copy(this.PercentileObj);
                hTemp.SumErrMagSqr = this.SumErrMagSqr;
                hTemp.MaximumEVM = this.MaximumEVM;
                hTemp.PrivAveragePower = this.PrivAveragePower;
                hTemp.PrivPeakPower = this.PrivPeakPower;
                hTemp.NormalizationOption = this.NormalizationOption;
                h(p) = hTemp; %#ok<AGROW>
            end
        end
    end
    
    %===========================================================================
    % Protected methods
    methods (Access = protected)
        function [minVal maxVal] = getExpectedRange(this) %#ok<MANU>
            minVal = 0;
            maxVal = 400;
        end
        %-----------------------------------------------------------------------
        function sortedList = getSortedPropDispList(this)
            % Get the sorted list of the properties to be displayed.
            
            sortedList = {...
                'Type', ...
                'NormalizationOption', ...
                };
            
            % Add normalization option related properties
            switch this.NormalizationOption
                case 'Average reference signal power'
                    % No additional properties
                case 'Average constellation power'
                    % Add average constellation power to the list
                    sortedList{end+1} = 'AveragePower';
                case 'Peak constellation power'
                    % Add peak constellation power to the list
                    sortedList{end+1} = 'PeakPower';
            end
            
            sortedList = [sortedList ...
                {'RMSEVM', ...
                'MaximumEVM', ...
                'Percentile', ...
                'PercentileEVM', ...
                'NumberOfSymbols'}];
        end
        %-----------------------------------------------------------------------
        function sortedList = getSortedPropInitList(this) %#ok<MANU>
            % GETSORTEDPROPINITLIST returns a list of properties in the order in
            % which the properties must be initialized.  If order is not
            % important, returns an empty cell array.
            
            sortedList = {...
                'NormalizationOption', ...
                'AveragePower', ...
                'PeakPower', ...
                };
        end
    end
    
    %===========================================================================
    % Set/Get methods
    methods
        function v = get.PercentileEVM(this)
            try
                v = this.PercentileObj.PercentilePoint;
            catch me
                if strcmpi(me.identifier, 'comm:commmeasure:Percentile:HighMinValue')
                    warning(generatemsgid('NoPercentileHigh'), ...
                        ['Percentile value cannot be calculated.  The data '...
                        'may have too little noise.  You can turn this '...
                        'warning off by typing ''warning(''off'', '...
                        '''comm:commmeasure:EVM:NoPercentileHigh'')''.']);
                    v = NaN;
                elseif strcmpi(me.identifier, 'comm:commmeasure:Percentile:LowMaxValue')
                    warning(generatemsgid('NoPercentileLow'), ...
                        ['Percentile value cannot be calculated.  The data '...
                        'may have too much noise.  You can turn this '...
                        'warning off by typing ''warning(''off'', '...
                        '''comm:commmeasure:EVM:NoPercentileLow'')''.']);
                    v = NaN;
                else
                    rethrow(me)
                end
            end
        end
        %-----------------------------------------------------------------------
        function v = get.RMSEVM(this)
            if this.NumberOfSymbols
                switch this.NormalizationOption
                    case 'Average reference signal power'
                        % Calculate percent EVM for individual symbols by
                        % normalizing with average reference signal power
                        v = sqrt(this.SumErrMagSqr/this.SumRefMagSqr)*100;
                    case 'Average constellation power'
                        % Calculate percent EVM for individual symbols by
                        % normalizing with average constellation power
                        v = sqrt(this.SumErrMagSqr/this.PrivNumberOfSymbols...
                            /this.AveragePower)*100;
                    case 'Peak constellation power'
                        % Calculate percent EVM for individual symbols by
                        % normalizing with peak constellation power
                        v = sqrt(this.SumErrMagSqr/this.PrivNumberOfSymbols...
                            /this.PeakPower)*100;
                end
            else
                v = NaN;
            end
        end
        %-----------------------------------------------------------------------
        function set.NormalizationOption(this, v)
            v = validatestring(v, {'Average reference signal power', ...
                'Average constellation power', 'Peak constellation power'}, ...
                'commmeasure.EVM', 'NormalizationOption');
            this.NormalizationOption = v;
        end
        %-----------------------------------------------------------------------
        function set.AveragePower(this, v)
            propName = 'AveragePower';
            validateattributes(v, {'double'}, ...
                {'nonnegative', 'scalar', 'nonnan', 'finite'},...
                [class(this) '.' propName], propName);
            if ~strncmpi(this.NormalizationOption, 'Average c', 9)
                warning(generatemsgid('AveragePowerInactive'), ...
                    ['AveragePower property is inactive when ', ...
                    'NormalizationOption is set to ''%s''.'], ...
                    this.NormalizationOption);
            end
            this.PrivAveragePower = v;
        end
        %-----------------------------------------------------------------------
        function v = get.AveragePower(this)
            v = this.PrivAveragePower;
        end
        %-----------------------------------------------------------------------
        function set.PeakPower(this, v)
            propName = 'PeakPower';
            validateattributes(v, {'double'}, ...
                {'nonnegative', 'scalar', 'nonnan', 'finite'},...
                [class(this) '.' propName], propName);
            if ~strncmpi(this.NormalizationOption, 'Peak c', 6)
                warning(generatemsgid('PeakPowerInactive'), ...
                    ['PeakPower property is inactive when ', ...
                    'NormalizationOption is set to ''%s''.'], ...
                    this.NormalizationOption);
            end
            this.PrivPeakPower = v;
        end
        %-----------------------------------------------------------------------
        function v = get.PeakPower(this)
            v = this.PrivPeakPower;
        end
        %-----------------------------------------------------------------------
    end
end
