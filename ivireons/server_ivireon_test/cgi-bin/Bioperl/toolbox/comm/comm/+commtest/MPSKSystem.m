classdef (Sealed) MPSKSystem < testconsole.SystemBasicAPI 
%MPSKSystem Default MPSKSystem class for the commtest package
%   MPSKSystem extends the testconsole.SystemBasicAPI class and defines an MPSK
%   system that can be run for different values of energy per bit to noise
%   power spectral density ratio (EbNo), and modulation order (M). 

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/08/11 15:38:11 $

    %===========================================================================
    % Define properties needed for the MPSK simulation
    %===========================================================================    
    % Define properties useful for this specific communications system. Every
    % communications system may have user-defined properties. The system must
    % have public properties with names equal to the test parameters it will
    % register to a test console. If in debug mode (i.e. setup or run methods of
    % the system are called without being attached to a test console), calling
    % the getTestParameter method will return the value held by the system's
    % public property that has the same name as the requested test parameter
    % name. 
    properties         
        %EbNo   energy per bit to noise power spectral density ratio 
        %   The default value is 0.  This property name will be registered as a
        %   test parameter.
        EbNo = 0;   
        %M      Modulation order
        %   Default value is 2.  This property name will be registered as a test
        %   parameter.
        M = 2;
    end
    % Private properties
    properties (Access = private)
        %Mod    Modulator
        Mod
        %Demod  Demodulator
        Demod        
        %BitsPerSymbol Bits per symbol
        BitsPerSymbol
        %SNR    Signal to noise ratio
        SNR
    end
    %===========================================================================
    methods (Access = protected)
        function register(obj) 
            %REGISTER Implement the register method
            %
            %   Test input registration
            %      The communication system registers to the error rate test
            %      console the type of data source it will use in its run
            %      method. The error rate test console has two types of inputs
            %      (sources) available:
            %      'NumTransmissions' - calling the getInput method will return
            %         the frame length. The system itself is responsible for
            %         generating a data frame using a data source.
            %      'RandomIntegerSource' - calling the getInput method will
            %         return a vector of symbols with a length specified by the
            %         FrameLength property of the error rate test console. If
            %         the system registers this source type, then it must also
            %         register a test parameter named 'M' that corresponds to
            %         the modulation order.

            %   The MPSKSystem has an internal data source that is used to
            %   generate data frames of a specified length. Registering a
            %   'NumTransmissions' test input will allow the test console
            %   to control the frame length.
            registerTestInput(obj,'NumTransmissions')

            %   Test parameter registration
            %      The communication system registers to the error rate test
            %      console the names of the parameters it will use as test
            %      parameters. These test parameters can be used to sweep
            %      through multiple values by the test console. At registration
            %      time, the system specifies the name of the test parameter,
            %      its default value, and if needed, its valid value ranges. The
            %      user will be able to specify a vector of sweep values
            %      directly in the error rate test console before running
            %      simulations. If the user does not specify a sweep vector for
            %      a test parameter, then simulations are run using the default
            %      value of that parameter. At run time, the communications
            %      system must request the current simulation sweep parameter
            %      values using the getTestParameter method. 
            %      If in debug mode (i.e. setup or run methods of the system are
            %      called without being attached to a test console), calls to
            %      the getTestParameter method will return the value stored in
            %      the system's public property of the same name as the
            %      requested parameter. 
            
            %   Register a test parameter named 'EbNo', set its default
            %   value to 0, and a valid range of [-50 50]. Note that EbNo
            %   is also defined as a public property. 
            registerTestParameter(obj,'EbNo',0,[-50 50]);
            %   Register a test parameter named 'M', set its default value to 4,
            %   and a valid range of [2 1024]. Note that M is also defined
            %   as a public property.  
            registerTestParameter(obj,'M',4,[2 1024]);

            %   Test probe registration
            %      The communications system registers to the error rate test
            %      console the names of the data probes it will use to pass data
            %      to the test console for error rate calculations. The system
            %      can register as many data probes as necessary. Before running
            %      simulations, the user will be able to define test points in
            %      the error rate test console where test probes will be paired
            %      so that data in each probe can be compared and errors
            %      counted. At run time the communications system must call the
            %      setTestProbeData method to log data into the registered
            %      probes held by the error rate test console.
            %      If in debug mode (i.e. setup or run methods of the system are
            %      called without being attached to a test console), calls to
            %      the setTestProbeData method are ignored.
            
            % Register a probe named 'TxInputSymbols' to log symbol streams at
            % the transmitter input. Add a description to the probe. The
            % description input is optional  
            registerTestProbe(obj,'TxInputSymbols','Symbols at modulator input')   
            % Register a probe named 'RxOutputSymbols' to log symbol streams at
            % the receiver output
            registerTestProbe(obj,'RxOutputSymbols', ...
                'Symbols at demodulator output') 
            % Register a probe named 'TxInputBits' to log bit streams at the
            % transmitter input.     
            registerTestProbe(obj,'TxInputBits', 'Bits at modulator input')   
            % Register a probe named 'RxOutputBits' to log bit streams at the
            % receiver output            
            registerTestProbe(obj,'RxOutputBits', 'Bits at demodulator output')                 
        end  
        %=======================================================================        
        function input = generateDefaultInput(obj) %#ok<MANU>
            %generateDefaultInput Generate data when in debug mode
            %   L = generateDefaultInput(H) returns frame length, L, for the
            %   MPSK communication system, H. This method is used to provide
            %   input to the system in debug mode  (i.e. when the system is
            %   not attached to a test console). If the getInput method of
            %   system H is called in the debug mode, the input provided by this
            %   method is returned.
            
            % Since the MPSKSystem registers a 'NumTransmissions' test input,
            % this method should return the number of transmissions to be
            % generated at each call to the system's getInput method when
            % operating in debug mode.                   
            input = 500;
        end
    end        
    %===========================================================================
    % Define methods
    %===========================================================================
    methods
        function obj = MPSKSystem(varargin)
            %MPSKSystem constructor
            if nargin > 0
                % There are input arguments, so initialize with
                % property-value pairs.
                initPropValuePairs(obj, varargin{:});
            end
            obj.Description = 'MPSK/AWGN Communications system';
            
            % Create PSK modulator and demodulator objects.
            obj.Mod = modem.pskmod('M', obj.M, 'SymbolOrder', 'Gray');
            obj.Demod = modem.pskdemod('M', obj.M, 'SymbolOrder', 'Gray'); 
        end
        %=======================================================================
        % This communication system does not require a reset method.
        %=======================================================================
        
        %=======================================================================
        % Implement the setup method which will be called by the error rate test
        % console at the beginning of a new simulation point.
        %=======================================================================
        function setup(obj)
            %SETUP  Implement the setup method            
            %   Get current modulation order value from the test console and set
            %   the modulation order property of the modulator and demodulator
            %   objects. Get the current EbNo value from the test console to
            %   calculate the signal to noise ratio. 
            
            % Get the current value of M from the error rate test console. In
            % debug mode, calling the getTestParameter method returns the value
            % held by the system's M public property.
            obj.M = getTestParameter(obj,'M');
            
            % Set the modulator and demodulator 'M' property according to the
            % current modulation order value. 
            obj.Mod.M = obj.M;
            obj.Demod.M = obj.M;   
            
            % Calculate the number of bits per symbol.
            obj.BitsPerSymbol = log2(obj.M); 
            
            % Get the current value of EbNo from the error rate test console. In
            % debug mode, calling the getTestParameter method returns the value
            % held by the system's EbNo public property.
            obj.EbNo = getTestParameter(obj,'EbNo');
            
            % Calculate SNR according to the EbNo value and the number of bits
            % per symbol.             
            obj.SNR = obj.EbNo + 10*log10(obj.BitsPerSymbol);
        end    
        %=======================================================================
        % Implement the run method for the MPSK communications system. This
        % method will be called by the error rate test console at every
        % iteration. 
        %=======================================================================
        function run(obj)
            %RUN    Run method for the MPSK communications system            
            
            % Get the frame length value from the error rate test console and
            % generate this number of symbols using a data source.
            % In debug mode calling the getInput method will return an input
            % generated by the generateDefaultInput method implemented by the
            % MPSK system. 
            numSourceOutputs = getInput(obj,'NumTransmissions');
            
            % Generate numSourceOutputs source outputs
            txMsg = randi([0 obj.M-1], numSourceOutputs,1);
            
            % Log source data for symbol error rate analysis. Calling the
            % setTestProbeData logs data into a registered data probe held by
            % the error rate test console. 
            % In debug mode calls to the setTestProbeData method are ignored.
            setTestProbeData(obj,'TxInputSymbols',txMsg);            
            
            %Modulate the data
            txOutput = modulate(obj.Mod, txMsg);
            %Pass data through an AWGN channel with current SNR value
            chnlOutput  = awgn(txOutput,obj.SNR,'measured',[],'dB');
            %Demodulate the data
            rxOutput = demodulate(obj.Demod, chnlOutput);
            
            % Log receiver output data for symbol error rate analysis
            setTestProbeData(obj,'RxOutputSymbols',rxOutput);            

            %Convert symbol streams to bit streams
            bTx = de2bi(txMsg,obj.BitsPerSymbol,'left-msb')';
            bTx = bTx(:);
            bRx = de2bi(rxOutput,obj.BitsPerSymbol,'left-msb')';
            bRx = bRx(:);
            
            %Log data for bit error rate analysis
            setTestProbeData(obj,'TxInputBits',bTx);    
            setTestProbeData(obj,'RxOutputBits',bRx);                            
        end
        %=======================================================================
        % set method for M parameter
        %=======================================================================
        function set.M(obj,value)
            %Set method for parameter M
            validateattributes(value,...
                {'numeric'},...
                {'finite','real','positive','scalar','integer'}, ...
                [class(obj) '.' 'M'],...
                'sweep value for test parameter M');
            
            if ~isequal(value,2^nextpow2(value))
                error(generatemsgid('MNotPower2'),...
                    (['Values for test parameter M ',...
                    'should be a power of 2.']));
            end
            
            obj.M = value;
        end
    end
end
