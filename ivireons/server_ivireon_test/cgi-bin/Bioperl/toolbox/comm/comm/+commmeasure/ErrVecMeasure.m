classdef ErrVecMeasure < handle
    %ErrVecMeasure Defines ErrVecMeasure class for COMMMEASURE package
    
    %   Copyright 2008-2009 The MathWorks, Inc.
    %   $Revision: 1.1.6.3 $  $Date: 2009/12/05 01:58:13 $

    %===========================================================================
    % Read-only properties
    properties (SetAccess = protected)
        % Type of the class.  Read-only property.
        Type;
        % Number of processed symbols.
        NumberOfSymbols = 0;
    end
    
    %===========================================================================
    % Dependent properties
    properties (Dependent)
        % Value used to calculate the percentile point of the measurement
        % The percentile point is the point where Percentile percent
        % of the individual measurements are below the PercentileEVM value or
        % above the PercentileMER value.
        %
        % For example, if Percentile is set to 95, then 95% of the EVM
        % measurements are below the PercentileEVM value.
        Percentile
    end
    
    %===========================================================================
    % Protected properties
    properties (Access = protected)
        % Holds the percentile object for percentile calculations
        PercentileObj
        % Running sum of error magnitude squares
        SumErrMagSqr = 0;
        % Running sum of reference signal magnitude squares
        SumRefMagSqr = 0;
        % Number of symbols used in Sum* variables
        PrivNumberOfSymbols = 0;
    end
    
    %===========================================================================
    % Public methods
    methods
        function this = ErrVecMeasure(varargin)
            this.PercentileObj = commmeasure.Percentile;
        end
        %-----------------------------------------------------------------------
        function reset(this)
            reset(this.PercentileObj)
            this.NumberOfSymbols = 0;
            this.SumErrMagSqr = 0;
            this.SumRefMagSqr = 0;
        end
    end
    
    %===========================================================================
    % Abstract Public methods
    methods (Abstract)
        update(this, rcv, xmt)
    end
    
    %===========================================================================
    % Abstract Protected methods
    methods (Access = protected, Abstract)
        [minVal maxVal] = getExpectedRange(this)
    end
    
    %===========================================================================
    % Set/Get methods
    methods
        function set.Percentile(this, v)
            this.PercentileObj.PercentileValue = v;
        end
        %-----------------------------------------------------------------------
        function v = get.Percentile(this)
            v = this.PercentileObj.PercentileValue;
        end
        %-----------------------------------------------------------------------
    end
end
