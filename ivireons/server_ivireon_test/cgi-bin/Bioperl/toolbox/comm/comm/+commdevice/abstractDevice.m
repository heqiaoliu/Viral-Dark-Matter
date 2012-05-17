classdef abstractDevice < handle
%ABSTRACTDEVICE Abstract class for communication devices
%   ABSTRACTDEVICE class is a utility class for generators and measurement
%   devices, such as a pattern generator and an eye diagram, that require
%   sampling frequency and symbol rate information.  
%
%   ABSTRACTDEVICE class has the following properties.  Properties and methods
%   labeled as abstract must be implemented by the subclass.
%
%   abstractDevice properties:
%
%   SamplingFrequency     - Sampling frequency
%   SamplesPerSymbol      - Number of samples in a symbol
%   SymbolRate            - Symbol rate
%
%   See COMMSRC.PATTERN for an example subclass of COMMDEVICE.ABSTRACTDEVICE.
%
%   See also COMMDEVICE, COMMSRC.PATTERN.

% Copyright 2007-2009 The MathWorks, Inc.
% $Revision: 1.1.6.2 $  $Date: 2009/03/09 19:06:02 $

    %===========================================================================
    % Public properties
    properties
%SamplingFrequency Sampling frequency
%   Specify the Sampling frequency of the input signal in Hz
        SamplingFrequency = 10000;
%SamplesPerSymbol Number of samples in a symbol
%   Specify the number of samples used to represent a symbol
        SamplesPerSymbol = 100;
    end

    %===========================================================================
    % Read only public properties.  These are defined as dependent properties,
    % i.e. their value is not stored but calculated with the get function.
    properties (Dependent, SetAccess = private)
%SymbolRate Symbol rate
%   Specify the symbol rate of the input signal in symbols per second.
%   Symbol rate is a read-only property and  it is calculated based on
%   SamplingFrequency and SamplesPerSymbol. 
        SymbolRate;
    end
    
    %===========================================================================
    % Set/Get methods
    methods
        function set.SamplingFrequency(this, Fs)
            % Check for validity
            sigdatatypes.checkFinitePosDblScalar(this, 'SamplingFrequency', Fs)

            % Set the property
            this.SamplingFrequency = Fs;
            
            % Reset the object
            reset(this);
        end
        
        %-----------------------------------------------------------------------
        function set.SamplesPerSymbol(this, nSamps)
            % Check for validity
            sigdatatypes.checkFinitePosIntScalar(this, 'SamplesPerSymbol', ...
                nSamps);

            % Set the property
            this.SamplesPerSymbol = nSamps;
            
            % Reset the object
            reset(this);
        end
        
        %-----------------------------------------------------------------------
        function Rs = get.SymbolRate(this)
            % Note that SymbolRate is a dependent property and its value is not
            % stored.  This get function calculates the value of this property
            % on the fly. 
            Rs = this.SamplingFrequency / this.SamplesPerSymbol;
        end
    end

    %===========================================================================
    % Abstract public methods
    methods (Abstract)
        reset(this)
    end
end
%---------------------------------------------------------------------------
% [EOF]